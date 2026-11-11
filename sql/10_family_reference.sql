--Tác động của mối quan hệ người thân tham chiếu (RelativeFamilyName) đến nợ xấu
SELECT 
    COALESCE(RelativeFamilyName, N'Chưa khai báo') AS NguoiThamChieu,
    COUNT(LoanID) AS SoKhoanVay,
    SUM(CASE WHEN [Trạng_thái] = N'Nợ Xấu' THEN 1 ELSE 0 END) AS SoKhoanNoXau,
    ROUND(SUM(CASE WHEN [Trạng_thái] = N'Nợ Xấu' THEN 1 ELSE 0 END) * 100.0 / COUNT(LoanID), 2) AS TyLeNoXau_Pct,
    ROUND(AVG(LongestOverdue), 1) AS SoNgayQuaHanTB
FROM tima_clean
GROUP BY RelativeFamilyName
ORDER BY TyLeNoXau_Pct DESC;

--Khách hàng có người thân cùng đứng tên vay tại TIMA
SELECT 
    a.LoanID AS LoanID_KhachHang,
    a.FullName AS TenKhachHang,
    a.FullNameFamily AS TenNguoiThan,
    b.LoanID AS LoanID_NguoiThanVay,
    b.FullName AS TenNguoiThanDungTenVay,
    a.[Trạng_thái] AS TrangThai_KhachHang,
    b.[Trạng_thái] AS TrangThai_NguoiThan
FROM tima_clean a
INNER JOIN tima_clean b ON LOWER(TRIM(a.FullNameFamily)) = LOWER(TRIM(b.FullName))
WHERE a.LoanID <> b.LoanID;

--Đánh giá nhóm khách hàng có người tham chiếu là cấp quản lý/giám đốc
SELECT 
    CASE 
        WHEN DescriptionPositionJob LIKE N'%giám đốc%' OR DescriptionPositionJob LIKE N'%quản lý%' OR DescriptionPositionJob LIKE N'%chủ%' THEN N'Người vay/tham chiếu cấp Quản lý/Chủ DN'
        ELSE N'Nhân viên/Khác'
    END AS NhomChucVu,
    COUNT(LoanID) AS SoKhoanVay,
    ROUND(AVG(TS_CREDIT_SCORE_V2), 1) AS DiemTinDungTB,
    SUM(CASE WHEN [Trạng_thái] = N'Nợ Xấu' THEN 1 ELSE 0 END) AS SoKhoanNoXau,
    ROUND(SUM(CASE WHEN [Trạng_thái] = N'Nợ Xấu' THEN 1 ELSE 0 END) * 100.0 / COUNT(LoanID), 2) AS TyLeNoXau_Pct
FROM tima_clean
GROUP BY 
    CASE 
        WHEN DescriptionPositionJob LIKE N'%giám đốc%' OR DescriptionPositionJob LIKE N'%quản lý%' OR DescriptionPositionJob LIKE N'%chủ%' THEN N'Người vay/tham chiếu cấp Quản lý/Chủ DN'
        ELSE N'Nhân viên/Khác'
    END;

--Đánh giá mức độ tín nhiệm theo người tham chiếu và điểm tín dụng
SELECT 
    RelativeFamilyName,
    COUNT(LoanID) AS SoLuongHoSo,
    ROUND(AVG(TS_CREDIT_SCORE_V2), 1) AS DiemTinDungTB,
    ROUND(AVG([Tiền_giải_ngân]), 0) AS HanMucGiaiNganTB
FROM tima_clean
WHERE RelativeFamilyName IS NOT NULL
GROUP BY RelativeFamilyName
ORDER BY DiemTinDungTB DESC;

--Người thân sống cùng khu vực địa chỉ hộ khẩu (CityNameHouseHold)
SELECT 
    CASE 
        WHEN CityName = CityNameHouseHold THEN N'Cư trú trùng tỉnh Hộ khẩu'
        ELSE N'Cư trú khác tỉnh Hộ khẩu (Ngoại tỉnh)'
    END AS TinhTrangCuTruHoKhau,
    COUNT(LoanID) AS SoKhoanVay,
    SUM(CASE WHEN [Trạng_thái] = N'Kết thúc' THEN 1 ELSE 0 END) AS SoKhoanTatToanTot,
    ROUND(SUM(CASE WHEN [Trạng_thái] = N'Kết thúc' THEN 1 ELSE 0 END) * 100.0 / COUNT(LoanID), 2) AS TyLeTatToanTot_Pct,
    SUM(CASE WHEN [Trạng_thái] = N'Nợ Xấu' THEN 1 ELSE 0 END) AS SoKhoanNoXau,
    ROUND(SUM(CASE WHEN [Trạng_thái] = N'Nợ Xấu' THEN 1 ELSE 0 END) * 100.0 / COUNT(LoanID), 2) AS TyLeNoXau_Pct
FROM tima_clean
GROUP BY 
    CASE 
        WHEN CityName = CityNameHouseHold THEN N'Cư trú trùng tỉnh Hộ khẩu'
        ELSE N'Cư trú khác tỉnh Hộ khẩu (Ngoại tỉnh)'
    END;
