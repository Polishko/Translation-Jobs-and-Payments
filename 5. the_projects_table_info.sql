/* This table contains detailed information on projects, including name, creation date, due date, type of project, amount of no match and fuzzy segments and paid_status.
It also contains a column for price that is calculated using the fn_calculate_price_for_project function. See functions, procedures and triggers for more information on the function.*/


--Use the function when populating the projects table as follows: Copy the last 4 input values before the price value (type id, low fuzzy, high fuzzy, no match) as the function parameters. Example:

INSERT INTO projects(name, start_date, end_date, account_id, job_type_id, low_fuzzy, high_fuzzy, no_match, price)
VALUES
    ('156_BCP Manual TR', '09.27.2023 10:10', '10.02.2023 09:00', 6, 2, 128, 287, 5243, (SELECT fn_calculate_price_for_project(2, 128, 287, 5243))),

    -- I included a procedure sp_insert_project_into_projects_table which uses this function and simple copyin from the notification email, to add new values to the table. Can be called as shown:


CALL sp_insert_project_into_projects_table(
    'Part 2',                 --copy paste project name
    '12.10.2023, 15:30',      --copy paste delivery date
    'Synology',               --copy paste account name
    'Post Edit',              --copy paste job type
    0,                        --enter low fuzzy high fuzzy and o match segments respectively 
    673,
    2595);
