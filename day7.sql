DROP DATABASE mysql_day7;
CREATE DATABASE mysql_day7;
USE mysql_day7;

-- Tạo bảng Categories
CREATE TABLE Categories (
    category_id INT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(100) NOT NULL
);

-- Tạo bảng Products
CREATE TABLE Products (
    product_id INT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(255) NOT NULL,
    category_id INT,
    price DECIMAL(10, 2) NOT NULL,
    stock_quantity INT NOT NULL,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (category_id) REFERENCES Categories(category_id)
);

-- Tạo bảng Orders
CREATE TABLE Orders (
    order_id INT PRIMARY KEY AUTO_INCREMENT,
    user_id INT NOT NULL,
    order_date DATETIME DEFAULT CURRENT_TIMESTAMP,
    status VARCHAR(20) NOT NULL
);

-- Tạo bảng OrderItems
CREATE TABLE OrderItems (
    order_item_id INT PRIMARY KEY AUTO_INCREMENT,
    order_id INT,
    product_id INT,
    quantity INT NOT NULL,
    unit_price DECIMAL(10, 2) NOT NULL,
    FOREIGN KEY (order_id) REFERENCES Orders(order_id),
    FOREIGN KEY (product_id) REFERENCES Products(product_id)
);

-- Chèn dữ liệu vào Categories
INSERT INTO Categories (name) VALUES 
('Electronics'), 
('Clothing'), 
('Books');

-- Chèn dữ liệu vào Products
INSERT INTO Products (name, category_id, price, stock_quantity, created_at) VALUES
('Smartphone', 1, 15000000, 50, '2025-05-01 10:00:00'),
('Laptop', 1, 25000000, 30, '2025-05-02 12:00:00'),
('T-shirt', 2, 200000, 100, '2025-05-03 14:00:00'),
('Book A', 3, 150000, 200, '2025-05-04 16:00:00'),
('Tablet', 1, 10000000, 20, '2025-05-05 18:00:00'),
('Headphones', 1, 500000, 150, '2025-05-06 09:00:00'),
('Jeans', 2, 400000, 80, '2025-05-07 11:00:00'),
('Book B', 3, 120000, 300, '2025-05-08 13:00:00'),
('Smartwatch', 1, 3000000, 40, '2025-05-09 15:00:00'),
('Speaker', 1, 2000000, 60, '2025-05-10 17:00:00');

-- Chèn dữ liệu vào Orders
INSERT INTO Orders (user_id, order_date, status) VALUES
(1, '2025-06-01 08:00:00', 'Shipped'),
(2, '2025-06-02 09:00:00', 'Pending'),
(3, '2025-06-03 10:00:00', 'Shipped'),
(4, '2025-06-04 11:00:00', 'Cancelled'),
(5, '2025-06-05 12:00:00', 'Shipped'),
(6, '2025-06-06 13:00:00', 'Shipped'),
(7, '2025-06-07 14:00:00', 'Pending'),
(8, '2025-06-08 15:00:00', 'Shipped'),
(9, '2025-06-09 16:00:00', 'Shipped'),
(10, '2025-06-10 17:00:00', 'Cancelled');

-- Chèn dữ liệu vào OrderItems
INSERT INTO OrderItems (order_id, product_id, quantity, unit_price) VALUES
(1, 1, 2, 15000000),
(1, 5, 1, 10000000),
(2, 3, 3, 200000),
(3, 2, 1, 25000000),
(3, 6, 2, 500000),
(4, 4, 5, 150000),
(5, 1, 1, 15000000),
(5, 9, 2, 3000000),
(6, 8, 4, 120000),
(7, 7, 2, 400000);

SELECT * FROM Categories;
SELECT * FROM Products;
SELECT * FROM Orders;
SELECT * FROM OrderItems;

-- 2. Phân tích và tối ưu hóa truy vấn
-- 2.1 Phân tích truy vấn ban đầu với EXPLAIN
-- Truy vấn ban đầu: 
SELECT * FROM Orders 
JOIN OrderItems ON Orders.order_id = OrderItems.order_id
WHERE status = 'Shipped'
ORDER BY order_date DESC;

-- Phân tích bằng EXPLAIN:
EXPLAIN SELECT * FROM Orders 
JOIN OrderItems ON Orders.order_id = OrderItems.order_id
WHERE status = 'Shipped'
ORDER BY order_date DESC;

-- 2.2 Đề xuất cải tiến
-- Tạo chỉ mục cho status và order_date trên bảng Orders: 
CREATE INDEX idx_orders_status_order_date ON Orders(status, order_date);

