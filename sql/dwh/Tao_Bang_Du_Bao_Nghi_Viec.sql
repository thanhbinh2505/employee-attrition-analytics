use PTNhanSu_DWH
go

create table dw.DimMucRuiRo
    (
        KhoaMucRuiRo tinyint not null primary key,
            
        TenMucRuiRo nvarchar(20) not null,
        ThuTuHienThi tinyint not null
    );

insert into dw.DimMucRuiRo
    (
        KhoaMucRuiRo,
        TenMucRuiRo,
        ThuTuHienThi
    )
    values
        (1, N'Thấp', 1),
        (2, N'Trung bình', 2),
        (3, N'Cao', 3);

select *
from dw.DimMucRuiRo
order by ThuTuHienThi;

create table dw.StagingKetQuaDuBaoNghiViec
    (
        MaNV int not null,
        NgayDuBao date not null,

        ThucTeNghiViec tinyint null,

        XacSuatNghiViec decimal(10,6) not null,
        DiemNguyCo decimal(6,2) not null,

        DuDoanNghiViec tinyint not null,

        MucRuiRo nvarchar(20) not null,
        ThuTuRuiRo tinyint not null,

        NguongDuDoan decimal(10,6) not null,

        XepHangNguyCo int null,
        PhanViNguyCo decimal(6,2) null,

        MoHinh nvarchar(50) not null,
        PhienBanMoHinh nvarchar(50) not null
    );

create table dw.FactDuBaoNghiViec
(
    KhoaDuBao bigint identity(1,1) primary key,

    KhoaNhanVien int not null,
    KhoaNgayDuBao int not null,
    KhoaMucRuiRo tinyint not null,

    ThucTeNghiViec tinyint null,

    XacSuatNghiViec decimal(10,6) not null,
    DiemNguyCo decimal(6,2) not null,

    DuDoanNghiViec tinyint not null,

    NguongDuDoan decimal(10,6) not null,

    XepHangNguyCo int null,
    PhanViNguyCo decimal(6,2) null,

    LaTP tinyint null,
    LaFP tinyint null,
    LaFN tinyint null,
    LaTN tinyint null,

    MoHinh nvarchar(50) not null,
    PhienBanMoHinh nvarchar(50) not null,

    constraint FK_DuBao_NhanVien foreign key (KhoaNhanVien) references dw.DimNhanVien(KhoaNhanVien),

    constraint FK_DuBao_Ngayb foreign key (KhoaNgayDuBao) references dw.DimNgay(KhoaNgay),

    constraint FK_DuBao_MucRuiRo foreign key (KhoaMucRuiRo) references dw.DimMucRuiRo(KhoaMucRuiRo)
);

select
    MucRuiRo,
    count(*) AS SoNhanVien,
    SUM(ThucTeNghiViec) AS SoNghiViec
from dw.StagingKetQuaDuBaoNghiViec
group by MucRuiRo
order by min(ThuTuRuiRo);


DELETE FROM dw.FactDuBaoNghiViec
WHERE PhienBanMoHinh = N'RF_2025_V1';
GO
--Nạp dữ liệu vào bảng Dự báo từ bảng staging kết quả
insert into dw.FactDuBaoNghiViec
(
    KhoaNhanVien,
    KhoaNgayDuBao,
    KhoaMucRuiRo,

    ThucTeNghiViec,
    XacSuatNghiViec,
    DiemNguyCo,
    DuDoanNghiViec,
    NguongDuDoan,
    XepHangNguyCo,
    PhanViNguyCo,
    LaTP,
    LaFP,
    LaFN,
    LaTN,

    MoHinh,
    PhienBanMoHinh
)
select
    F.KhoaNhanVien,
    D.KhoaNgay,
    R.KhoaMucRuiRo,

    S.ThucTeNghiViec,
    S.XacSuatNghiViec,
    S.DiemNguyCo,
    S.DuDoanNghiViec,
    S.NguongDuDoan,
    S.XepHangNguyCo,
    S.PhanViNguyCo,

    case
        when S.ThucTeNghiViec = 1 and S.DuDoanNghiViec = 1
        then 1 else 0
    end as LaTP,

    case
        when S.ThucTeNghiViec = 0 and S.DuDoanNghiViec = 1
        then 1 else 0
    end as LaFP,

    case
        when S.ThucTeNghiViec = 1 and S.DuDoanNghiViec = 0
        then 1 else 0
    end as LaFN,

    case
        when S.ThucTeNghiViec = 0 and S.DuDoanNghiViec = 0
        then 1 else 0
    end as LaTN,

    S.MoHinh,
    S.PhienBanMoHinh

from dw.StagingKetQuaDuBaoNghiViec S

inner join dw.DimNgay D
    on D.NgayThang = S.NgayDuBao

inner join dw.DimNhanVien NV
    on NV.MaNV = S.MaNV

inner join dw.FactTrangThaiNhanVien F
    on F.KhoaNhanVien = NV.KhoaNhanVien and F.KhoaNgayChot = D.KhoaNgay

inner join dw.DimMucRuiRo R
    on R.TenMucRuiRo = S.MucRuiRo;
go
