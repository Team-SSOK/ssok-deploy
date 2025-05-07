INSERT IGNORE INTO good (created_at, updated_at, name, account_type_code, interest_rate, interest_cycle)
VALUES
(NOW(), NOW(), '기본 예금 상품', 'DEPOSIT', 1.5, 30),
(NOW(), NOW(), '기본 적금 상품', 'SAVINGS', 2.0, 30)