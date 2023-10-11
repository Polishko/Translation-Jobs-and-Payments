--The following trigger updates the main rate of the 'Review' job type by %25 of the 'Translation' main rate, each time the Translation rate is updated.

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

