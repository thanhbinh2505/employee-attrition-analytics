import pandas as pd
from db import get_engine


engine = get_engine()

query = """
select top 10 *
from dw.View_ML_NhanVien
order by NgayThang, MaNV
"""

df = pd.read_sql(query, engine)

print(df)

print("So dong:", len(df))