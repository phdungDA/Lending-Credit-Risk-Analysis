--Tỷ lệ hoàn trả đúng hạn theo từng gói sản phẩm tín dụng
SELECT 
    COALESCE(ProductCreditName, N'Chưa xác định') AS SanPhamTinDung,
    COUNT(LoanID) AS TongSoKhoanVay,
    SUM(CASE WHEN [Trạng_thái] = N'Kết thúc' AND LongestOverdue = 0 THEN 1 ELSE 0 END) AS SoKhoanDungHanTuyetDoi,
    ROUND(SUM(CASE WHEN [Trạng_thái] = N'Kết thúc' AND LongestOverdue = 0 THEN 1 ELSE 0 END) * 100.0 / COUNT(LoanID), 2) AS TyLeDungHan_Pct,
    ROUND(AVG(LongestOverdue), 1) AS SoNgayQuaHanTB
FROM tima_clean
GROUP BY ProductCreditName
ORDER BY TyLeDungHan_Pct DESC;

--So sánh tỷ lệ nợ xấu của sản phẩm thế chấp phổ biến với các sản phẩm khác
SELECT 
    CASE 
        WHEN ProductCreditName LIKE N'%Điện thoại%' THEN 'Cầm cố Điện thoại'
        WHEN ProductCreditName LIKE N'%xe máy%' THEN 'Cầm cố Xe máy'
        WHEN ProductCreditName LIKE N'%sim%' OR ProductCreditName LIKE N'%Sim%' THEN N'Vay theo Sim'
        ELSE N'Sản phẩm khác'
    END AS NhomSanPham,
    COUNT(LoanID) AS TongSoKhoanVay,
    SUM([Tiền_giải_ngân]) AS TongTienGiaiNgan,
    SUM(CASE WHEN [Trạng_thái] = N'Nợ Xấu' THEN 1 ELSE 0 END) AS SoKhoanNoXau,
    ROUND(SUM(CASE WHEN [Trạng_thái] = N'Nợ Xấu' THEN 1 ELSE 0 END) * 100.0 / COUNT(LoanID), 2) AS TyLeNoXau_Pct
FROM tima_clean
GROUP BY
    CASE 
        WHEN ProductCreditName LIKE N'%Điện thoại%' THEN 'Cầm cố Điện thoại'
        WHEN ProductCreditName LIKE N'%xe máy%' THEN 'Cầm cố Xe máy'
        WHEN ProductCreditName LIKE N'%sim%' OR ProductCreditName LIKE N'%Sim%' THEN N'Vay theo Sim'
        ELSE N'Sản phẩm khác'
    END
ORDER BY TongTienGiaiNgan DESC;

--Tổng số tiền vay cho mỗi loại sản phẩm và so sánh với tỷ lệ giải ngân
SELECT 
    COALESCE(ProductCreditName, N'Chưa xác định') AS SanPham,
    SUM([Số_tiền_đăng_ký_vay_ban_đầu]) AS TongDKVay,
    SUM([Tiền_giải_ngân]) AS TongGiaiNgan,
    ROUND(SUM([Tiền_giải_ngân]) * 100.0 / NULLIF(SUM([Số_tiền_đăng_ký_vay_ban_đầu]), 0), 2) AS TyLeDuyetGiaiNgan_Pct,
    ROUND(SUM([Tiền_giải_ngân]) * 100.0 / (SELECT SUM([Tiền_giải_ngân]) FROM tima_clean), 2) AS TyTrongDongGopDoanhSo_Pct
FROM tima_clean
GROUP BY ProductCreditName
ORDER BY TongGiaiNgan DESC;

--Sản phẩm có số ngày quá hạn cao nhất và mối liên hệ với điểm tín dụng
SELECT 
    ProductCreditName,
    COUNT(LoanID) AS SoKhoanVay,
    ROUND(AVG(TS_CREDIT_SCORE_V2), 1) AS DiemTinDungTB,
    ROUND(AVG(LongestOverdue), 1) AS SoNgayQuaHanTB,
    MAX(LongestOverdue) AS SoNgayQuaHanMax
FROM tima_clean
WHERE ProductCreditName IS NOT NULL
GROUP BY ProductCreditName
ORDER BY SoNgayQuaHanTB DESC;

--Tình trạng nợ xấu của từng sản phẩm theo từng thành phố
SELECT 
    CityName,
    ProductCreditName,
    COUNT(LoanID) AS TongSoKhoanVay,
    SUM(CASE WHEN [Trạng_thái] = N'Nợ Xấu' THEN 1 ELSE 0 END) AS SoKhoanNoXau,
    ROUND(SUM(CASE WHEN [Trạng_thái] = N'Nợ Xấu' THEN 1 ELSE 0 END) * 100.0 / COUNT(LoanID), 2) AS TyLeNoXau_Pct
FROM tima_clean
WHERE CityName IS NOT NULL AND ProductCreditName IS NOT NULL
GROUP BY CityName, ProductCreditName
HAVING COUNT(LoanID) >= 3
ORDER BY CityName, TyLeNoXau_Pct DESC;