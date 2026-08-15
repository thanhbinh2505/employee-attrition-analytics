use master
go

if db_id(N'PTNhanSu_DWH') is null
begin create database PTNhanSu_DWH;
end
go

use PTNhanSu_DWH
go

if not exists (select * from sys.schemas where name = N'dw')
	begin
		exec(N'create schema dw');
	end
go

create table dw.DimNgay(
	KhoaNgay int not null primary key,
	NgayThang date not null unique,
	Ngay tinyint not null,
	Thang tinyint not null,
	TenThang nvarchar(20) not null,
	Quy tinyint not null,
	Nam smallint not null,
	NamThang varchar(10) not null,
	LaCuoiTuan bit not null,

    constraint CK_DimNgay_Thang check (Thang between 1 and 12),
    constraint CK_DimNgay_Quy check (Quy between 1 and 4),
    constraint CK_DimNgay_Ngay check (Ngay between 1 and 31)
);
go

create table dw.DimNhanVien(
	KhoaNhanVien int identity(1,1) primary key,
	MaNV int not null,
	GioiTinh varchar(10) not null,
    TinhTrangHonNhan varchar(20) null,
	PhongBan nvarchar(100) not null,
	ChucDanh nvarchar(150) not null,
	CapBacCongViec tinyint not null,

	NgayHieuLuc date not null,
	NgayHetHieuLuc date not null
    constraint df_dimnhanvien_ngayhethieulu default ('9999-12-31'),

	LaHienTai bit not null
	constraint df_dimnhanvien_lahientai default 1,

	PhienBan int not null
	constraint df_dimnhanvien_phienban default 1,

	MaBam varbinary(32) null,
	ThoiGianTao datetime2(0) not null 
    constraint df_dimnhanvien_thoigiantao default sysdatetime(),
    ThoiGianCapNhat datetime2(0) null,

    constraint ck_dimnhanvien_capbac check (CapBacCongViec between 1 and 5),

    constraint ck_dimnhanvien_ngay check (NgayHetHieuLuc >= NgayHieuLuc),
    constraint ck_dimnhanvien_phienban check (PhienBan >= 1),
    constraint ck_dimnhanvien_gioitinh check(GioiTinh in('Male','Female')),
);
go

create unique index ux_dimnhanvien_hientai on dw.DimNhanVien(MaNV)
where LaHienTai = 1;
create unique index ux_dimnhanvien_manv_phienban on dw.DimNhanVien
(
    MaNV,
    PhienBan
);
create index ix_dimNhanVien_LichSu on dw.DimNhanVien(MaNV, NgayHieuLuc, NgayHetHieuLuc);

create table dw.DimNhomLuong(
    KhoaNhomLuong int not null primary key,
    TenNhomLuong nvarchar(50) not null unique,
    ThuNhapToiThieu bigint null,
    ThuNhapToiDa bigint null,
    ThuTu int not null,
    constraint ck_DimNhomLuong_ThuNhap check
        (
            ThuNhapToiDa is null
            or ThuNhapToiThieu is null
            or ThuNhapToiDa >= ThuNhapToiThieu
        )
    
);
go

if not exists (select 1 from dw.DimNhomLuong)
begin
    insert into dw.DimNhomLuong
    (KhoaNhomLuong, TenNhomLuong, ThuNhapToiThieu, ThuNhapToiDa, ThuTu)
    values
    (0, N'Khong xac dinh', null, null, 0),
    (1, N'Duoi 12 trieu', 0, 11999999, 1),
    (2, N'Tu 12 den duoi 18 trieu', 12000000, 17999999, 2),
    (3, N'Tu 18 den duoi 30 trieu', 18000000, 29999999, 3),
    (4, N'Tu 30 trieu tro len', 30000000, null, 4);
end;
go

create table dw.DimNhomThamNien(
    KhoaNhomThamNien int not null primary key,
    TenNhomThamNien nvarchar(50) not null unique,
    SoNamToiThieu tinyint null,
    SoNamToiDa tinyint null,
    ThuTu int not null,

    constraint ck_DimNhomThamNien_SoNam check
        (
            SoNamToiDa  is null
            or SoNamToiThieu is null
            or SoNamToiDa >= SoNamToiThieu
        )
);
go

if not exists (select 1 from dw.DimNhomThamNien)
begin
    insert into dw.DimNhomThamNien
    (KhoaNhomThamNien, TenNhomThamNien, SoNamToiThieu, SoNamToiDa, ThuTu)
    values
    (0, N'Khong xac dinh', null, null, 0),
    (1, N'Duoi 1 nam', 0, 0, 1),
    (2, N'Tu 1 den 3 nam', 1, 3, 2),
    (3, N'Tu 4 den 5 nam', 4, 5, 3),
    (4, N'Tu 6 den 10 nam', 6, 10, 4),
    (5, N'Tren 10 nam', 11, null, 5);
end;
go

create table dw.DimTrangThaiNghiViec(
    KhoaTrangThaiNghiViec int not null primary key,
    NghiViecTrong12Thang bit null,
    TenTrangThai nvarchar(100) not null unique
);
go


