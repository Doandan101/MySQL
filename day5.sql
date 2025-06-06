CREATE DATABASE mysql_day5;
USE mysql_day5;

-- Tạo bảng Rooms
CREATE TABLE Rooms (
    room_id INT PRIMARY KEY AUTO_INCREMENT,
    room_number VARCHAR(10) UNIQUE,
    type VARCHAR(20),
    status VARCHAR(20),
    price INT CHECK (price >= 0)
);

-- Tạo bảng Guests
CREATE TABLE Guests (
    guest_id INT PRIMARY KEY AUTO_INCREMENT,
    full_name VARCHAR(100),
    phone VARCHAR(20)
);

-- Tạo bảng Bookings
CREATE TABLE Bookings (
    booking_id INT PRIMARY KEY AUTO_INCREMENT,
    guest_id INT,
    room_id INT,
    check_in DATE,
    check_out DATE,
    status VARCHAR(20),
    FOREIGN KEY (guest_id) REFERENCES Guests(guest_id),
    FOREIGN KEY (room_id) REFERENCES Rooms(room_id)
);

-- Tạo bảng Invoices (cho Bonus)
CREATE TABLE Invoices (
    invoice_id INT PRIMARY KEY AUTO_INCREMENT,
    booking_id INT,
    total_amount INT,
    generated_date DATE,
    FOREIGN KEY (booking_id) REFERENCES Bookings(booking_id)
);

INSERT INTO Rooms (room_number, type, status, price) VALUES
('101', 'Standard', 'Available', 1000000),
('102', 'VIP', 'Available', 2000000),
('103', 'Suite', 'Occupied', 3500000),
('104', 'Standard', 'Maintenance', 1200000);

INSERT INTO Guests (full_name, phone) VALUES
('Nguyen Van A', '0901234567'),
('Tran Thi B', '0912345678'),
('Le Van C', '0923456789');

INSERT INTO Bookings (guest_id, room_id, check_in, check_out, status) VALUES
(1, 3, '2025-06-01', '2025-06-07', 'Confirmed'),
(2, 2, '2025-06-05', '2025-06-10', 'Confirmed'),
(3, 1, '2025-06-07', '2025-06-09', 'Pending');

DELIMITER //

CREATE PROCEDURE MakeBooking(
    IN p_guest_id INT,
    IN p_room_id INT,
    IN p_check_in DATE,
    IN p_check_out DATE
)
BEGIN
    DECLARE room_status VARCHAR(20);
    DECLARE conflict_count INT;

    -- Kiểm tra xem phòng có tồn tại và trạng thái là Available
    SELECT status INTO room_status
    FROM Rooms
    WHERE room_id = p_room_id;

    IF room_status IS NULL THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Phòng không tồn tại!';
    ELSEIF room_status != 'Available' THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Phòng không khả dụng!';
    END IF;

    -- Kiểm tra xung đột thời gian với các đặt phòng khác
    SELECT COUNT(*) INTO conflict_count
    FROM Bookings
    WHERE room_id = p_room_id
    AND status = 'Confirmed'
    AND (
        (p_check_in BETWEEN check_in AND check_out)
        OR (p_check_out BETWEEN check_in AND check_out)
        OR (check_in BETWEEN p_check_in AND p_check_out)
    );

    IF conflict_count > 0 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Xung đột thời gian đặt phòng!';
    END IF;

    -- Nếu hợp lệ, tạo đặt phòng và cập nhật trạng thái phòng
    INSERT INTO Bookings (guest_id, room_id, check_in, check_out, status)
    VALUES (p_guest_id, p_room_id, p_check_in, p_check_out, 'Confirmed');

    UPDATE Rooms
    SET status = 'Occupied'
    WHERE room_id = p_room_id;

END //

DELIMITER ;

DELIMITER //

CREATE PROCEDURE MakeBooking(
    IN p_guest_id INT,
    IN p_room_id INT,
    IN p_check_in DATE,
    IN p_check_out DATE
)
BEGIN
    DECLARE room_status VARCHAR(20);
    DECLARE conflict_count INT;

    -- Kiểm tra xem phòng có tồn tại và trạng thái là Available
    SELECT status INTO room_status
    FROM Rooms
    WHERE room_id = p_room_id;

    IF room_status IS NULL THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Phòng không tồn tại!';
    ELSEIF room_status != 'Available' THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Phòng không khả dụng!';
    END IF;

    -- Kiểm tra xung đột thời gian với các đặt phòng khác
    SELECT COUNT(*) INTO conflict_count
    FROM Bookings
    WHERE room_id = p_room_id
    AND status = 'Confirmed'
    AND (
        (p_check_in BETWEEN check_in AND check_out)
        OR (p_check_out BETWEEN check_in AND check_out)
        OR (check_in BETWEEN p_check_in AND p_check_out)
    );

    IF conflict_count > 0 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Xung đột thời gian đặt phòng!';
    END IF;

    -- Nếu hợp lệ, tạo đặt phòng và cập nhật trạng thái phòng
    INSERT INTO Bookings (guest_id, room_id, check_in, check_out, status)
    VALUES (p_guest_id, p_room_id, p_check_in, p_check_out, 'Confirmed');

    UPDATE Rooms
    SET status = 'Occupied'
    WHERE room_id = p_room_id;

END //

DELIMITER ;

DELIMITER //

CREATE TRIGGER after_booking_cancel
AFTER UPDATE ON Bookings
FOR EACH ROW
BEGIN
    -- Kiểm tra nếu trạng thái thay đổi thành 'Cancelled'
    IF NEW.status = 'Cancelled' AND OLD.status != 'Cancelled' THEN
        -- Kiểm tra có đặt phòng Confirmed khác trong tương lai không
        IF NOT EXISTS (
            SELECT 1
            FROM Bookings
            WHERE room_id = NEW.room_id
            AND status = 'Confirmed'
            AND check_in >= CURDATE()
        ) THEN
            UPDATE Rooms
            SET status = 'Available'
            WHERE room_id = NEW.room_id;
        END IF;
    END IF;
END //

DELIMITER ;

DELIMITER //

CREATE PROCEDURE GenerateInvoice(
    IN p_booking_id INT
)
BEGIN
    DECLARE v_check_in DATE;
    DECLARE v_check_out DATE;
    DECLARE v_price INT;
    DECLARE v_nights INT;
    DECLARE v_total_amount INT;

    -- Kiểm tra booking_id có tồn tại và trạng thái là Confirmed
    SELECT b.check_in, b.check_out, r.price
    INTO v_check_in, v_check_out, v_price
    FROM Bookings b
    JOIN Rooms r ON b.room_id = r.room_id
    WHERE b.booking_id = p_booking_id AND b.status = 'Confirmed';

    IF v_check_in IS NULL THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Đặt phòng không tồn tại hoặc chưa được xác nhận!';
    END IF;

    -- Tính số đêm
    SET v_nights = DATEDIFF(v_check_out, v_check_in);

    -- Tính tổng tiền
    SET v_total_amount = v_nights * v_price;

    -- Thêm hóa đơn vào bảng Invoices
    INSERT INTO Invoices (booking_id, total_amount, generated_date)
    VALUES (p_booking_id, v_total_amount, CURDATE());

END //

DELIMITER ;
CALL GenerateInvoice(1);

SELECT * FROM Rooms;
SELECT * FROM Bookings;
SELECT * FROM Invoices;
