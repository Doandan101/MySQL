CREATE DATABASE mysql_day1;
USE mysql_day1; 

CREATE TABLE Customers (
customer_id INT AUTO_INCREMENT PRIMARY KEY,
name VARCHAR(255) NOT NULL,
city VARCHAR(50) NOT NULL,
email VARCHAR(255) 
);

CREATE TABLE Products (
product_id INT AUTO_INCREMENT PRIMARY KEY,
name VARCHAR(255) NOT NULL,
price DECIMAL(10,2) NOT NULL
);

CREATE TABLE Orders (
order_id INT AUTO_INCREMENT PRIMARY KEY,
customer_id INT NOT NULL,
order_date DATE NOT NULL,
total_amount DECIMAL(10,2) NOT NULL, 
FOREIGN KEY (customer_id) REFERENCES Customers(customer_id)
);

-- INSERT 
INSERT INTO Customers (name, city, email) VALUES
('Nguyen An', 'HaNoi', 'an.nguyen@email.com'),
('Tran Binh', 'Ho Chi Minh', NULL),
('Le Cuong', 'Da Nang', 'cuong.le@email.com'),
('Hoang Duong', 'HaNoi', 'duong.hoang@email.com');

INSERT INTO Products (name, price) VALUES
('Laptop Dell', 15000000.00),
('Mouse Logitech', 300000.00),
('Keyboard Razer', 1200000.00),
('Laptop HP', 14000000.00);

INSERT INTO Orders (customer_id, order_date, total_amount) VALUES 
(1, '2023-01-15', 500000.00),
(3, '2023-02-10', 800000.00),
(2, '2023-03-05', 300000.00),
(1, '2023-04-01', 450000.00);

SELECT * FROM Customers;
SELECT * FROM Products;
SELECT * FROM Orders;

-- 1. Danh sách khách hàng đến từ Hà Nội
SELECT *FROM Customers WHERE city = 'HaNoi';

-- 2. Đơn hàng trên 400.000 đồng và đặt sau 31/01/2023
SELECT * FROM Orders WHERE total_amount > 400000 AND order_date > '2023-01-31';

-- 3. Khách hàng chưa có email
SELECT *FROM Customers WHERE email IS NULL;

-- 4. Xem toàn bộ đơn hàng, sắp xếp theo tổng tiền giảm dần
SELECT * FROM Orders ORDER BY total_amount DESC; 

-- 5. Thêm khách hàng mới "Pham Thanh"
INSERT INTO Customers (name, city, email) VALUES
('Pham Thanh', 'Can Tho', NULL);

-- 6. Cập nhật email cho khách hàng customer_id = 2
UPDATE Customers SET email = 'binh.tran@email.com' WHERE customer_id = 2;

-- 7. Xóa đơn hàng order_id = 103
DELETE FROM Orders WHERE order_id = 103;

-- 8. Lấy 2 khách hàng đầu tiên
SELECT * FROM Customers LIMIT 2;

-- 9. Đơn hàng có giá trị lớn nhất và nhỏ nhất
SELECT MAX(total_amount) AS max_amount, MIN(total_amount) AS min_amount FROM Orders;

-- 10. Tổng số lượng đơn hàng, tổng tiền, trung bình giá trị
SELECT COUNT(*) AS total_orders, SUM(total_amount) AS total_revennue, AVG(total_amount) AS avg_order_value FROM Orders;

-- 11. Sản phẩm bắt đầu bằng "Laptop"
SELECT * FROM Products WHERE name LIKE 'Laptop%';

-- 12. Mô tả RDBMS và vai trò của mối quan hệ
SELECT c.name, o.order_id, o.total_amount FROM Customers c JOIN Orders o ON c.customer_id = o.customer_id; 
