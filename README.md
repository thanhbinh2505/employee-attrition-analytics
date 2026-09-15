Hệ thống phân tích và dự báo nguy cơ nghỉ việc của nhân viên

1. Phần mềm cần cài

- Microsoft SQL Server
- SQL Server Management Studio (SSMS)
- SQL Server Integration Services Projects (SSIS)
- Microsoft Analysis Services Projects (SSAS)
- Power BI Desktop


2. Tạo cơ sở dữ liệu

Bước 1 - Tạo Staging

Chạy file: sql\Tao_Staging.sql

Bước 2 - Tạo Data Warehouse

Chạy file: sql\Tao_DataWarehouse.sql

3. Chạy ETL bằng SSIS (Visual Studio)

Kiểm tra Connection Manager và chỉnh lại:

Server Name
Database Name
Đường dẫn file CSV nguồn

Sau đó chạy các package:

1. PKG_01_NapDL_Tho
2. PKG_02_ChuanHoaNV
3. PKG_03_SCD_Type2_DimNhanVien
4. PKG_04_Load_FactTrangThaiNhanVien

4. Tạo View cho Machine Learning

Chạy file: sql\01_Tao_view_ml.sql

Sau đó kiểm tra: sql\02_kiem_tra_view.sql

Tạo bảng lưu kết quả dự báo: chạy sql\Tao_Bang_Du_Bao_Nghi_Viec.sql

File này cần được chạy trước notebook dự báo


5. Cài môi trường Python

Tạo môi trường ảo: python -m venv .venv

Cập nhật pip: python -m pip install --upgrade pip

Cài thư viện: pip install -r requirements.txt


6. Cấu hình kết nối Python

Mở file: python\src\db.py

Kiểm tra thông tin kết nối SQL Server cho đúng máy đang chạy.

Database sử dụng: PTNhanSu_DWH

7. Chạy notebook Machine Learning

Mở thư mục: python\notebooks\

Chạy toàn bộ phần Machine Learning: 
1. 01_eda.ipynb
2. 02_Kmeans.ipynb
3. 03_knn.ipynb
4. 04_tree.ipynb
5. 05_random_forest.ipynb

Nếu chỉ cần chạy lại mô hình dự báo cuối: python\notebooks\05_random_forest.ipynb

Sau khi chạy, kiểm tra dữ liệu dự báo đã được ghi vào SQL Server.

8. Deploy và Process SSAS

Mở project: ssas\PTNhanSu_ssas\ (Visual Studio)

Kiểm tra Data Source đang kết nối tới: PTNhanSu_DWH

Vào: Project → Properties → Deployment

Đổi: Server = (Tên SQL Server)

Sau đó: Deploy

Deploy thành công thì thực hiện: Process → Process Full

9. Mở Power BI

Mở file: power_bi\DashBoardFinal.pbix

Power BI yêu cầu kết nối lại, nhập đúng tên server SSAS.

