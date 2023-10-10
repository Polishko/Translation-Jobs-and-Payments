--1. Function for price calculation

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

--directly use the function when populating the projects table; copy the last 4 input values in a row: type id, low fuzzy, high fuzzy, no match values as the function parameters example:

INSERT INTO projects(name, start_date, end_date, account_id, job_type_id, low_fuzzy, high_fuzzy, no_match, price)
VALUES
    ('156_BCP Manual TR', '09.27.2023 10:10', '10.02.2023 09:00', 6, 2, 128, 287, 5243, (SELECT fn_calculate_price_for_project(2, 128, 287, 5243))),
....

  