if not exists (select 1 from dw.DimTrangThaiNghiViec)
begin
    insert into dw.DimTrangThaiNghiViec
    (KhoaTrangThaiNghiViec, NghiViecTrong12Thang, TenTrangThai)
    values
    (0, null, N'Khong xac dinh'),
    (1, 0, N'Khong nghi trong 12 thang tiep theo'),
    (2, 1, N'Nghi trong 12 thang tiep theo');
end;
go

create table dw.FactTrangThaiNhanVien(
    KhoaTrangThaiNhanVien bigint identity(1,1) not null primary key clustered,
    KhoaNhanVien int not null,
    KhoaNgayChot int not null,
    KhoaNgayNghi int null,
    KhoaNhomLuong int not null,
    KhoaNhomThamNien int not null,
    KhoaTrangThaiNghiViec int not null,
    
    -- Truy vết nguồn (Đồng bộ kiểu dữ liệu với stg.NhanVienChuanHoa)
    MaBanGhiNguon bigint not null,
    MaNK_Nguon int not null,
    
    Tuoi tinyint not null,
    KhoangCachTuNha smallint not null,
    SoLuongDuAn tinyint not null,
    SoGioTrungBinhThang smallint not null,
    LamThemGio bit not null,

    DiemDanhGiaHieuSuat tinyint not null,
    DiemHaiLongCongViec tinyint not null,
    DiemHaiLongMoiTruong tinyint not null,

    ThuNhapThang bigint not null,

    SoNamTaiCongTy tinyint not null,
    SoNamTuLanThangChucCuoi tinyint not null,
    DuocThangChucNamTruoc bit not null,

    SoNhanVien tinyint not null
        constraint df_facttrangthai_sonhanvien default 1,

    SoNghiViec tinyint not null,

    ThoiGianTai datetime2(0) not null 
        constraint df_facttrangthai_thoigiantai default sysdatetime(),

    -- Ràng buộc Foreign Keys
    constraint fk_facttrangthai_nhanvien foreign key (KhoaNhanVien) references dw.DimNhanVien(KhoaNhanVien),
    constraint fk_facttrangthai_ngaychot foreign key (KhoaNgayChot) references dw.DimNgay(KhoaNgay),
    constraint fk_facttrangthai_ngaynghi foreign key (KhoaNgayNghi) references dw.DimNgay(KhoaNgay),
    constraint fk_facttrangthai_nhomluong foreign key (KhoaNhomLuong) references dw.DimNhomLuong(KhoaNhomLuong),
    constraint fk_facttrangthai_nhomthamnien foreign key (KhoaNhomThamNien) references dw.DimNhomThamNien(KhoaNhomThamNien),
    constraint fk_facttrangthai_trangthainghi foreign key (KhoaTrangThaiNghiViec) references dw.DimTrangThaiNghiViec(KhoaTrangThaiNghiViec),

    constraint ck_facttrangthai_tuoi check (Tuoi between 18 and 70),
    constraint ck_facttrangthai_soduan check (SoLuongDuAn between 0 and 20),
    constraint ck_facttrangthai_sogio check (SoGioTrungBinhThang between 80 and 350),
    constraint ck_facttrangthai_hieusuat check (DiemDanhGiaHieuSuat between 1 and 5),
    constraint ck_facttrangthai_hailongcv check (DiemHaiLongCongViec between 1 and 4),
    constraint ck_facttrangthai_hailongmt check (DiemHaiLongMoiTruong between 1 and 4),
    constraint ck_facttrangthai_thunhap check (ThuNhapThang > 0),
    constraint ck_facttrangthai_sonhanvien check (SoNhanVien = 1),
    constraint ck_facttrangthai_songhiviec check (SoNghiViec in (0,1))

);
go

create unique index ux_facttrangthai_banghinguon on dw.FactTrangThaiNhanVien(MaBanGhiNguon, MaNK_Nguon);
go

create index ix_facttrangthai_ngaychot on dw.FactTrangThaiNhanVien(KhoaNgayChot);
go

create index ix_facttrangthai_nhanvien on dw.FactTrangThaiNhanVien(KhoaNhanVien);
go

declare @TuNgay date = '2018-01-01';
declare @DenNgay date = '2026-12-31';
;with CTE_Ngay as
(
    select @TuNgay as NgayThang
    union all
    select dateadd(day, 1, NgayThang)
    from CTE_Ngay
    where NgayThang < @DenNgay
)
insert into dw.DimNgay
(
    KhoaNgay,
    NgayThang,
    Ngay,
    Thang,
    TenThang,
    Quy,
    Nam,
    NamThang,
    LaCuoiTuan
)
select
    convert(int, convert(char(8), N.NgayThang, 112)) as KhoaNgay, N.NgayThang,
    day(N.NgayThang) as Ngay,
    month(N.NgayThang) as Thang,
    N'Tháng ' + convert(nvarchar(2), month(N.NgayThang)) as TenThang,
    datepart(quarter, N.NgayThang) as Quy,
    year(N.NgayThang) as Nam,
    convert(char(7), N.NgayThang, 126) as NamThang,
    case
        when datediff(day, '19000101', N.NgayThang) % 7 in (5, 6)
            then 1
        else 0
    end as LaCuoiTuan

from CTE_Ngay N

where not exists
(
    select 1
    from dw.DimNgay D
    where D.NgayThang = N.NgayThang
)
option (maxrecursion 0);
go