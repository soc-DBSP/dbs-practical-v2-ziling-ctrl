BEGIN;
UPDATE staff_backup
SET hourly_rate = hourly_rate + 20;
COMMIT;