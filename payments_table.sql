--The payments table will populate with new values each time a project is added to the projects table. Expected final payment date for a project is 30 days after the project end_date. The date_paid column will remain Null until it is filled when payment is made.

CREATE OR REPLACE FUNCTION fn_set_payment_due_date()
RETURNS TRIGGER
AS $$
    BEGIN
        INSERT INTO payments(date_due, date_paid, project_id)
        VALUES
            (NEW.end_date + INTERVAL '30 Days', NULL, NEW.id);
    RETURN NEW;
    END
$$
LANGUAGE plpgsql;

CREATE TRIGGER trigger_add_payment_due_date
AFTER INSERT ON projects
FOR EACH ROW
EXECUTE FUNCTION fn_set_payment_due_date();

--When the status of a project is changed as True upon payment, the below trigger will set the payment_date in the payments table as the "current date" of status change.

CREATE OR REPLACE FUNCTION fn_set_payment_date()
RETURNS TRIGGER
AS $$
    BEGIN
    IF NEW.status_paid = TRUE THEN
        UPDATE payments
        SET date_paid = (SELECT CURRENT_TIMESTAMP)
        WHERE payments.project_id = NEW.id;
    END IF;
    RETURN NEW;
    END
 $$
LANGUAGE plpgsql;

CREATE TRIGGER set_payment_date
AFTER UPDATE OF status_paid ON projects
FOR EACH ROW
EXECUTE FUNCTION fn_set_payment_due_date();
