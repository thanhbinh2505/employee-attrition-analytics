use master
go

if DB_ID(N'PTNhanSu_Staging') is null
begin create database PTNhanSu_Staging;
end
go

use PTNhanSu_Staging
go

if not exists (select * from sys.schemas where name = N'stg')
	begin
		exec(N'create schema stg');
	end
go

if not exists (select * from sys.schemas where name = N'etl')
	begin
		exec(N'create schema etl');
	end
go
select * from sys.schemas

create table etl.NhatKyTaiDuLieu(
	MaNK int identity(1,1) not null primary key,
	TenFile nvarchar(250) not null,
	HeThong nvarchar(50) not null
	constraint df_nhatky_hethong default N'csv',
	ThoiGianBatDau datetime2(0) not null
	constraint df_nhatky_thoigianbatdau default sysdatetime(),
	ThoiGianKetThuc datetime null,
	TrangThai varchar(20) not null
	constraint df_nhatky_trangthai default N'RUNNING',

	SoDongDoc int not null constraint df_nhatky_sodongdoc default 0,
    SoDongHopLe int not null  constraint df_nhatky_sodonghople default 0,
    SoDongLoi int not null  constraint df_nhatky_sodongloi default 0,

    ThongBaoLoi nvarchar(500) null,
    constraint ck_nhatky_trangthai check (TrangThai IN ('RUNNING', 'SUCCESS', 'FAILED')),
    constraint ck_nhatky_sodemdong check (SoDongDoc >= 0 and SoDongHopLe >= 0 and SoDongLoi >= 0 and SoDongHopLe + SoDongLoi <= SoDongDoc)

);
go

create table stg.DuLieuTho_NV(
	MaDL bigint identity(1,1) not null primary key,
	MaNK int not null,

	constraint fk_DuLieuTho_NhatKyTai foreign key (MaNK) references etl.NhatKyTaiDuLieu(MaNK),

	TenFile nvarchar(250) null,

	MaBanGhi nvarchar(50) null,
	MaNV nvarchar(50) null,
	NamChotDuLieu nvarchar(20) null,
	NgayChotDuLieu nvarchar(50) null,
	MaNK_Nguon nvarchar(20) null,
	Tuoi nvarchar(20) null,
	GioiTinh nvarchar(30) null,
	TinhTrangHonNhan nvarchar(30) null,
	PhongBan nvarchar(100) null,
	ChucDanh nvarchar(150) null,
	CapBacCongViec nvarchar(20) null,
	KhoangCachTuNha nvarchar(20) null,
	SoLuongDuAn nvarchar(20) null,
	SoGioTrungBinhThang nvarchar(20) null,
	LamThemGio nvarchar(20) null,
	DiemDanhGiaHieuSuat nvarchar(20) null,
	DiemHaiLongCongViec nvarchar(20) null,
	DiemHaiLongMoiTruong nvarchar(20) null,
	ThuNhapThang nvarchar(50) null,
	SoNamTaiCongTy nvarchar(20) null,
	SoNamTuLanThangChuc nvarchar(20) null,
	DuocThangChucNamTruoc nvarchar(20) null,
	DuBaoNghiViec nvarchar(20) null,
	NgayNghiViec  nvarchar(50) null,
	NgayBatDau  nvarchar(50) null,
	NgayKetThuc nvarchar(50) null,
	TrangThaiHoatDong nvarchar(20) null,
	LoaiThayDoi nvarchar(50) null,
	PhienBan_SCD nvarchar(20) null,
	LaBanGhiHienTai nvarchar(20) null,

	ThoiGianTaiDL datetime2(0) not null
	constraint df_dulieutho_thoigiantai default sysdatetime(),
	DaXuLy bit not null
	constraint df_dulieutho_daxuly default 0
);
go

--Tạo chỉ mục để khi truy vấn tối ưu hơn
create index idx_dulieutho_mank on stg.DuLieuTho_NV(MaNK, DaXuLy);
go

