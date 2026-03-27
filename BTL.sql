-- =========================================================================
-- ĐỒ ÁN CƠ SỞ DỮ LIỆU: QUẢN LÝ BÃI GỬI XE
-- NHÓM: Hồng Anh (Leader), Tuấn Anh, Đức Dũng, Ngọc Dương, Thế Hanh
-- =========================================================================

-- CHỐNG LỖI: Tự động xóa Database cũ (nếu có) để tạo lại từ đầu thật sạch sẽ
USE master;
GO

IF EXISTS (SELECT name FROM sys.databases WHERE name = N'QuanLyBaiGuiXe')
BEGIN
    ALTER DATABASE QuanLyBaiGuiXe SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
    DROP DATABASE QuanLyBaiGuiXe;
END
GO

-- Tạo mới Database
CREATE DATABASE QuanLyBaiGuiXe;
GO

USE QuanLyBaiGuiXe;
GO

-- =========================================================================
-- PHẦN 1: TẠO BẢNG (DDL)
-- =========================================================================

-- Tạo bảng LOAI_XE
CREATE TABLE LOAI_XE (
    MaLoaiXe VARCHAR(10) PRIMARY KEY,
    TenLoaiXe NVARCHAR(50) NOT NULL,
    DonGia INT NOT NULL
);

-- Tạo bảng KHACH_HANG
CREATE TABLE KHACH_HANG (
    MaKH INT PRIMARY KEY,
    HoTen NVARCHAR(100) NOT NULL,
    SoDienThoai VARCHAR(15),
    BienSoXe VARCHAR(20) NOT NULL
);

-- Tạo bảng THE_XE
CREATE TABLE THE_XE (
    MaThe VARCHAR(20) PRIMARY KEY,
    LoaiThe NVARCHAR(50) NOT NULL,
    TrangThai NVARCHAR(50) NOT NULL,
    MaKH INT NULL, 
    FOREIGN KEY (MaKH) REFERENCES KHACH_HANG(MaKH)
);

-- Tạo bảng LUOT_VAO_RA 
CREATE TABLE LUOT_VAO_RA (
    MaGiaoDich INT PRIMARY KEY,
    MaThe VARCHAR(20) NOT NULL,
    ThoiGianVao DATETIME NOT NULL,
    ThoiGianRa DATETIME NULL, 
    BienSoVao VARCHAR(20) NOT NULL,
    TienThu INT NULL,
    FOREIGN KEY (MaThe) REFERENCES THE_XE(MaThe)
);
GO

-- =========================================================================
-- PHẦN 2: THÊM DỮ LIỆU MẪU (DML)
-- =========================================================================

-- Thêm giá vé
INSERT INTO LOAI_XE (MaLoaiXe, TenLoaiXe, DonGia) VALUES
('XM', N'Xe máy', 5000),
('OTO', N'Ô tô', 30000);

-- Thêm khách hàng vé tháng
INSERT INTO KHACH_HANG (MaKH, HoTen, SoDienThoai, BienSoXe) VALUES
(1, N'Nguyễn Văn A', '0901234567', '29A1-123.45'),
(2, N'Trần Thị B', '0987654321', '30F-999.99');

-- Thêm thẻ từ RFID
INSERT INTO THE_XE (MaThe, LoaiThe, TrangThai, MaKH) VALUES
('RFID_T01', N'Vé tháng', N'Đang sử dụng', 1), 
('RFID_T02', N'Vé tháng', N'Đang sử dụng', 2), 
('RFID_V01', N'Vé lượt', N'Rảnh', NULL),      
('RFID_V02', N'Vé lượt', N'Rảnh', NULL);      

-- =========================================================================
-- PHẦN 3: GIẢ LẬP LOGIC QUẸT THẺ XE VÀO / RA 
-- =========================================================================

-- Giả lập 3 xe vào bãi (ThoiGianRa = NULL)
INSERT INTO LUOT_VAO_RA (MaGiaoDich, MaThe, ThoiGianVao, ThoiGianRa, BienSoVao, TienThu) VALUES 
(1, 'RFID_T01', '2026-03-27 07:00:00', NULL, '29A1-123.45', NULL),
(2, 'RFID_V01', '2026-03-27 08:00:00', NULL, '29B2-555.55', NULL),
(3, 'RFID_T02', '2026-03-27 09:00:00', NULL, '30F-999.99', NULL);

-- Giả lập 2 xe ra bãi (Cập nhật ThoiGianRa và tính tiền thu)
UPDATE LUOT_VAO_RA SET ThoiGianRa = '2026-03-27 10:00:00', TienThu = 5000 WHERE MaGiaoDich = 2;
UPDATE LUOT_VAO_RA SET ThoiGianRa = '2026-03-27 17:00:00', TienThu = 0 WHERE MaGiaoDich = 3;
GO

-- =========================================================================
-- PHẦN 4: TRUY VẤN XUẤT BÁO CÁO (CHỤP ẢNH DÁN VÀO WORD)
-- =========================================================================

-- Bảng 1: Xem toàn bộ lịch sử xe ra/vào
SELECT * FROM LUOT_VAO_RA;

-- Bảng 2: Danh sách các xe ĐANG CÒN TRONG BÃI (chưa ra)
SELECT MaGiaoDich, MaThe, BienSoVao AS [Bien So Xe], ThoiGianVao AS [Gio Vao]
FROM LUOT_VAO_RA 
WHERE ThoiGianRa IS NULL;

-- Bảng 3: Tính tổng doanh thu tiền vé lượt trong ngày
SELECT SUM(TienThu) AS [Tong Doanh Thu (VNĐ)]
FROM LUOT_VAO_RA
WHERE ThoiGianRa IS NOT NULL;