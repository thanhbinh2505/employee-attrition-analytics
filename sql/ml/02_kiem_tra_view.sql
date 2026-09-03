use PTNhanSu_DWH
go

select top 20 *
from dw.View_ML_NhanVien
order by NgayThang, MaNV
go

select count(*) as TongSnapshot, 
		count(distinct MaNV) as TongNhanVien,
		Min(Nam) as NamDau,
		Max(Nam) as NamCuoi,
		sum(TargetNghiViec) as TongNghiViec
from dw.View_ML_NhanVien
go

select Nam, count(*) as TongSnapshot, 
		count(distinct MaNV) as TongNhanVien,
		sum(TargetNghiViec) as TongNghiViec
from dw.View_ML_NhanVien
group by Nam
order by Nam;
go

select MaNV, NgayThang, count(*) as SoDong
from dw.View_ML_NhanVien
group by MaNV, NgayThang
having count(*) >1
go


		