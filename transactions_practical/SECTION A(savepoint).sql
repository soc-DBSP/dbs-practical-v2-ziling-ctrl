BEGIN;
SAVEPOINT a;
UPDATE staff_backup
SET staff_no = CONCAT('B', SUBSTRING(staff_no,2))
WHERE staff_no LIKE 'S%';
SAVEPOINT b;
UPDATE staff_backup
SET hourly_rate = hourly_rate + 30;
ROLLBACK TO b;
SELECT * FROM staff_backup;
COMMIT;