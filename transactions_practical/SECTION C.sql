-- CREATE TABLE payment_fee_type (
-- fee_type SERIAL PRIMARY KEY,
-- fee_name VARCHAR(20) NOT NULL
-- );
-- INSERT INTO payment_fee_type (fee_name) VALUES
-- ('crse_fee'),
-- ('lab_fee');
-- CREATE TABLE payment_history (
-- payment_id SERIAL PRIMARY KEY,
-- payee_no VARCHAR(4) NOT NULL,
-- payment_date DATE NOT NULL,
-- amount_paid DECIMAL(7, 2) NOT NULL,
-- fee_type INT NOT NULL,
-- CONSTRAINT payment_history_fee_type_fk FOREIGN KEY (fee_type) REFERENCES
-- payment_fee_type(fee_type)
-- );
-- ALTER TABLE course ADD COLUMN max_crse_size INTEGER default 100;

-- Stored Procedure with transaction to enrol student --
-- UPDATE course SET max_crse_size=2 WHERE crse_code='DBA';
CREATE OR REPLACE PROCEDURE enrol_new_student(
IN adm_no_param CHAR(4),
IN stud_name_param VARCHAR(30),
IN gender_param CHAR(1),
IN address_param VARCHAR(100),
IN dob_param DATE,
IN nationality_param VARCHAR(30),
IN crse_code_param VARCHAR(5),
OUT err_msg VARCHAR(50) -- An OUT parameter to return error message
)
LANGUAGE plpgsql
AS $$
DECLARE
max_size INTEGER;
current_size INTEGER;
current_crse_fee DECIMAL(7, 2);
current_lab_fee DECIMAL(7, 2);
BEGIN
BEGIN -- T1, Add a nested transaction block to emulate savepoint for the payment operations
-- TODO Fetch crse_fee and lab_fee in a single query
SELECT crse_fee, lab_fee INTO current_crse_fee, current_lab_fee FROM course WHERE crse_code = crse_code_param;
-- TODO Insert crse_fee and lab_fee into payment_history for non-null fees. For fee_type, 1 represents crse_fee and 2 represents lab_fee
INSERT INTO payment_history (payee_no, payment_date, amount_paid, fee_type) 
VALUES (adm_no_param, LOCALTIMESTAMP, current_crse_fee, 1);
IF (current_lab_fee IS NOT NULL) THEN
	INSERT INTO payment_history (payee_no, payment_date, amount_paid, fee_type) 
	VALUES (adm_no_param, LOCALTIMESTAMP, current_lab_fee, 2);
END IF;
EXCEPTION
WHEN OTHERS THEN
err_msg := 'Issues with payments.';
END; -- End of T1 transaction block enclosing payment operations
BEGIN -- T2, a nested transaction block for the remaining operations
-- TODO Insert a new record into the student table
INSERT INTO student (adm_no, stud_name, gender, address, dob, nationality, crse_code)
VALUES (adm_no_param, stud_name_param, gender_param, address_param, dob_param, nationality_param, crse_code_param);
-- TODO Get the maximum course size for the specified course
SELECT max_crse_size INTO max_size FROM course WHERE crse_code = crse_code_param;
-- TODO Get the current number of students enrolled in the specified course
SELECT COUNT(*) INTO current_size FROM student WHERE crse_code = crse_code_param;
-- TODO Check if adding a new student exceeds the maximum course size
IF (max_size >= current_size)
THEN
RAISE NOTICE 'Student inserted successfully.';
ELSE
RAISE EXCEPTION 'Cannot insert student. Maximum course size exceeded.';
END IF;
EXCEPTION
WHEN OTHERS THEN
-- Handle exception as an error message returned to the application
err_msg := 'Maximum course size exceeded. Please Handle Manually.';
END; -- End of T2 transaction block
COMMIT;
END;
$$;