/*This table contains information on match types and their corresponding rates (as percent of the main rate of a given job type) that are used to calculate the price for certain project.
It is used by the fn_calculate_price_for_project function to automatically populate the price column while inserting the relevant values in the projects table (See functions, procedures and triggers file)*/


Example

INSERT INTO rate_percentages(match_type, percent_of_full_rate)
  VALUES
    ('No Match', 100),
    ('FZ/75-84', 50),
    ('FZ/85-99', 30),
;
