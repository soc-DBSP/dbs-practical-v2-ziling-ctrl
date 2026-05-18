BEGIN;
UPDATE staff_backup
SET staff_no = CONCAT('A', SUBSTRING(staff_no,2))
WHERE staff_no LIKE 'S%';
SELECT staff_no FROM staff_backup;
ROLLBACK;
SELECT staff_no FROM staff_backup;