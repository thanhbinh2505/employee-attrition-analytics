import random
from datetime import date, timedelta

import numpy as np
import pandas as pd


# =========================================================
# 1. CẤU HÌNH
# =========================================================

SEED = 42

# 10.000 nhân viên có thể tạo khoảng 30.000–50.000 dòng
# tùy tỷ lệ nghỉ việc và số năm làm việc.
NUM_EMPLOYEES = 10_000

START_YEAR = 2018
END_YEAR = 2025

OUTPUT_FILE = "Employee_Attrition.csv"

random.seed(SEED)
np.random.seed(SEED)


# =========================================================
# 2. DANH MỤC PHÒNG BAN VÀ CHỨC VỤ
# =========================================================

DEPARTMENT_ROLES = {
    "Information Technology": [
        "Software Engineer",
        "Data Analyst",
        "System Administrator",
        "QA Engineer",
        "IT Support"
    ],
    "Sales": [
        "Sales Executive",
        "Sales Representative",
        "Account Manager",
        "Sales Supervisor"
    ],
    "Human Resources": [
        "HR Executive",
        "Recruiter",
        "C&B Specialist",
        "HR Manager"
    ],
    "Finance": [
        "Accountant",
        "Financial Analyst",
        "Internal Auditor",
        "Finance Manager"
    ],
    "Marketing": [
        "Marketing Executive",
        "Content Specialist",
        "Digital Marketing Specialist",
        "Marketing Manager"
    ],
    "Operations": [
        "Operations Executive",
        "Warehouse Supervisor",
        "Procurement Specialist",
        "Operations Manager"
    ]
}


# Khoảng lương theo cấp bậc, đơn vị VND/tháng
LEVEL_SALARY_RANGE = {
    1: (7_000_000, 12_000_000),
    2: (12_000_000, 20_000_000),
    3: (20_000_000, 35_000_000),
    4: (35_000_000, 55_000_000),
    5: (55_000_000, 90_000_000)
}


# =========================================================
# 3. CÁC HÀM HỖ TRỢ
# =========================================================

def clamp(value, min_value, max_value):
    """Giới hạn giá trị trong một khoảng."""
    return max(min_value, min(value, max_value))


def random_date_in_year(year, start_month=1):
    """Sinh ngày hợp lệ ngẫu nhiên trong một năm."""
    start_date = date(year, start_month, 1)
    end_date = date(year, 12, 31)

    number_of_days = (end_date - start_date).days

    return start_date + timedelta(
        days=random.randint(0, number_of_days)
    )


def calculate_attrition_probability(
    overtime,
    job_satisfaction,
    environment_satisfaction,
    average_monthly_hours,
    number_projects,
    years_at_company,
    years_since_last_promotion,
    monthly_income,
    job_level
):
    """
    Tính xác suất nghỉ việc dùng để sinh dữ liệu mô phỏng.

    Xác suất tăng khi:
    - Nhân viên tăng ca.
    - Mức hài lòng thấp.
    - Số giờ làm việc cao.
    - Có nhiều dự án.
    - Lâu chưa được thăng chức.
    - Thâm niên thấp.
    - Thu nhập thấp so với cấp bậc.
    """

    low_salary_threshold = (
        LEVEL_SALARY_RANGE[job_level][0] * 1.10
    )

    # Điểm nền nhằm giữ tỷ lệ nghỉ việc ở mức vừa phải
    score = -3.25

    if overtime == "Yes":
        score += 0.95

    if job_satisfaction <= 2:
        score += 0.85

    if environment_satisfaction <= 2:
        score += 0.55

    if average_monthly_hours >= 220:
        score += 0.65

    if number_projects >= 6:
        score += 0.40

    if years_since_last_promotion >= 4:
        score += 0.55

    if years_at_company < 2:
        score += 0.45

    if monthly_income < low_salary_threshold:
        score += 0.35

    # Chuyển điểm thành xác suất bằng hàm sigmoid
    probability = 1 / (1 + np.exp(-score))

    return probability


# =========================================================
# 4. SINH DỮ LIỆU
# =========================================================

data = []

