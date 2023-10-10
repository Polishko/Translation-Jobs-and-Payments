--Initial creation of the table job_types and inclusion of a trigger that will update the main rate of the 'Review' job type by %25 of the 'Translation' main rate, each time the Translation rate is updated.

INSERT INTO job_types(name, main_rate)
VALUES
    ('Translation', 0),
    ('Post Edit', 0),
    ('Review', 0)
;

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

--setting the current rates for Translation and Post Edit jobs
UPDATE job_types
SET main_rate = 0.023
WHERE name = 'Translation';

UPDATE job_types
SET main_rate = 0.020
WHERE name = 'Post Edit';

