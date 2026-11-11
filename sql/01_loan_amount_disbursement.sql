-- Tổng số tiền đăng ký vay ban đầu và giải ngân theo từng sản phẩm tín dụng
SELECT 
    COALESCE(ProductCreditName, N'Chưa xác định') AS SanPhamTinDung,
    COUNT(LoanID) AS TongSoKhoanVay,
    SUM([Số_tiền_đăng_ký_vay_ban_đầu]) AS TongTienDKVay,
    SUM([Tiền_giải_ngân]) AS TongTienGiaiNgan,
    ROUND(SUM([Tiền_giải_ngân]) * 100.0 / NULLIF(SUM([Số_tiền_đăng_ký_vay_ban_đầu]), 0), 2) AS TyLeGiaiNgan_Pct,
    ROUND(AVG([Tiền_giải_ngân]), 0) AS GiaiNganTrungBinh
FROM tima_clean
GROUP BY ProductCreditName
ORDER BY TongTienGiaiNgan DESC;

--Danh sách các khoản vay có tỷ lệ giải ngân < 50% theo thành phố
SELECT 
    CityName,
    COUNT(LoanID) AS SoKhoanVay_Duoi50Pct,
    SUM([Số_tiền_đăng_ký_vay_ban_đầu]) AS TongDKVay,
    SUM([Tiền_giải_ngân]) AS TongGiaiNganThucTe,
    ROUND(AVG([Tiền_giải_ngân] * 100.0 / NULLIF([Số_tiền_đăng_ký_vay_ban_đầu], 0)), 2) AS TyLeGiaiNganTB_Pct
FROM tima_clean
WHERE ([Tiền_giải_ngân] * 1.0 / NULLIF([Số_tiền_đăng_ký_vay_ban_đầu], 0)) < 0.5
GROUP BY CityName
ORDER BY SoKhoanVay_Duoi50Pct DESC;

--Mức chênh lệch giữa tiền vay ban đầu và dư nợ gốc còn lại theo thời gian cư trú
SELECT 
    COALESCE([Thời_gian_đã_sống], N'Chưa xác định') AS ThoiGianCuTru,
    COUNT(LoanID) AS SoKhoanVay,
    SUM([Số_tiền_đăng_ký_vay_ban_đầu]) AS TongTienVayBanDau,
    SUM([Tiền_gốc_còn_lại]) AS TongDuNoConLai,
    SUM([Số_tiền_đăng_ký_vay_ban_đầu] - [Tiền_gốc_còn_lại]) AS TongTienDaThuHoi,
    ROUND(AVG([Số_tiền_đăng_ký_vay_ban_đầu] - [Tiền_gốc_còn_lại]), 0) AS ChenhLechThuHoiTB
FROM tima_clean
GROUP BY [Thời_gian_đã_sống]
ORDER BY TongTienDaThuHoi DESC;


--Khoản vay có tỷ lệ giải ngân cao nhất theo từng quận và giới tính
WITH RankedLoans AS (
    SELECT 
        DistrictName,
        Gender AS GioiTinh,
        LoanID,
        FullName,
        [Số_tiền_đăng_ký_vay_ban_đầu] AS SoTienDK,
        [Tiền_giải_ngân] AS SoTienGiaiNgan,
        ROUND([Tiền_giải_ngân] * 100.0 / NULLIF([Số_tiền_đăng_ký_vay_ban_đầu], 0), 2) AS TyLeGiaiNgan_Pct,
        ROW_NUMBER() OVER (
            PARTITION BY DistrictName, Gender 
            ORDER BY ([Tiền_giải_ngân] * 1.0 / NULLIF([Số_tiền_đăng_ký_vay_ban_đầu], 0)) DESC, [Tiền_giải_ngân] DESC
        ) AS RankNum
    FROM tima_clean
    WHERE DistrictName IS NOT NULL AND [Số_tiền_đăng_ký_vay_ban_đầu] > 0
)
SELECT DistrictName, GioiTinh, LoanID, FullName, SoTienDK, SoTienGiaiNgan, TyLeGiaiNgan_Pct
FROM RankedLoans
WHERE RankNum = 1
ORDER BY DistrictName;

--Tỷ lệ hoàn thành giải ngân theo nghề nghiệp và thành phố
SELECT 
    CityName,
    COALESCE(JobName, N'Chưa xác định') AS NgheNghiep,
    COUNT(LoanID) AS SoKhoanVay,
    SUM([Số_tiền_đăng_ký_vay_ban_đầu]) AS TongDKVay,
    SUM([Tiền_giải_ngân]) AS TongGiaiNgan,
    ROUND(SUM([Tiền_giải_ngân]) * 100.0 / NULLIF(SUM([Số_tiền_đăng_ký_vay_ban_đầu]), 0), 2) AS TyLeGiaiNgan_Pct
FROM tima_clean
GROUP BY CityName, JobName
HAVING COUNT(LoanID) >= 3
ORDER BY TyLeGiaiNgan_Pct DESC;