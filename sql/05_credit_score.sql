--Phân bố điểm tín dụng TS_CREDIT_SCORE_V2 theo nhóm thu nhập
WITH CTE AS (
    SELECT
        CASE
            WHEN Salary < 7000000 THEN N'Dưới 7 Triệu'
            WHEN Salary <= 15000000 THEN N'Từ 7 - 15 Triệu'
            WHEN Salary > 15000000 THEN N'Trên 15 Triệu'
            ELSE N'Chưa xác định'
        END AS NhomThuNhap,
        ID,
        TS_CREDIT_SCORE_V2
    FROM tima_clean
)
SELECT
    NhomThuNhap,
    COUNT(ID) AS SoLuongKhachHang,
    MIN(TS_CREDIT_SCORE_V2) AS DiemThapNhat,
    ROUND(AVG(TS_CREDIT_SCORE_V2), 1) AS DiemTrungBinh,
    MAX(TS_CREDIT_SCORE_V2) AS DiemCaoNhat
FROM CTE
GROUP BY NhomThuNhap
ORDER BY NhomThuNhap;

--Xu hướng quá hạn và nợ xấu theo phân tầng điểm tín dụng
WITH CTE AS (
    SELECT 
        CASE 
            WHEN TS_CREDIT_SCORE_V2 < 450 THEN N'< 450 (Rủi ro rất cao)'
            WHEN TS_CREDIT_SCORE_V2 < 550 THEN N'450 - 549 (Rủi ro trung bình)'
            WHEN TS_CREDIT_SCORE_V2 < 650 THEN N'550 - 649 (Khá tốt)'
            ELSE N'>= 650 (Rất tốt)'
        END AS NhomDiemTinDung,
        LoanID,
        LongestOverdue,
        [Trạng_thái]
    FROM tima_clean
)
SELECT 
    NhomDiemTinDung,
    COUNT(LoanID) AS TongSoKhoanVay,
    ROUND(AVG(LongestOverdue), 1) AS SoNgayQuaHanTB,
    SUM(CASE WHEN [Trạng_thái] = N'Nợ Xấu' THEN 1 ELSE 0 END) AS SoKhoanNoXau,
    ROUND(SUM(CASE WHEN [Trạng_thái] = N'Nợ Xấu' THEN 1 ELSE 0 END) * 100.0 / COUNT(LoanID), 2) AS TyLeNoXau_Pct
FROM CTE
GROUP BY NhomDiemTinDung
ORDER BY NhomDiemTinDung;

--Các yếu tố ảnh hưởng đến điểm tín dụng (Giới tính, Địa bàn, Mức lương)
SELECT 
    CityName,
    Gender AS GioiTinh,
    COUNT(LoanID) AS SoLuongHoSo,
    ROUND(AVG(TS_CREDIT_SCORE_V2), 1) AS DiemTinDungTB,
    ROUND(AVG(Salary), 0) AS LuongTrungBinh,
    ROUND(AVG(LongestOverdue), 1) AS SoNgayQuaHanTB
FROM tima_clean
WHERE CityName IS NOT NULL
GROUP BY CityName, Gender
HAVING COUNT(LoanID) >= 5
ORDER BY DiemTinDungTB DESC;

--So sánh tỷ lệ điểm tín dụng < 600 với nợ xấu CIC (HasBadDebt)
WITH CTE AS (
    SELECT 
        CASE 
            WHEN TS_CREDIT_SCORE_V2 < 600 THEN N'Điểm < 600 (Thấp)' 
            ELSE N'Điểm >= 600 (Cao)' 
        END AS PhanLoaiDiemNoiBo,
        CASE 
            WHEN HasBadDebt = 1 THEN N'Có nợ xấu CIC' 
            ELSE N'Không nợ xấu CIC' 
        END AS LichSuCIC,
        LoanID,
        [Trạng_thái]
    FROM tima_clean
)
SELECT 
    PhanLoaiDiemNoiBo,
    LichSuCIC,
    COUNT(LoanID) AS SoLuongHoSo,
    SUM(CASE WHEN [Trạng_thái] = N'Nợ Xấu' THEN 1 ELSE 0 END) AS SoKhoanNoXauTIMA,
    ROUND(SUM(CASE WHEN [Trạng_thái] = N'Nợ Xấu' THEN 1 ELSE 0 END) * 100.0 / COUNT(LoanID),2) AS TyLeNoXauTIMA_Pct
FROM CTE
GROUP BY 
    PhanLoaiDiemNoiBo,
    LichSuCIC

ORDER BY TyLeNoXauTIMA_Pct DESC;

--Điểm tín dụng trung bình theo trạng thái khoản vay và sản phẩm tín dụng
SELECT 
    COALESCE(ProductCreditName, 'Chưa xác định') AS SanPhamTinDung,
    [Trạng_thái] AS TrangThai,
    COUNT(LoanID) AS SoKhoanVay,
    ROUND(AVG(TS_CREDIT_SCORE_V2), 1) AS DiemTinDungTB,
    ROUND(AVG(LongestOverdue), 1) AS SoNgayQuaHanTB
FROM tima_clean
GROUP BY ProductCreditName, [Trạng_thái]
ORDER BY SanPhamTinDung, TrangThai;