for emp_num in range(1, NUM_EMPLOYEES + 1):

    # -----------------------------------------------------
    # 4.1. Thuộc tính ban đầu của nhân viên
    # -----------------------------------------------------

    gender = random.choice(["Male", "Female"])

    birth_year = random.randint(1970, 2000)

    # Bảo đảm nhân viên ít nhất khoảng 20 tuổi khi vào làm
    minimum_hire_year = max(2010, birth_year + 20)

    hire_year = random.randint(
        minimum_hire_year,
        END_YEAR - 1
    )

    hire_date = random_date_in_year(hire_year)

    current_department = random.choice(
        list(DEPARTMENT_ROLES.keys())
    )

    current_role = random.choice(
        DEPARTMENT_ROLES[current_department]
    )

    current_job_level = random.choices(
        population=[1, 2, 3, 4],
        weights=[45, 30, 18, 7],
        k=1
    )[0]

    current_salary = random.randint(
        *LEVEL_SALARY_RANGE[current_job_level]
    )

    distance_from_home = random.randint(1, 40)

    marital_status = random.choice(
        ["Single", "Married", "Divorced"]
    )

    job_satisfaction_state = random.randint(2, 4)
    environment_satisfaction_state = random.randint(2, 4)

    last_promotion_year = hire_year

    # Nếu nhân viên vào làm trước START_YEAR,
    # chỉ ghi dữ liệu từ START_YEAR.
    first_data_year = max(hire_year, START_YEAR)

    first_record = True
    promotion_last_year = 0

    # -----------------------------------------------------
    # 4.2. Sinh dữ liệu lịch sử theo từng năm
    # -----------------------------------------------------

    for year in range(first_data_year, END_YEAR + 1):

        if year == hire_year:
            snapshot_date = hire_date
        else:
            snapshot_date = date(year, 1, 1)

        current_age = year - birth_year

        years_at_company = max(
            0,
            year - hire_year
        )

        years_since_last_promotion = max(
            0,
            year - last_promotion_year
        )

        # Số dự án nhân viên tham gia
        number_projects = int(
            np.clip(
                np.random.poisson(3.5),
                1,
                8
            )
        )

        # Tình trạng tăng ca
        overtime = random.choices(
            population=["Yes", "No"],
            weights=[35, 65],
            k=1
        )[0]

        # Số giờ làm việc trung bình mỗi tháng
        average_monthly_hours = int(
            np.clip(
                np.random.normal(
                    168
                    + number_projects * 6
                    + (28 if overtime == "Yes" else 0),
                    18
                ),
                120,
                280
            )
        )

        performance_rating = int(
            np.clip(
                round(np.random.normal(3.4, 0.8)),
                1,
                5
            )
        )

        # Mức hài lòng có thể thay đổi nhẹ qua từng năm
        job_satisfaction_state = clamp(
            job_satisfaction_state
            + random.choice([-1, 0, 0, 0, 1]),
            1,
            4
        )

        environment_satisfaction_state = clamp(
            environment_satisfaction_state
            + random.choice([-1, 0, 0, 0, 1]),
            1,
            4
        )

        # -------------------------------------------------
        # 4.3. Xác định nguy cơ nghỉ việc
        # -------------------------------------------------

        attrition_probability = (
            calculate_attrition_probability(
                overtime=overtime,
                job_satisfaction=job_satisfaction_state,
                environment_satisfaction=(
                    environment_satisfaction_state
                ),
                average_monthly_hours=(
                    average_monthly_hours
                ),
                number_projects=number_projects,
                years_at_company=years_at_company,
                years_since_last_promotion=(
                    years_since_last_promotion
                ),
                monthly_income=current_salary,
                job_level=current_job_level
            )
        )

        attrition_flag = int(
            random.random() < attrition_probability
        )

        leave_date = None

        if attrition_flag == 1:

            # Nhân viên nghỉ trong vòng 30–365 ngày
            # kể từ ngày snapshot.
            leave_date = (
                snapshot_date
                + timedelta(days=random.randint(30, 365))
            )

            end_date = leave_date

            # Trạng thái tại cuối khoảng hiệu lực
            is_active = 0

            change_type = "Terminated"

        else:

            end_date = date(year, 12, 31)

            is_active = 1

            if first_record:
                change_type = "New"
            else:
                change_type = "AnnualSnapshot"

        # -------------------------------------------------
        # 4.4. Ghi nhận dòng dữ liệu
        # -------------------------------------------------

        row = {
            "EmployeeNumber": emp_num,

            # Thông tin phiên bản và incremental loading
            "SnapshotYear": year,
            "SnapshotDate": snapshot_date,
            "BatchID": year - START_YEAR + 1,

            # Thông tin nhân viên
            "Age": current_age,
            "Gender": gender,
            "MaritalStatus": marital_status,
            "Department": current_department,
            "JobRole": current_role,
            "JobLevel": current_job_level,
            "DistanceFromHome": distance_from_home,

            # Thông tin công việc
            "NumberProject": number_projects,
            "AverageMonthlyHours": average_monthly_hours,
            "OverTime": overtime,
            "PerformanceRating": performance_rating,
            "JobSatisfaction": job_satisfaction_state,
            "EnvironmentSatisfaction": (
                environment_satisfaction_state
            ),
            "MonthlyIncome_VND": int(
                round(current_salary, -3)
            ),

            # Thâm niên và thăng tiến
            "YearsAtCompany": years_at_company,
            "YearsSinceLastPromotion": (
                years_since_last_promotion
            ),
            "PromotionLastYear": promotion_last_year,

            # Nhãn dự báo:
            # 1 = nghỉ trong vòng 12 tháng sau SnapshotDate
            # 0 = không nghỉ trong khoảng dự báo
            "Attrition": attrition_flag,

            # Thông tin lịch sử
            "LeaveDate": leave_date,
            "Start_Date": snapshot_date,
            "End_Date": end_date,
            "Is_Active": is_active,
            "ChangeType": change_type
        }

        data.append(row)

        first_record = False

        # Nếu nhân viên đã nghỉ thì không sinh dữ liệu năm sau
        if attrition_flag == 1:
            break

        # -------------------------------------------------
        # 4.5. Cập nhật thông tin cho năm tiếp theo
        # -------------------------------------------------

        promotion_last_year = 0

        # Tăng lương hằng năm khoảng 4%–10%
        current_salary = int(
            current_salary
            * random.uniform(1.04, 1.10)
        )

        # Xác suất được thăng chức
        if (
            current_job_level < 5
            and random.random() < 0.09
        ):
            current_job_level += 1

            current_salary = int(
                max(
                    current_salary
                    * random.uniform(1.12, 1.25),
                    LEVEL_SALARY_RANGE[
                        current_job_level
                    ][0]
                )
            )

            last_promotion_year = year + 1
            promotion_last_year = 1

        # Xác suất chuyển phòng ban
        if random.random() < 0.03:

            other_departments = [
                department
                for department in DEPARTMENT_ROLES
                if department != current_department
            ]

            current_department = random.choice(
                other_departments
            )

            current_role = random.choice(
                DEPARTMENT_ROLES[
                    current_department
                ]
            )

        # Xác suất đổi chức vụ trong cùng phòng ban
        elif random.random() < 0.08:

            current_role = random.choice(
                DEPARTMENT_ROLES[
                    current_department
                ]
            )

        # Thay đổi tình trạng hôn nhân
        if (
            marital_status == "Single"
            and random.random() < 0.08
        ):
            marital_status = "Married"

        elif (
            marital_status == "Married"
            and random.random() < 0.015
        ):
            marital_status = "Divorced"


