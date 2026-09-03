use PTNhanSu_DWH
go

create or alter view dw.View_ML_NhanVien
as
select DimNV.MaNV,
    DimNgay.NgayThang,
    DimNgay.Nam,
    DimNV.PhongBan,
    DimNV.ChucDanh,
    DimNV.CapBacCongViec,
    F.Tuoi,
    F.KhoangCachTuNha,
    F.SoLuongDuAn,
    F.SoGioTrungBinhThang,
    F.LamThemGio,
    F.DiemDanhGiaHieuSuat,
    F.DiemHaiLongCongViec,
    F.DiemHaiLongMoiTruong,
    F.ThuNhapThang,
    F.SoNamTaiCongTy,
    F.SoNamTuLanThangChucCuoi,
    F.DuocThangChucNamTruoc,
    F.SoNghiViec AS TargetNghiViec
from dw.FactTrangThaiNhanVien as F
	inner join dw.DimNhanVien as DimNV
		on F.KhoaNhanVien = DimNV.KhoaNhanVien
	inner join dw.DimNgay
		on F.KhoaNgayChot = DimNgay.KhoaNgay
go