create table stg.NhanVienChuanHoa(
	MaCH bigint identity(1,1) not null primary key,
	MaNK int not null,
	MaDL bigint not null,

	constraint fk_chuanhoa_nhatkytai FOREIGN KEY (MaNK) REFERENCES etl.NhatKyTaiDuLieu(MaNK),
    constraint fk_chuanhoa_dulieutho FOREIGN KEY (MaDL) REFERENCES stg.DuLieuTho_NV(MaDL),

	MaBanGhi             bigint not null,
	MaNV                 int not null,
	NamChotDuLieu                int not null,
	NgayChotDuLieu               date not null,
	MaNK_Nguon               int not null,
	Tuoi                         tinyint not null,
	GioiTinh                     varchar(10) not null,
	TinhTrangHonNhan             varchar(20) not null,
	PhongBan                     nvarchar(100) not null,
	ChucDanh                     nvarchar(150) not null,
	CapBacCongViec               tinyint not null,
	KhoangCachTuNha              SMALLINT not null,
	SoLuongDuAn                  tinyint not null,
	SoGioTrungBinhThang       SMALLINT not null,
	LamThemGio                 bit not null,
	DiemDanhGiaHieuSuat          tinyint not null,
	DiemHaiLongCongViec          tinyint not null,
	DiemHaiLongMoiTruong         tinyint not null,
	ThuNhapThang      bigint not null,
	SoNamTaiCongTy               tinyint not null,
	SoNamTuLanThangChucCuoi      tinyint not null,
	DuocThangChucNamTruoc        bit not null,
	NghiViecTrongKy      bit not null,
	NgayNghiViec                 date null,

	NgayBatDauNguon           date null,
	NgayKetThucNguon       date null,
	TrangThaiHoatDongNguon            bit null,
	LoaiThayDoiNguon          varchar(50) null,
	PhienBanNguon         int null,
	LaBanGhiHienTaiNguon        bit null,

	MaBam varbinary(32) null, -- Phục vụ so sánh SCD
	NgayHieuLuc_SCD date null,
    NgayHetHieuLuc_SCD date null,

    PhienBan_SCD int null,
    LaPhienBanHienTai bit null,
    TrangThaiChatLuong varchar(10) not null
    constraint df_TrangThaiChuanHoa_ChatLuong default 'VALID',

    ThongBaoLoi  nvarchar(2000) null,

    ThoiGianTai datetime2(0) not null
    constraint df_TrangThaiChuanHoa_ThoiGianTai default sysdatetime(),

	constraint ck_chuanhoa_tuoi check (Tuoi between 18 and 70),
	constraint ck_chuanhoa_gioitinh check(GioiTinh in('Male','Female')),
	constraint ck_chuanhoa_capbac check(CapBacCongViec between 1 and 5),
	constraint ck_chuanhoa_khoangcach check(KhoangCachTuNha between 0 and 100),
	constraint ck_chuanhoa_soduan check (SoLuongDuAn between 0 and 20), 
	constraint ck_chuanhoa_sogiolam check (SoGioTrungBinhThang between 80 and 350), 
	constraint ck_chuanhoa_diemhieusuat check (DiemDanhGiaHieuSuat between 1 and 5), 
	constraint ck_chuanhoa_hailongcv check (DiemHaiLongCongViec between 1 and 4), 
	constraint ck_chuanhoa_hailongmt check (DiemHaiLongMoiTruong between 1 and 4), 
	constraint ck_chuanhoa_thunhap check (ThuNhapThang > 0), 
	constraint ck_chuanhoa_trangthaichatluong check (TrangThaiChatLuong in ('VALID', 'WARNING'))

);
go


create unique index ux_chuanhoa_banghinguon on stg.NhanVienChuanHoa(MaBanGhi, MaNK_Nguon);
go

create unique index ux_chuanhoa_MaDL on stg.NhanVienChuanHoa(MaDL);

create index ix_chuanhoa_tangdan on stg.NhanVienChuanHoa(MaNK_Nguon, MaNV, NgayChotDuLieu);
go

create table etl.LoiXuLy
(
    MaLoi               bigint identity(1,1) not null primary key,
    MaNK          int not null,
    MaDL         bigint null,

    TenGoiSSIS          nvarchar(150) null,
    TenTacVu            nvarchar(150) null,
    CotLoi              nvarchar(150) null,
    MaLoiSSIS           int null,
    ThongBaoLoi         nvarchar(2000) not null,
    DuLieuLoi           nvarchar(max) null,

    ThoiGianGhiLoi      datetime2(0) not null
    constraint df_loixuly_thoigianghi default sysdatetime(),

    constraint fk_loixuly_nhatkytai foreign key (MaNK) references etl.NhatKyTaiDuLieu(MaNK),
    constraint fk_loixuly_dulieutho foreign key (MaDL) references stg.DuLieuTho_NV(MaDL)
);
go

create index ix_loixuly_manhatky on etl.LoiXuLy(MaNK, ThoiGianGhiLoi);
go

create table etl.MocDuLieu
(
    TenTienTrinh                sysname not null primary key,
    MaNguon_End          int not null
    constraint df_mocdulieu_madotnguon default 0,

    NgayChot_End           date null,
    ThoiGianTaiThanhCong_End   datetime2(0) null,

    ThoiGianCapNhat             datetime2(0) not null
    constraint df_mocdulieu_capnhat default sysdatetime(),

    constraint ck_mocdulieu_madotnguon check (MaNguon_End >= 0)
);
go


if not exists
(
    select 1
    from etl.MocDuLieu
    where TenTienTrinh = N'TrangThaiNhanVien'
)
begin
    insert into etl.MocDuLieu(TenTienTrinh, MaNguon_End, NgayChot_End, ThoiGianTaiThanhCong_End)
    values(N'TrangThaiNhanVien', 0,null, null)
end




