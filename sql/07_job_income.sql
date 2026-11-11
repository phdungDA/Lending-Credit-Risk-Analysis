--Tỷ lệ nợ xấu ở nhóm khách hàng có thu nhập < 10 triệu đồngSELECT 
SELECT 
    CASE
        WHEN Salary < 10000000 THEN N'Thu nhập < 10 Triệu'
        WHEN Salary >= 10000000 THEN N'Thu nhập >= 10 Triệu'
        ELSE N'Chưa xác định'
    END AS NhomThuNhap,
    COUNT(LoanID) AS SoKhoanVay,
    SUM(HasBadDebt) AS SoKhoanNoXauCIC,
    ROUND(SUM(HasBadDebt) * 100.0 / COUNT(LoanID),2) AS TyLeNoXauCIC_Pct,
    SUM(CASE WHEN [Trạng_thái] = N'Nợ Xấu' THEN 1 ELSE 0 END) AS SoKhoanNoXauTIMA,
    ROUND(SUM(CASE WHEN [Trạng_thái] = N'Nợ Xấu' THEN 1 ELSE 0 END) * 100.0 / COUNT(LoanID),2) AS TyLeNoXauTIMA_Pct,
    ROUND(AVG(LongestOverdue), 1) AS SoNgayQuaHanTB
FROM tima_clean
GROUP BY
    CASE
        WHEN Salary < 10000000 THEN N'Thu nhập < 10 Triệu'
        WHEN Salary >= 10000000 THEN N'Thu nhập >= 10 Triệu'
        ELSE N'Chưa xác định'
    END;

--Mối quan hệ giữa ngành nghề và số ngày quá hạn thanh toán (LongestOverdue)
SELECT 
    COALESCE(JobName, N'Chưa xác định') AS NgheNghiep,
    COUNT(LoanID) AS TongSoKhoanVay,
    ROUND(AVG(LongestOverdue), 1) AS SoNgayQuaHanTB,
    MAX(LongestOverdue) AS SoNgayQuaHanMax,
    SUM(CASE WHEN [Trạng_thái] = N'Nợ Xấu' THEN 1 ELSE 0 END) AS SoKhoanNoXau,
    ROUND(SUM(CASE WHEN [Trạng_thái] = N'Nợ Xấu' THEN 1 ELSE 0 END) * 100.0 / COUNT(LoanID), 2) AS TyLeNoXau_Pct
FROM tima_clean
GROUP BY JobName
HAVING COUNT(LoanID) >= 3
ORDER BY SoNgayQuaHanTB DESC;

--Tổng số tiền vay theo nhóm ngành nghề và phân khúc thu nhập
SELECT 
    COALESCE(JobName, N'Khác') AS NgheNghiep,
    SUM(CASE WHEN Salary < 10000000 THEN [Tiền_giải_ngân] ELSE 0 END) AS GiaiNgan_Duoi10Tr,
    SUM(CASE WHEN Salary >= 10000000 THEN [Tiền_giải_ngân] ELSE 0 END) AS GiaiNgan_Tren10Tr,
    SUM([Tiền_giải_ngân]) AS TongTienGiaiNgan
FROM tima_clean
GROUP BY JobName
HAVING COUNT(LoanID) >= 5
ORDER BY TongTienGiaiNgan DESC;

--Ảnh hưởng của địa bàn công ty khách hàng đến khả năng trả nợ
SELECT 
    DistrictNameCompany AS QuanCongTy,
    COUNT(LoanID) AS SoKhoanVay,
    SUM([Tiền_giải_ngân]) AS TongGiaiNgan,
    SUM(CASE WHEN [Trạng_thái] = N'Nợ Xấu' THEN 1 ELSE 0 END) AS SoKhoanNoXau,
    ROUND(SUM(CASE WHEN [Trạng_thái] = N'Nợ Xấu' THEN 1 ELSE 0 END) * 100.0 / COUNT(LoanID), 2) AS TyLeNoXau_Pct
FROM tima_clean
WHERE DistrictNameCompany IS NOT NULL AND DistrictNameCompany <> 'Unknown'
GROUP BY DistrictNameCompany
HAVING COUNT(LoanID) >= 5
ORDER BY TyLeNoXau_Pct DESC;

--Nhận diện các nhóm thu nhập có nguy cơ nợ xấu cao nhất
SELECT 
    CASE 
        WHEN Salary < 5000000 THEN N'Dưới 5 Triệu'
        WHEN Salary <= 8000000 THEN N'Từ 5 - 8 Triệu'
        WHEN Salary <= 12000000 THEN N'Từ 8 - 12 Triệu'
        WHEN Salary <= 20000000 THEN N'Từ 12 - 20 Triệu'
        WHEN Salary > 20000000 THEN N'Trên 20 Triệu'
        ELSE N'Không xác định'
    END AS DaiThuNhap,
    COUNT(LoanID) AS SoKhoanVay,
    SUM(CASE WHEN [Trạng_thái] = N'Nợ Xấu' THEN 1 ELSE 0 END) AS SoKhoanNoXau,
    ROUND(SUM(CASE WHEN [Trạng_thái] = N'Nợ Xấu' THEN 1 ELSE 0 END) * 100.0 / COUNT(LoanID), 2) AS TyLeNoXau_Pct,
    ROUND(AVG(TS_CREDIT_SCORE_V2), 1) AS DiemTinDungTB
FROM tima_clean
GROUP BY CASE 
        WHEN Salary < 5000000 THEN N'Dưới 5 Triệu'
        WHEN Salary <= 8000000 THEN N'Từ 5 - 8 Triệu'
        WHEN Salary <= 12000000 THEN N'Từ 8 - 12 Triệu'
        WHEN Salary <= 20000000 THEN N'Từ 12 - 20 Triệu'
        WHEN Salary > 20000000 THEN N'Trên 20 Triệu'
        ELSE N'Không xác định'
    END
ORDER BY DaiThuNhap;

--