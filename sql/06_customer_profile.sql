--Độ tuổi trung bình của khách hàng vay tiền theo khu vực
SELECT
    CityName,
    DistrictName,
    COUNT(LoanID) AS SoLuongKhoanVay,
    ROUND(AVG(CAST(DATEDIFF(YEAR, Birthday, '2019-01-01') AS FLOAT)), 1) AS DoTuoiTrungBinh
FROM tima_clean
WHERE Birthday IS NOT NULL
GROUP BY CityName, DistrictName
HAVING COUNT(LoanID) >= 5
ORDER BY DoTuoiTrungBinh ASC;

--Danh sách khách hàng vay nhiều lần (trùng số điện thoại) và tổng tiền giải ngân
SELECT 
    [Số_điện_thoại_khách_hàng] AS SoDienThoai,
    FullName,
    COUNT(LoanID) AS SoLanVay,
    SUM([Tiền_giải_ngân]) AS TongTienGiaiNgan,
    SUM(CASE WHEN [Trạng_thái] = N'Nợ Xấu' THEN 1 ELSE 0 END) AS SoKhoanNoXau,
    MAX(LongestOverdue) AS SoNgayQuaHanCaoNhat
FROM tima_clean
WHERE [Số_điện_thoại_khách_hàng] IS NOT NULL AND [Số_điện_thoại_khách_hàng] NOT LIKE '%abc%'
GROUP BY [Số_điện_thoại_khách_hàng], FullName
HAVING COUNT(LoanID) > 1
ORDER BY SoLanVay DESC, TongTienGiaiNgan DESC;

--Số lượng khách hàng theo giới tính và phân tích theo tỷ lệ nợ xấu (HasBadDebt)
SELECT 
    Gender AS GioiTinh,
    COUNT(DISTINCT CardNumber) AS SoKhachHang,
    COUNT(LoanID) AS TongSoKhoanVay,
    SUM(HasBadDebt) AS SoKhoanNoXauCIC,
    ROUND(SUM(HasBadDebt) * 100.0 / COUNT(LoanID), 2) AS TyLeNoXauCIC_Pct,
    SUM(CASE WHEN [Trạng_thái] = N'Nợ Xấu' THEN 1 ELSE 0 END) AS SoKhoanNoXauTIMA,
    ROUND(SUM(CASE WHEN [Trạng_thái] = N'Nợ Xấu' THEN 1 ELSE 0 END) * 100.0 / COUNT(LoanID), 2) AS TyLeNoXauTIMA_Pct
FROM tima_clean
GROUP BY Gender;

--Đánh giá tính ổn định cư trú tác động đến tỷ lệ nợ xấu
SELECT 
    COALESCE([Hình_thức_cư_trú], N'Chưa xác định') AS HinhThucCuTru,
    COALESCE([Thời_gian_đã_sống], N'Chưa xác định') AS ThoiGianCuTru,
    COUNT(LoanID) AS SoKhoanVay,
    SUM(CASE WHEN [Trạng_thái] = N'Nợ Xấu' THEN 1 ELSE 0 END) AS SoKhoanNoXau,
    ROUND(SUM(CASE WHEN [Trạng_thái] = N'Nợ Xấu' THEN 1 ELSE 0 END) * 100.0 / COUNT(LoanID), 2) AS TyLeNoXau_Pct,
    ROUND(AVG(LongestOverdue), 1) AS SoNgayQuaHanTB
FROM tima_clean
GROUP BY [Hình_thức_cư_trú] , [Thời_gian_đã_sống]
HAVING COUNT(LoanID) >= 3
ORDER BY TyLeNoXau_Pct DESC;

--Phát hiện các cụm khách hàng trùng lặp địa chỉ (Street & Ward)
SELECT 
    DistrictName,
    Street,
    COUNT(DISTINCT CardNumber) AS SoKhachHangKhacNhau,
    COUNT(LoanID) AS TongSoKhoanVay,
    SUM([Tiền_giải_ngân]) AS TongTienGiaiNgan,
    SUM(CASE WHEN [Trạng_thái] = N'Nợ Xấu' THEN 1 ELSE 0 END) AS SoKhoanNoXau
FROM tima_clean
WHERE Street IS NOT NULL AND LEN(Street) > 5
GROUP BY DistrictName, Street
HAVING COUNT(DISTINCT CardNumber) > 1
ORDER BY SoKhachHangKhacNhau DESC;