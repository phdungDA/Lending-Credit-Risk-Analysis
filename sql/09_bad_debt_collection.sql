--Danh mục các khoản vay nợ xấu theo sản phẩm và thành phố
SELECT 
    CityName,
    COALESCE(ProductCreditName, N'Chưa xác định') AS SanPhamTinDung,
    COUNT(LoanID) AS SoKhoanNoXau,
    SUM([Tiền_gốc_còn_lại]) AS TongDuNoXauConLai,
    ROUND(AVG(TS_CREDIT_SCORE_V2), 1) AS DiemTinDungTB
FROM tima_clean
WHERE [Trạng_thái] = N'Nợ Xấu' OR HasBadDebt = 1
GROUP BY CityName, ProductCreditName
ORDER BY TongDuNoXauConLai DESC;

--Chân dung nhóm khách hàng sạch nợ và các yếu tố thúc đẩy
SELECT 
    CASE 
        WHEN Salary >= 10000000 THEN N'Lương >= 10 Tr'
        ELSE N'Lương < 10 Tr/Khác'
    END AS MucLuong,
    CASE 
        WHEN [Hình_thức_cư_trú] IN (N'Sở hữu cá nhân', N'Đồng sở hữu', N'Nhà sở hữu') THEN N'Có nhà sở hữu'
        ELSE N'Thuê/Ở nhờ/Khác'
    END AS TinhTrangNhaO,
    COUNT(LoanID) AS TongSoKhoan,
    SUM(CASE WHEN [Trạng_thái] = N'Kết thúc' AND HasBadDebt = 0 AND HasLatePayment = 0 AND LongestOverdue = 0 THEN 1 ELSE 0 END) AS SoKhoanHoanHao,
    ROUND(SUM(CASE WHEN [Trạng_thái] = N'Kết thúc' AND HasBadDebt = 0 AND HasLatePayment = 0 AND LongestOverdue = 0 THEN 1 ELSE 0 END) * 100.0 / COUNT(LoanID), 2) AS TyLeKhachHangHoanHao_Pct
FROM tima_clean
GROUP BY 
    CASE 
        WHEN Salary >= 10000000 THEN N'Lương >= 10 Tr'
        ELSE N'Lương < 10 Tr/Khác'
    END, 
    CASE 
        WHEN [Hình_thức_cư_trú] IN (N'Sở hữu cá nhân', N'Đồng sở hữu', N'Nhà sở hữu') THEN N'Có nhà sở hữu'
        ELSE N'Thuê/Ở nhờ/Khác'
    END
ORDER BY TyLeKhachHangHoanHao_Pct DESC;

--Nhóm khách hàng chậm thanh toán CIC (HasLatePayment = 1) theo giới tính và nghề nghiệp
SELECT 
    Gender AS GioiTinh,
    COALESCE(JobName, N'Chưa xác định') AS NgheNghiep,
    COUNT(LoanID) AS TongSoKhoanVay,
    SUM(HasLatePayment) AS SoKhoanChamTraCIC,
    ROUND(SUM(HasLatePayment) * 100.0 / COUNT(LoanID), 2) AS TyLeChamTraCIC_Pct,
    SUM(CASE WHEN [Trạng_thái] = N'Nợ Xấu' THEN 1 ELSE 0 END) AS SoKhoanNoXauThucTe
FROM tima_clean
GROUP BY Gender, JobName
HAVING COUNT(LoanID) >= 5
ORDER BY TyLeChamTraCIC_Pct DESC;

--Bảng tổng hợp rủi ro nợ xấu và quá hạn theo quận trọng điểm
SELECT 
    DistrictName,
    COUNT(LoanID) AS TongSoKhoanVay,
    SUM([Tiền_giải_ngân]) AS TongTienGiaiNgan,
    SUM(CASE WHEN [Trạng_thái] = N'Nợ Xấu' THEN 1 ELSE 0 END) AS SoKhoanNoXau,
    ROUND(SUM(CASE WHEN [Trạng_thái] = N'Nợ Xấu' THEN 1 ELSE 0 END) * 100.0 / COUNT(LoanID), 2) AS TyLeNoXau_Pct,
    ROUND(AVG(LongestOverdue), 1) AS SoNgayQuaHanTB,
    ROUND(AVG(TS_CREDIT_SCORE_V2), 1) AS DiemTinDungTB
FROM tima_clean
WHERE CityName = N'Hà Nội' AND DistrictName IS NOT NULL
GROUP BY DistrictName
HAVING COUNT(LoanID) >= 10
ORDER BY TyLeNoXau_Pct DESC, SoNgayQuaHanTB DESC;

--Phân tích nợ xấu theo nhóm tuổi khách hàng
WITH CustomerAgeGroup AS (
    SELECT 
        LoanID,
        [Trạng_thái] AS TrangThai,
        LongestOverdue,
        DATEDIFF(YEAR, TRY_CAST(Birthday AS DATE), '2019-01-01') AS Tuoi
    FROM tima_clean
    WHERE Birthday IS NOT NULL
      AND TRY_CAST(Birthday AS DATE) IS NOT NULL
)
SELECT 
    CASE 
        WHEN Tuoi < 25 THEN N'Dưới 25 tuổi (Trẻ)'
        WHEN Tuoi BETWEEN 25 AND 35 THEN N'25 - 35 tuổi (Độ tuổi lao động chính)'
        WHEN Tuoi BETWEEN 36 AND 45 THEN N'36 - 45 tuổi (Trung niên)'
        ELSE N'Trên 45 tuổi'
    END AS NhomTuoi,
    COUNT(LoanID) AS TongSoKhoanVay,
    SUM(CASE WHEN TrangThai = N'Nợ Xấu' THEN 1 ELSE 0 END) AS SoKhoanNoXau,
    ROUND(SUM(CASE WHEN TrangThai = N'Nợ Xấu' THEN 1 ELSE 0 END) * 100.0 / COUNT(LoanID), 2) AS TyLeNoXau_Pct,
    ROUND(AVG(CAST(LongestOverdue AS FLOAT)), 1) AS SoNgayQuaHanTB
FROM CustomerAgeGroup
GROUP BY 
    CASE 
        WHEN Tuoi < 25 THEN N'Dưới 25 tuổi (Trẻ)'
        WHEN Tuoi BETWEEN 25 AND 35 THEN N'25 - 35 tuổi (Độ tuổi lao động chính)'
        WHEN Tuoi BETWEEN 36 AND 45 THEN N'36 - 45 tuổi (Trung niên)'
        ELSE N'Trên 45 tuổi'
    END
ORDER BY NhomTuoi;