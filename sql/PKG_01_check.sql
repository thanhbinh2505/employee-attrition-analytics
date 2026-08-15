use PTNhanSu_Staging
go
SELECT *
FROM etl.NhatKyTaiDuLieu
ORDER BY MaNK DESC;

SELECT
    MaNK,
    COUNT(*) AS SoDongChuaXuLy
FROM stg.DuLieuTho_NV
WHERE DaXuLy = 0
GROUP BY MaNK;