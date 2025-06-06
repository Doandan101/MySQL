CREATE DATABASE mysql_day4;
USE mysql_day4;

-- Tạo bảng Students
CREATE TABLE Students (
    student_id INT PRIMARY KEY AUTO_INCREMENT,
    full_name VARCHAR(100) NOT NULL,
    email VARCHAR(100) UNIQUE,
    join_date DATE DEFAULT '2025-06-05'
);

-- Tạo bảng Courses
CREATE TABLE Courses (
    course_id INT PRIMARY KEY AUTO_INCREMENT,
    title VARCHAR(100) NOT NULL,
    description TEXT,
    price INT CHECK (price >= 0)
);

-- Tạo bảng Enrollments
CREATE TABLE Enrollments (
    enrollment_id INT PRIMARY KEY AUTO_INCREMENT,
    student_id INT,
    course_id INT,
    enroll_date DATE DEFAULT '2025-06-05',
    status VARCHAR(20) DEFAULT 'active',
    FOREIGN KEY (student_id) REFERENCES Students(student_id),
    FOREIGN KEY (course_id) REFERENCES Courses(course_id)
);

-- Chèn dữ liệu vào bảng Students
INSERT INTO Students (full_name, email, join_date) VALUES
('Nguyen Van A', 'nguyenvana@gmail.com', '2025-01-10'),
('Tran Thi B', 'tranthib@gmail.com', '2025-02-15'),
('Le Van C', 'levanc@gmail.com', '2025-03-20'),
('Do Thi D', 'dothid@gmail.com', '2025-04-25'),
('Hoang Van E', 'hoangvane@gmail.com', '2025-06-05');

-- Chèn dữ liệu vào bảng Courses
INSERT INTO Courses (title, description, price) VALUES
('Lập trình Python cơ bản', 'Khóa học về lập trình Python cho người mới bắt đầu.', 500000),
('SQL nâng cao', 'Học cách viết truy vấn SQL phức tạp.', 750000),
('Thiết kế UI/UX', 'Khóa học thiết kế giao diện người dùng.', 1200000),
('Machine Learning cơ bản', 'Giới thiệu về học máy và các thuật toán cơ bản.', 2000000),
('Tiếng Anh giao tiếp', 'Khóa học cải thiện kỹ năng giao tiếp tiếng Anh.', 0);

-- Chèn dữ liệu vào bảng Enrollments
INSERT INTO Enrollments (student_id, course_id, enroll_date, status) VALUES
(1, 1, '2025-01-15', 'active'),
(1, 3, '2025-02-01', 'active'),
(2, 2, '2025-02-20', 'active'),
(3, 1, '2025-03-25', 'inactive'),
(3, 4, '2025-04-01', 'active'),
(4, 5, '2025-05-01', 'active'),
(5, 2, '2025-06-05', 'active');

-- Xóa bảng Enrollments
DROP TABLE Enrollments;

-- Tạo VIEW StudentCourseView để hiển thị sinh viên và khóa học đã đăng ký
DROP VIEW IF EXISTS StudentCourseView;
CREATE VIEW StudentCourseView AS
SELECT s.student_id, s.full_name, s.email, c.course_id, c.title AS course_title FROM Students s
INNER JOIN Enrollments e ON s.student_id = e.student_id
INNER JOIN Courses c ON e.course_id = c.course_id;

-- Tạo chỉ mục trên cột title của bảng Courses
CREATE INDEX idx_course_title ON Courses(title);

-- Xóa cơ sở dữ liệu OnlineLearning
DROP DATABASE mysql_day4;