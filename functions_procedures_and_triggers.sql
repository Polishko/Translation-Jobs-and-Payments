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

/*3. FUNCTION FOR PROJECT PRICE CALCULATION
The following function is used to calculate price for project by using data such as project type, no match and fuzzy segments as well as information from the rate_percentages table.*/

CREATE OR REPLACE FUNCTION fn_calculate_price_for_project(type_id INT, lf INT, hf INT, nm INT)
RETURNS NUMERIC
AS $$
    DECLARE
        final_price NUMERIC;
        main_rate NUMERIC := (SELECT main_rate FROM job_types WHERE id = type_id);
        rate_percent_nm NUMERIC := (SELECT percent_of_full_rate FROM rate_percentages WHERE id = 1);
        rate_percent_lf NUMERIC := (SELECT percent_of_full_rate FROM rate_percentages WHERE id = 2);
        rate_percent_hf NUMERIC := (SELECT percent_of_full_rate FROM rate_percentages WHERE id = 3);
    BEGIN
        final_price = (nm * rate_percent_nm + lf * rate_percent_lf + hf * rate_percent_hf) * main_rate/100;
    RETURN final_price;
    END
$$
LANGUAGE plpgsql;
