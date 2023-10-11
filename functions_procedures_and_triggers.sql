/*1. TRIGGER TO UPDATE REVIEW MAIN RATE
The following trigger updates the main rate of the 'Review' job type by %25 of the 'Translation' main rate, each time the Translation rate is updated.*/

CREATE OR REPLACE FUNCTION fn_calculate_review_rate()
RETURNS TRIGGER AS $$
    DECLARE
        review_rate NUMERIC;
    BEGIN
        IF NEW.name = 'Translation' THEN
            review_rate := (SELECT NEW.main_rate FROM job_types WHERE name = 'Translation') * 0.25;
            UPDATE job_types
            SET main_rate = review_rate
            WHERE name = 'Review';
        END IF;
    RETURN NEW;
    END
$$
LANGUAGE plpgsql;

CREATE TRIGGER set_review_rate
BEFORE UPDATE ON job_types
FOR EACH ROW
WHEN (NEW.main_rate <> OLD.main_rate)
EXECUTE FUNCTION fn_calculate_review_rate();

/*2. PROCEDURE TO ADD A PURCHASE ORDER TO A PROJECT
This procedure is used to add a purchase order for a project when the order is ready.*/

CREATE OR REPLACE PROCEDURE sp_add_purchase_order(project_name VARCHAR, new_order_code TEXT)
AS $$
    BEGIN
        INSERT INTO purchase_orders(project_id, time_created, order_code)
        VALUES ((SELECT id FROM projects WHERE name = project_name), (SELECT CURRENT_TIMESTAMP), new_order_code);
    END
$$
LANGUAGE plpgsql;

-- call the procedure as follows providing the project name and order code as follows:

CALL sp_add_purchase_order('156_BCP Manual TR', 'PTRIC084732');

