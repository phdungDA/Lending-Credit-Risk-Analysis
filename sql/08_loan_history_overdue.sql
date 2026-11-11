--Phân tích các khoản vay quá hạn từ 3 đến 6 tháng (90 đến 180 ngày)
SELECT 
    CityName,
    DistrictName,
    JobName,
    Salary,
    ProductCreditName,
    [Tiền_giải_ngân] AS SoTienGiaiNgan,
    [Tiền_gốc_còn_lại] AS DuNoConLai,
    LongestOverdue AS SoNgayQuaHan
FROM tima_clean
WHERE LongestOverdue BETWEEN 90 AND 180
ORDER BY LongestOverdue DESC;

--Tỷ lệ quá hạn của khách hàng từng vay nhiều lần (NumberOfLoans) so với lần đầu
SELECT 
    CASE 
        WHEN NumberOfLoans IS NULL OR NumberOfLoans <= 0 THEN N'Chưa từng vay TCTD khác (0 hoặc Chưa rõ)'
        WHEN NumberOfLoans = 1 THEN N'Đang vay 1 TCTD'
        WHEN NumberOfLoans BETWEEN 2 AND 3 THEN N'Đang vay 2 - 3 TCTD'
        ELSE N'Đang vay > 3 TCTD (Rủi ro cao)'
    END AS SoLuongTCTDDangVay,
    COUNT(LoanID) AS SoKhoanVay,
    ROUND(AVG(LongestOverdue), 1) AS SoNgayQuaHanTB,
    SUM(CASE WHEN [Trạng_thái] = N'Nợ Xấu' THEN 1 ELSE 0 END) AS SoKhoanNoXau,
    ROUND(SUM(CASE WHEN [Trạng_thái] = N'Nợ Xấu' THEN 1 ELSE 0 END) * 100.0 / COUNT(LoanID), 2) AS TyLeNoXau_Pct
FROM tima_clean
GROUP BY
    CASE 
        WHEN NumberOfLoans IS NULL OR NumberOfLoans <= 0 THEN N'Chưa từng vay TCTD khác (0 hoặc Chưa rõ)'
        WHEN NumberOfLoans = 1 THEN N'Đang vay 1 TCTD'
        WHEN NumberOfLoans BETWEEN 2 AND 3 THEN N'Đang vay 2 - 3 TCTD'
        ELSE N'Đang vay > 3 TCTD (Rủi ro cao)'
    END
ORDER BY TyLeNoXau_Pct DESC;

--Các khoản vay quá hạn trên 6 tháng (> 180 ngày - nợ mất vốn)
SELECT 
    ProductCreditName,
    COUNT(LoanID) AS SoKhoanVayMatVon,
    SUM([Tiền_gốc_còn_lại]) AS TongDuNoTonThatDuKien,
    ROUND(AVG(TS_CREDIT_SCORE_V2), 1) AS DiemTinDungTB
FROM tima_clean
WHERE LongestOverdue > 180
GROUP BY ProductCreditName
ORDER BY TongDuNoTonThatDuKien DESC;

--Top khách hàng có số ngày quá hạn dài nhất hệ thống
SELECT TOP 10
    LoanID,
    FullName,
    JobName,
    Salary,
    CityName,
    ProductCreditName,
    [Tiền_giải_ngân] AS TienGiaiNgan,
    [Tiền_gốc_còn_lại] AS DuNoConLai,
    TS_CREDIT_SCORE_V2,
    LongestOverdue AS SoNgayQuaHan
FROM tima_clean
ORDER BY LongestOverdue DESC;

--Mức độ quá hạn theo quy mô gói tiền giải ngân
SELECT 
    CASE 
        WHEN [Tiền_giải_ngân] < 5000000 THEN 'Dưới 5 Triệu'
        WHEN [Tiền_giải_ngân] <= 10000000 THEN N'Từ 5 - 10 Triệu'
        WHEN [Tiền_giải_ngân] <= 20000000 THEN N'Từ 10 - 20 Triệu'
        ELSE N'Trên 20 Triệu'
    END AS QuyMoKhoanVay,
    COUNT(LoanID) AS SoKhoanVay,
    SUM([Tiền_giải_ngân]) AS TongTienGiaiNgan,
    ROUND(AVG(LongestOverdue), 1) AS SoNgayQuaHanTB,
    SUM(CASE WHEN [Trạng_thái] = N'Nợ Xấu' THEN 1 ELSE 0 END) AS SoKhoanNoXau,
    ROUND(SUM(CASE WHEN [Trạng_thái] = N'Nợ Xấu' THEN 1 ELSE 0 END) * 100.0 / COUNT(LoanID), 2) AS TyLeNoXau_Pct
FROM tima_clean
WHERE [Tiền_giải_ngân] > 0
GROUP BY
    CASE 
        WHEN [Tiền_giải_ngân] < 5000000 THEN 'Dưới 5 Triệu'
        WHEN [Tiền_giải_ngân] <= 10000000 THEN N'Từ 5 - 10 Triệu'
        WHEN [Tiền_giải_ngân] <= 20000000 THEN N'Từ 10 - 20 Triệu'
        ELSE N'Trên 20 Triệu'
    END
ORDER BY QuyMoKhoanVay;