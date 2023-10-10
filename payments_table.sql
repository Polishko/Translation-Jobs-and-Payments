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
