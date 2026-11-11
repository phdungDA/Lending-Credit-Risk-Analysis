--Phân tích các quận có tỷ lệ nợ xấu cao nhất
SELECT 
    CityName,
    DistrictName,
    COUNT(LoanID) AS TongSoKhoanVay,
    SUM([Tiền_giải_ngân]) AS TongGiaiNgan,
    SUM(CASE WHEN [Trạng_thái] = N'Nợ Xấu' THEN 1 ELSE 0 END) AS SoKhoanNoXau,
    ROUND(SUM(CASE WHEN [Trạng_thái] = N'Nợ Xấu' THEN 1 ELSE 0 END) * 100.0 / COUNT(LoanID), 2) AS TyLeNoXau_Pct,
    ROUND(AVG(TS_CREDIT_SCORE_V2), 1) AS DiemTinDungTB
FROM tima_clean
WHERE DistrictName IS NOT NULL
GROUP BY CityName, DistrictName
HAVING COUNT(LoanID) >= 10
ORDER BY TyLeNoXau_Pct DESC;

--Hiệu suất giải ngân theo từng quận tại Hà Nội
SELECT 
    DistrictName AS QuanHuyen,
    COUNT(LoanID) AS SoKhoanVay,
    SUM([Số_tiền_đăng_ký_vay_ban_đầu]) AS TongDKVay,
    SUM([Tiền_giải_ngân]) AS TongGiaiNgan,
    ROUND(SUM([Tiền_giải_ngân]) * 100.0 / NULLIF(SUM([Số_tiền_đăng_ký_vay_ban_đầu]), 0), 2) AS TyLeGiaiNgan_Pct,
    ROUND(SUM([Tiền_giải_ngân]) * 100.0 / (SELECT SUM([Tiền_giải_ngân]) FROM tima_clean WHERE CityName = N'Hà Nội'), 2) AS TyTrongDongGop_Pct
FROM tima_clean
WHERE CityName = N'Hà Nội' AND DistrictName IS NOT NULL
GROUP BY DistrictName
ORDER BY TongGiaiNgan DESC;

--Tỷ lệ trả nợ đúng hạn tại các phường hộ khẩu tập trung
SELECT 
    DistrictNameHouseHold AS QuanHoKhau,
    WardNameHouseHold AS PhuongHoKhau,
    COUNT(LoanID) AS SoKhoanVay,
    SUM(CASE WHEN [Trạng_thái] = N'Kết thúc' AND LongestOverdue = 0 THEN 1 ELSE 0 END) AS SoKhoanDungHanTuyetDoi,
    ROUND(SUM(CASE WHEN [Trạng_thái] = N'Kết thúc' AND LongestOverdue = 0 THEN 1 ELSE 0 END) * 100.0 / COUNT(LoanID), 2) AS TyLeDungHan_Pct
FROM tima_clean
WHERE WardNameHouseHold IS NOT NULL
GROUP BY DistrictNameHouseHold, WardNameHouseHold
HAVING COUNT(LoanID) >= 3
ORDER BY TyLeDungHan_Pct DESC;

--Quy mô giải ngân và phân bổ khách hàng theo các tỉnh thành
SELECT 
    COALESCE(CityName, N'Chưa xác định') AS TinhThanhPho,
    COUNT(DISTINCT CardNumber) AS SoKhachHang,
    COUNT(LoanID) AS TongSoKhoanVay,
    SUM([Tiền_giải_ngân]) AS TongTienGiaiNgan,
    ROUND(AVG([Tiền_giải_ngân]), 0) AS GiaTriVayTB,
    ROUND(AVG(TS_CREDIT_SCORE_V2), 1) AS DiemTinDungTB
FROM tima_clean
GROUP BY CityName
ORDER BY TongTienGiaiNgan DESC;

--Tỷ lệ có lịch sử chậm thanh toán CIC (HasLatePayment) theo địa bàn
SELECT 
    CityName,
    COUNT(LoanID) AS SoKhoanVay,
    SUM(HasLatePayment) AS SoKhoanChamTraCIC,
    ROUND(SUM(HasLatePayment) * 100.0 / COUNT(LoanID), 2) AS TyLeChamTraCIC_Pct,
    ROUND(AVG(LongestOverdue), 1) AS SoNgayQuaHanTB
FROM tima_clean
WHERE CityName IS NOT NULL
GROUP BY CityName
ORDER BY SoKhoanVay DESC;