# =========================================================
# 5. TẠO DATAFRAME VÀ BỔ SUNG THÔNG TIN SCD
# =========================================================

df = pd.DataFrame(data)

df.sort_values(
    by=["EmployeeNumber", "SnapshotDate"],
    inplace=True
)

df.reset_index(drop=True, inplace=True)

# Khóa duy nhất cho từng phiên bản
df.insert(
    0,
    "RecordID",
    range(1, len(df) + 1)
)

# Số phiên bản SCD của từng nhân viên
df["SCD_Version"] = (
    df.groupby("EmployeeNumber")
    .cumcount()
    + 1
)

# Mặc định tất cả phiên bản không phải hiện tại
df["Is_Current"] = 0

# Phiên bản cuối cùng của mỗi nhân viên là phiên bản hiện tại
latest_indexes = (
    df.groupby("EmployeeNumber")["SnapshotDate"]
    .idxmax()
)

df.loc[latest_indexes, "Is_Current"] = 1


# =========================================================
# 6. CHUYỂN ĐỊNH DẠNG NGÀY
# =========================================================

date_columns = [
    "SnapshotDate",
    "LeaveDate",
    "Start_Date",
    "End_Date"
]

for column in date_columns:
    df[column] = (
        pd.to_datetime(df[column])
        .dt.strftime("%Y-%m-%d")
    )


# =========================================================
# 7. XUẤT MỘT FILE CSV DUY NHẤT
# =========================================================

df.to_csv(
    OUTPUT_FILE,
    index=False,
    encoding="utf-8-sig"
)


# =========================================================
# 8. THỐNG KÊ KẾT QUẢ
# =========================================================

total_records = len(df)

total_employees = (
    df["EmployeeNumber"]
    .nunique()
)

total_attrition_records = int(
    df["Attrition"].sum()
)

attrition_rate = (
    total_attrition_records
    / total_records
    * 100
)

print("=" * 60)
print("HOÀN THÀNH TẠO DỮ LIỆU")
print("=" * 60)

print(f"Tên file: {OUTPUT_FILE}")
print(f"Số nhân viên: {total_employees:,}")
print(f"Tổng số dòng lịch sử: {total_records:,}")
print(
    f"Số dòng có Attrition = 1: "
    f"{total_attrition_records:,}"
)
print(
    f"Tỷ lệ Attrition trên các snapshot: "
    f"{attrition_rate:.2f}%"
)

print("\nSố dòng theo BatchID:")
print(
    df.groupby(
        ["BatchID", "SnapshotYear"]
    )
    .size()
    .reset_index(name="NumberOfRows")
)