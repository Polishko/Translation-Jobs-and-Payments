--This table contains information on job_types and their main rate. The rate for review is calculated based on the translation rate and is calculated automatically by a trigger function (See functions, procedures and triggers file)

--Example:
INSERT INTO job_types(name, main_rate)
VALUES
    ('Translation', 0),
    ('Post Edit', 0),
    ('Review', 0)
;
