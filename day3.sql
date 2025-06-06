CREATE DATABASE mysql_day3;
USE mysql_day3;

-- Tạo bảng Candidates
CREATE TABLE Candidates (
    candidate_id INT PRIMARY KEY,
    full_name VARCHAR(255),
    email VARCHAR(255),
    phone VARCHAR(20),
    years_exp INT,
    expected_salary INT
);

-- Tạo bảng Jobs
CREATE TABLE Jobs (
    job_id INT PRIMARY KEY,
    title VARCHAR(255),
    department VARCHAR(100),
    min_salary INT,
    max_salary INT
);

-- Tạo bảng Applications
CREATE TABLE Applications (
    app_id INT PRIMARY KEY,
    candidate_id INT,
    job_id INT,
    apply_date DATE,
    status VARCHAR(50),
    FOREIGN KEY (candidate_id) REFERENCES Candidates(candidate_id),
    FOREIGN KEY (job_id) REFERENCES Jobs(job_id)
);

-- Chèn dữ liệu vào bảng Candidates
INSERT INTO Candidates (candidate_id, full_name, email, phone, years_exp, expected_salary) VALUES
(1, 'Nguyen Van A', 'a@gmail.com', '0901234567', 2, 15000000),
(2, 'Tran Thi B', 'b@gmail.com', NULL, 5, 25000000),
(3, 'Le Van C', 'c@gmail.com', '0912345678', 7, 30000000),
(4, 'Do Thi D', 'd@gmail.com', '0923456789', 0, 10000000),
(5, 'Hoang Van E', 'e@gmail.com', '0934567890', 3, 20000000);

DELETE FROM Candidates;

-- Chèn dữ liệu vào bảng Jobs
INSERT INTO Jobs (job_id, title, department, min_salary, max_salary) VALUES
(101, 'Software Engineer', 'IT', 20000000, 35000000),
(102, 'Data Analyst', 'IT', 18000000, 30000000),
(103, 'HR Manager', 'HR', 25000000, 40000000),
(104, 'Marketing Specialist', 'Marketing', 15000000, 25000000),
(105, 'DevOps Engineer', 'IT', 25000000, 45000000),
(106, 'Senior IT Architect', 'IT', 35000000, 50000000);

DELETE FROM Jobs;

-- Chèn dữ liệu vào bảng Applications
INSERT INTO Applications (app_id, candidate_id, job_id, apply_date, status) VALUES
(1001, 1, 101, '2025-01-10', 'Accepted'),
(1002, 1, 103, '2025-01-15', 'Pending'),
(1003, 2, 102, '2025-02-01', 'Rejected'),
(1004, 3, 101, '2025-02-05', 'Accepted'),
(1005, 3, 105, '2025-02-10', 'Pending'),
(1006, 4, 104, '2025-03-01', 'Accepted'),
(1007, 5, 102, '2025-03-05', 'Pending');

DELETE FROM Applications;

-- Bài 1: Tìm ứng viên đã từng ứng tuyển vào ít nhất một công việc thuộc phòng ban "IT" (Sử dụng EXISTS)
SELECT c.candidate_id, c.full_name FROM Candidates c WHERE EXISTS (
	SELECT 1
    FROM Applications a
    INNER JOIN Jobs j ON a.job_id = j.job_id
    WHERE a.candidate_id = c.candidate_id
    AND j.department = 'IT'
);

-- Bài 2: Liệt kê công việc có mức lương tối đa lớn hơn mức lương mong đợi của bất kỳ ứng viên nào (Sử dụng ANY)
SELECT job_id, title, max_salary FROM Jobs WHERE max_salary > ANY ( SELECT expected_salary FROM Candidates );

-- Bài 3: Liệt kê công việc có mức lương tối thiểu lớn hơn mức lương mong đợi của tất cả ứng viên (Sử dụng ALL)
SELECT job_id, title, min_salary FROM Jobs WHERE min_salary > ALL ( SELECT expected_salary FROM Candidates );

-- Bài 4: Chèn vào bảng ShortlistedCandidates những ứng viên có trạng thái 'Accepted'
CREATE TABLE ShortlistedCandidates (
    candidate_id INT,
    job_id INT,
    selection_date DATE,
    PRIMARY KEY (candidate_id, job_id),
    FOREIGN KEY (candidate_id) REFERENCES Candidates(candidate_id),
    FOREIGN KEY (job_id) REFERENCES Jobs(job_id)
);

INSERT INTO ShortlistedCandidates (candidate_id, job_id, selection_date)
SELECT a.candidate_id, a.job_id, CURDATE() AS selection_date FROM Applications a WHERE a.status = 'Accepted';

-- Bài 5: Hiển thị ứng viên với đánh giá mức kinh nghiệm (Sử dụng CASE)
SELECT candidate_id, full_name, years_exp, CASE WHEN years_exp < 1 THEN 'Fresher' WHEN years_exp BETWEEN 1 AND 3 THEN 'Junior'
WHEN years_exp BETWEEN 4 AND 6 THEN 'Mid-level' WHEN years_exp > 6 THEN 'Senior' ELSE 'Unknown' END AS experience_level FROM Candidates;

-- Bài 6: Liệt kê ứng viên, thay phone NULL bằng 'Chưa cung cấp' (Sử dụng COALESCE)
SELECT candidate_id, full_name, COALESCE(phone, 'Chưa cung cấp') AS phone FROM Candidates;

-- Bài 7: Tìm công việc có max_salary không bằng min_salary và max_salary >= 1000
SELECT job_id, title, min_salary, max_salary FROM Jobs WHERE max_salary != min_salary AND max_salary >= 1000;