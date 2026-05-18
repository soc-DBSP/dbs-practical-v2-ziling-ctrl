--- stored procedure to transfer staff ---
CREATE OR REPLACE PROCEDURE transfer_staff(
IN p_staff_no CHAR(4),
IN p_new_dept_code VARCHAR(5)
)
LANGUAGE plpgsql
AS $$
DECLARE
v_old_dept_code VARCHAR(5);
BEGIN
-- TODO: Get the current department of the staff member
v_old_dept_code := (SELECT dept_code FROM staff WHERE staff_no = p_staff_no LIMIT 1);
-- TODO: Increment 1 on no_of_staff for the new department
UPDATE department SET no_of_staff = no_of_staff + 1 WHERE dept_code = p_new_dept_code;
-- TODO: Decrement 1 on no_of_staff for the old department
UPDATE department SET no_of_staff = no_of_staff - 1 WHERE dept_code = v_old_dept_code;
-- TODO: Check if the staff member is a Head of Department. If so, raise an
IF EXISTS(SELECT * FROM department WHERE hod = p_staff_no) THEN
	RAISE EXCEPTION 'Please manually update for HOD appointment holders.';
END IF;
-- TODO: Set mod_coord to null if staff_no matches
UPDATE module SET mod_coord = NULL WHERE mod_coord = p_staff_no;
-- TODO: Set supervisor_staff_no to null if staff_no matches
UPDATE staff SET supervisor_staff_no = NULL WHERE supervisor_staff_no = p_staff_no;
-- TODO: Update the staff's dept_code to the new one
UPDATE staff SET dept_code = p_new_dept_code WHERE staff_no = p_staff_no;
END;
$$;