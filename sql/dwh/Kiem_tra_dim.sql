select

count(*) as SoDongKhongCoDim

from PTNhanSu_Staging.stg.NhanVienChuanHoa S



left join PTNhanSu_DWH.dw.DimNhanVien D

on S.MaNV = D.MaNV

and S.PhienBan_SCD = D.PhienBan



where S.TrangThaiChatLuong = 'VALID'

and D.KhoaNhanVien is null;


SELECT COUNT(*) AS SoDongThieuDim
FROM dw.FactTrangThaiNhanVien F
LEFT JOIN dw.DimNhanVien D
    ON F.KhoaNhanVien = D.KhoaNhanVien
WHERE D.KhoaNhanVien IS NULL;

SELECT COUNT(*) AS SoDongSaiSCD
FROM dw.FactTrangThaiNhanVien F
JOIN dw.DimNhanVien D
    ON F.KhoaNhanVien = D.KhoaNhanVien
WHERE F.KhoaNgayChot < 
      CONVERT(INT, CONVERT(CHAR(8), D.NgayHieuLuc, 112))
   OR
      F.KhoaNgayChot >
      CONVERT(INT, CONVERT(CHAR(8), D.NgayHetHieuLuc, 112));

      SELECT 
    MaBanGhiNguon,
    MaNK_Nguon,
    COUNT(*) AS SoLan
FROM dw.FactTrangThaiNhanVien
GROUP BY 
    MaBanGhiNguon,
    MaNK_Nguon
HAVING COUNT(*) > 1;

select
    S.NgayNghiViec
from PTNhanSu_Staging.stg.NhanVienChuanHoa S

left join PTNhanSu_DWH.dw.DimNgay D
    on S.NgayNghiViec = D.NgayThang

where S.NgayNghiViec is not null
  and D.KhoaNgay is null

group by S.NgayNghiViec;

use PTNhanSu_DWH;
go

select count(*) as SoDongFact
from dw.FactTrangThaiNhanVien;

select
    min(KhoaNgayChot) as NgayDau,
    max(KhoaNgayChot) as NgayCuoi,
    count(*) as SoDong,
    sum(SoNhanVien) as TongSoNhanVien,
    sum(SoNghiViec) as TongSoNghiViec
from dw.FactTrangThaiNhanVien;

    select
        F.KhoaTrangThaiNhanVien,
        D.MaNV,
        F.KhoaNgayChot,
        D.PhienBan,
        D.TinhTrangHonNhan,
        D.PhongBan,
        D.ChucDanh,
        D.NgayHieuLuc,
        D.NgayHetHieuLuc

    from dw.FactTrangThaiNhanVien F

    inner join dw.DimNhanVien D
        on F.KhoaNhanVien = D.KhoaNhanVien

    where D.MaNV = 5

    order by F.KhoaNgayChot;

    select
    F.KhoaTrangThaiNhanVien,
    D.MaNV,
    F.KhoaNgayChot,
    D.PhienBan,
    D.NgayHieuLuc,
    D.NgayHetHieuLuc

from dw.FactTrangThaiNhanVien F

inner join dw.DimNhanVien D
    on F.KhoaNhanVien = D.KhoaNhanVien

inner join dw.DimNgay N
    on F.KhoaNgayChot = N.KhoaNgay

where N.NgayThang < D.NgayHieuLuc
   or N.NgayThang > D.NgayHetHieuLuc;

   select count(*) as Sau
from dw.FactTrangThaiNhanVien;