-- Tạo composite index cho OrderItems trên order_id và product_id:
CREATE INDEX idx_orderitems_order_product ON OrderItems(order_id, product_id);

-- Sửa truy vấn để chỉ chọn cột cần thiết:
SELECT Orders.order_id, Orders.order_date, Orders.status, 
       OrderItems.product_id, OrderItems.quantity, OrderItems.unit_price
FROM Orders 
JOIN OrderItems ON Orders.order_id = OrderItems.order_id
WHERE Orders.status = 'Shipped'
ORDER BY Orders.order_date DESC;

-- 2.3 Kiểm tra lại với EXPLAIN
EXPLAIN SELECT Orders.order_id, Orders.order_date, OrderItems.product_id, OrderItems.quantity
FROM Orders 
JOIN OrderItems ON Orders.order_id = OrderItems.order_id
WHERE Orders.status = 'Shipped'
ORDER BY Orders.order_date DESC;

-- 3. So sánh hiệu suất giữa JOIN và Subquery
-- 3.1 Truy vấn 1: JOIN giữa Products và Categories
SELECT p.product_id, p.name, c.name AS category_name
FROM Products p
JOIN Categories c ON p.category_id = c.category_id;

-- 3.2 Truy vấn 2: Subquery
SELECT product_id, name, 
       (SELECT name FROM Categories WHERE category_id = p.category_id) AS category_name
FROM Products p;

-- Chạy cả hai truy vấn với EXPLAIN:
EXPLAIN SELECT p.product_id, p.name, p.price, c.name AS category_name
FROM Products p
JOIN Categories c ON p.category_id = c.category_id;

EXPLAIN SELECT p.product_id, p.name, p.price,
       (SELECT name FROM Categories c WHERE c.category_id = p.category_id) AS category_name
FROM Products p;

-- 4. Lấy 10 sản phẩm mới nhất trong danh mục “Electronics”  với stock_quantity > 0
SELECT p.product_id, p.name, p.price, p.stock_quantity, p.created_at
FROM Products p
JOIN Categories c ON p.category_id = c.category_id
WHERE c.name = 'Electronics'
AND p.stock_quantity > 0
ORDER BY p.created_at DESC
LIMIT 10;

-- Tối ưu chỉ mục:
CREATE INDEX idx_products_category_stock_created ON Products(category_id, stock_quantity, created_at);

-- 5. Tạo Covering Index
-- Truy vấn:  
SELECT product_id, name, price 
FROM Products 
WHERE category_id = 3 
ORDER BY price ASC 
LIMIT 20;

-- Tạo Covering Index:
CREATE INDEX idx_covering_category_price ON Products(category_id, price, product_id, name);

-- Kiểm tra với EXPLAIN:
EXPLAIN SELECT product_id, name, price 
FROM Products 
WHERE category_id = 3 
ORDER BY price ASC 
LIMIT 20;

-- 6. Tối ưu truy vấn tính doanh thu theo tháng
SELECT DATE_FORMAT(o.order_date, '%Y-%m') AS month, SUM(oi.quantity * oi.unit_price) AS revenue
FROM Orders o
JOIN OrderItems oi ON o.order_id = oi.order_id
WHERE o.order_date >= '2025-05-13' AND o.order_date < '2025-07-13'
GROUP BY DATE_FORMAT(o.order_date, '%Y-%m')
ORDER BY month ASC;

-- Cải tiến:
CREATE INDEX idx_order_date ON Orders(order_date);

-- 7. Tách truy vấn lớn thành nhiều bước
-- Bước 1: Lọc đơn hàng có sản phẩm đắt tiền (>1M)
CREATE TEMPORARY TABLE ExpensiveOrders AS
SELECT DISTINCT oi.order_id
FROM OrderItems oi
WHERE oi.unit_price > 1000000;

-- Bước 2: Tính tổng số lượng bán ra
SELECT SUM(oi.quantity) AS total_quantity
FROM OrderItems oi
JOIN ExpensiveOrders eo ON oi.order_id = eo.order_id;

-- Tạo chỉ mục trên OrderItems(unit_price) để hỗ trợ lọc:
CREATE INDEX idx_orderitems_unit_price ON OrderItems(unit_price);

-- 8. Top 5 sản phẩm bán chạy nhất trong 30 ngày
SELECT p.product_id, p.name, SUM(oi.quantity) AS total_sold
FROM Products p
JOIN OrderItems oi ON p.product_id = oi.product_id
JOIN Orders o ON oi.order_id = o.order_id
WHERE o.order_date >= DATE_SUB(CURRENT_DATE, INTERVAL 30 DAY)
GROUP BY p.product_id, p.name
ORDER BY total_sold DESC
LIMIT 5;	

