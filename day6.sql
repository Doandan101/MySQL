DROP DATABASE mysql_day6;
CREATE DATABASE mysql_day6;
USE mysql_day6;

-- Tạo bảng Accounts với InnoDB
CREATE TABLE Accounts (
    account_id INT PRIMARY KEY,
    full_name VARCHAR(100) NOT NULL,
    balance DECIMAL(15, 2) NOT NULL DEFAULT 0.00,
    status VARCHAR(20) NOT NULL CHECK (status IN ('Active', 'Frozen', 'Closed'))
) ENGINE=InnoDB;

-- Tạo bảng Transactions với InnoDB
CREATE TABLE Transactions (
    txn_id INT AUTO_INCREMENT PRIMARY KEY,
    from_account INT,
    to_account INT,
    amount DECIMAL(15, 2) NOT NULL,
    txn_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    status VARCHAR(20) NOT NULL CHECK (status IN ('Success', 'Failed', 'Pending')),
    FOREIGN KEY (from_account) REFERENCES Accounts(account_id),
    FOREIGN KEY (to_account) REFERENCES Accounts(account_id)
) ENGINE=InnoDB;

-- Tạo bảng TxnAuditLogs với MyISAM
CREATE TABLE TxnAuditLogs (
    log_id INT AUTO_INCREMENT PRIMARY KEY,
    txn_id INT,
    action VARCHAR(100),
    log_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP
) ENGINE=MyISAM;

-- Dư liệu mẫu 
INSERT INTO Accounts (account_id, full_name, balance, status) VALUES
(1, 'Nguyen Van A', 10000.00, 'Active'),
(2, 'Tran Thi B', 5000.00, 'Active'),
(3, 'Le Van C', 2000.00, 'Frozen');

INSERT INTO Transactions (from_account, to_account, amount, status) VALUES
(1, 2, 1000.00, 'Success'),
(2, 1, 500.00, 'Pending');

INSERT INTO TxnAuditLogs (txn_id, action) VALUES
(1, 'Transfer 1000 from account 1 to account 2'),
(2, 'Transfer 500 from account 2 to account 1');

SELECT * FROM Accounts;
SELECT * FROM Transactions;
SELECT * FROM TxnAuditLogs;

-- 2. Transactions & Chống Deadlock
DELIMITER //

CREATE PROCEDURE TransferMoney(
    IN p_from_account INT,
    IN p_to_account INT,
    IN p_amount DECIMAL(15,2)
)
BEGIN
    DECLARE v_from_balance DECIMAL(15,2);
    DECLARE v_from_status VARCHAR(20);
    DECLARE v_to_status VARCHAR(20);
    DECLARE v_txn_id INT;
    DECLARE EXIT HANDLER FOR SQLEXCEPTION 
    BEGIN
        ROLLBACK;
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Giao dịch thất bại!';
    END;

    START TRANSACTION;

    -- Khóa tài khoản theo thứ tự để tránh deadlock
    SELECT balance, status INTO v_from_balance, v_from_status
    FROM Accounts WHERE account_id = p_from_account FOR UPDATE;

    SELECT status INTO v_to_status
    FROM Accounts WHERE account_id = p_to_account FOR UPDATE;

    -- Kiểm tra trạng thái tài khoản
    IF v_from_status != 'Active' OR v_to_status != 'Active' THEN
        ROLLBACK;
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Tài khoản không Active!';
    END IF;

    -- Kiểm tra số dư
    IF v_from_balance < p_amount THEN
        ROLLBACK;
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Số dư không đủ!';
    END IF;

    -- Trừ tiền tài khoản nguồn
    UPDATE Accounts
    SET balance = balance - p_amount
    WHERE account_id = p_from_account;

    -- Cộng tiền tài khoản đích
    UPDATE Accounts
    SET balance = balance + p_amount
    WHERE account_id = p_to_account;

    -- Ghi giao dịch
    INSERT INTO Transactions (from_account, to_account, amount, status)
    VALUES (p_from_account, p_to_account, p_amount, 'Success');

    -- Lấy txn_id vừa tạo
    SET v_txn_id = LAST_INSERT_ID();

    -- Ghi audit log
    INSERT INTO TxnAuditLogs (txn_id, action)
    VALUES (v_txn_id, CONCAT('Transfer ', p_amount, ' from account ', p_from_account, ' to account ', p_to_account));

    COMMIT;
END //

DELIMITER ;

CALL TransferMoney(1, 2, 2000.00);

-- Kiểm tra kết quả
SELECT * FROM Accounts;
SELECT * FROM Transactions;
SELECT * FROM TxnAuditLogs;

-- 3. MVCC – Multi-Version Concurrency Control
-- 3.1 Truy vấn hiển thị số dư 
SET TRANSACTION ISOLATION LEVEL REPEATABLE READ;
START TRANSACTION;
SELECT balance FROM Accounts WHERE account_id = 1;

-- 3.2 Giao dịch chuyển tiền từ Session khác
 CALL TransferMoney(1, 2, 500.00);
 
 -- 3.3 Quan sát MVCC
SELECT balance FROM Accounts WHERE account_id = 1;
COMMIT;

-- 4. Common Table Expression (CTE)
-- 4.1 Tạo bảng Referrals 
CREATE TABLE Referrals (
    referrer_id INT REFERENCES Accounts(account_id),
    referee_id INT REFERENCES Accounts(account_id),
    PRIMARY KEY (referrer_id, referee_id)
) ENGINE=InnoDB;

-- Dữ liệu mẫu
INSERT INTO Referrals (referrer_id, referee_id) VALUES
(1, 2),
(2, 3);

-- 4.1 CTE Đệ Quy – Liệt kê cấp dưới
WITH RECURSIVE ReferralTree AS (
    SELECT referrer_id, referee_id, 1 AS level
    FROM Referrals
    WHERE referrer_id = 1
    UNION ALL
    SELECT r.referrer_id, r.referee_id, rt.level + 1
    FROM Referrals r
    INNER JOIN ReferralTree rt ON r.referrer_id = rt.referee_id
)
SELECT rt.referrer_id, rt.referee_id, rt.level, a.full_name AS referee_name
FROM ReferralTree rt
JOIN Accounts a ON rt.referee_id = a.account_id;

-- 4.2 CTE Truy vấn phức tạp 
WITH AvgTxn AS (
    SELECT AVG(amount) AS avg_amount
    FROM Transactions
),
LabeledTxns AS (
    SELECT t.txn_id, t.from_account, t.amount,
           CASE
               WHEN t.amount > (SELECT avg_amount FROM AvgTxn) THEN 'High'
               WHEN t.amount = (SELECT avg_amount FROM AvgTxn) THEN 'Normal'
               ELSE 'Low'
           END AS label
    FROM Transactions t
)
SELECT t.txn_id, t.amount, t.label, a.full_name AS from_account_name
FROM LabeledTxns t
JOIN Accounts a ON t.from_account = a.account_id
WHERE t.label = 'High';

SELECT * FROM Accounts;
SELECT * FROM Transactions;
SELECT * FROM TxnAuditLogs;
SELECT * FROM Referrals;