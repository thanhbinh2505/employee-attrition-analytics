from sqlalchemy import create_engine
from urllib.parse import quote_plus

server = r"THANH_BINH\MSSQLSERVER01"
database = "PTNhanSu_DWH"
driver = "ODBC Driver 17 for SQL Server"

def get_engine():
    conn_str = quote_plus(
        f"driver={{{driver}}};"
        f"server={server};"
        f"database={database};"
        "Trusted_Connection=yes;"
        "TrustServerCertificate=yes;"
    )

    engine = create_engine(
        f"mssql+pyodbc:///?odbc_connect={conn_str}"
    )

    return engine