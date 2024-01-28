/*1. TRIGGER TO UPDATE REVIEW MAIN RATE
The purpose of this trigger is to update review rate accordingly when the translator declares an increase in their transdlation rate. Since the review rate is defined as 25% of the translation rate, the trigger
updates the main rate of the 'Review' job type by %25 of the 'Translation' main rate, each time the Translation rate is updated.*/

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

/*3. FUNCTION FOR PROJECT PRICE CALCULATION AND PROCEDURE FOR INSERTION INFORMATION TO PROJECTS TABLE
The following function is used to calculate the price for the project by using data such as project type, no match (nm) and fuzzy segments (lf and hf) as well as information from the rate_percentages table.
Afterwards, a procedure is used to enter the new project information together with the calculated price value in the projects table*/

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

CREATE OR REPLACE PROCEDURE sp_insert_project_into_projects_table(
    project_name VARCHAR,
    project_end TEXT,
    account_name VARCHAR,
    type_name VARCHAR,
    low INT,
    high INT,
    nomatch INT    )
AS $$
    BEGIN
        INSERT INTO projects(name, start_date, end_date, account_id, job_type_id, low_fuzzy, high_fuzzy, no_match, price)
        VALUES
            (project_name,
            CURRENT_TIMESTAMP,
             TO_TIMESTAMP(project_end, 'DD.MM.YYYY, HH24:MI:SS'),
            (SELECT id FROM accounts WHERE accounts.name = INITCAP(account_name)),
             (SELECT id FROM job_types WHERE name = INITCAP(type_name)),
             low, high, nomatch,
             (SELECT fn_calculate_price_for_project(
                 (SELECT id FROM job_types WHERE name = type_name),
                 low,
                 high,
                 nomatch))
            );
    END
$$
LANGUAGE plpgsql;

/*4. FUNCTION AND TRIGGER USED TO SET THE PAYMENT DUE DATE IN THE PAYMENTS TABLE
The trigger is activated when a project is added to the projects table and automatically sets the payment due date in the payments table based on project end date.*/


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

/*5. FUNCTION AND TRIGGER USED TO SET THE PAYMENT DATE IN THE PAYMENTS TABLE
This function is used to enter the date when the payment is made to the payments table. When the status of a project payment is changed as True upon payment, the below trigger automatically sets the payment_date
in the payments table as the date when the status change is made.*/

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
