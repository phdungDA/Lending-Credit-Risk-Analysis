--Tỷ lệ phần trăm các khoản vay đã tất toán (Kết thúc) theo khu vực địa lý
SELECT 
    CityName,
    DistrictName,
    COUNT(LoanID) AS TongSoKhoanVay,
    SUM(CASE WHEN [Trạng_thái] = N'Kết thúc' THEN 1 ELSE 0 END) AS SoKhoanTraHet,
    ROUND(SUM(CASE WHEN [Trạng_thái] = N'Kết thúc' THEN 1 ELSE 0 END) * 100.0 / COUNT(LoanID), 2) AS TyLeTraHet_Pct
FROM tima_clean
WHERE DistrictName IS NOT NULL
GROUP BY CityName, DistrictName
HAVING COUNT(LoanID) >= 5
ORDER BY TyLeTraHet_Pct DESC;

--Phân tích trạng thái khoản vay theo nhóm thu nhập và loại công việc
WITH IncomeGrouped AS (
    SELECT 
        LoanID,
        COALESCE(JobName, 'Unknown') AS NgheNghiep,
        [Trạng_thái] AS TrangThai,
        CASE 
            WHEN Salary < 7000000 THEN N'Dưới 7 Triệu'
            WHEN Salary <= 15000000 THEN N'Từ 7 - 15 Triệu'
            WHEN Salary > 15000000 THEN N'Trên 15 Triệu'
            ELSE N'Chưa xác định'
        END AS PhanKhucThuNhap
    FROM tima_clean
)
SELECT 
    NgheNghiep,
    PhanKhucThuNhap,
    COUNT(LoanID) AS TongSoKhoan,
    SUM(CASE WHEN TrangThai = N'Kết thúc' THEN 1 ELSE 0 END) AS SoKhoanKetThuc,
    SUM(CASE WHEN TrangThai = N'Nợ Xấu' THEN 1 ELSE 0 END) AS SoKhoanNoXau,
    ROUND(SUM(CASE WHEN TrangThai = N'Nợ Xấu' THEN 1 ELSE 0 END) * 100.0 / COUNT(LoanID), 2) AS TyLeNoXau_Pct
FROM IncomeGrouped
GROUP BY NgheNghiep, PhanKhucThuNhap
HAVING COUNT(LoanID) >= 3
ORDER BY TyLeNoXau_Pct DESC;

--Tỷ lệ khoản vay quá hạn / nợ xấu theo sản phẩm tín dụng
SELECT 
    COALESCE(ProductCreditName, N'Chưa xác định') AS SanPhamTinDung,
    COUNT(LoanID) AS TongSoKhoanVay,
    SUM(CASE WHEN [Trạng_thái] = N'Nợ Xấu' OR LongestOverdue > 90 THEN 1 ELSE 0 END) AS SoKhoanNoXau,
    ROUND(SUM(CASE WHEN [Trạng_thái] = N'Nợ Xấu' OR LongestOverdue > 90 THEN 1 ELSE 0 END) * 100.0 / COUNT(LoanID), 2) AS TyLeNoXau_Pct,
    ROUND(AVG(LongestOverdue), 1) AS SoNgayQuaHanTB
FROM tima_clean
GROUP BY ProductCreditName
ORDER BY TyLeNoXau_Pct DESC;

--Hiển thị các khoản vay chưa giải ngân liên quan đến mức lương và tiền đăng ký
SELECT 
    LoanID,
    FullName,
    CityName,
    JobName,
    Salary,
    [Số_tiền_đăng_ký_vay_ban_đầu] AS SoTienDKVay,
    TS_CREDIT_SCORE_V2,
    Brieft,
    HasBadDebt
FROM tima_clean
WHERE [Tiền_giải_ngân] IS NULL OR [Tiền_giải_ngân] = 0 OR [Trạng_thái] = N'Chưa giải ngân';

--Phân tích các khoản vay "Đang vay" theo hình thức trả lãi
SELECT 
    COALESCE(InterestPaymentType, N'Chưa xác định') AS HinhThucDongLai,
    COUNT(LoanID) AS SoKhoanDangVay,
    SUM([Tiền_giải_ngân]) AS TongTienGiaiNgan,
    SUM([Tiền_gốc_còn_lại]) AS TongDuNoConLai,
    ROUND(AVG(LongestOverdue), 1) AS SoNgayQuaHanTB
FROM tima_clean
WHERE [Trạng_thái] LIKE N'Đang%'
GROUP BY InterestPaymentType
ORDER BY TongDuNoConLai DESC;