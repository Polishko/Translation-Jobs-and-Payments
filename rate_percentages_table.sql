-- This table shows the percentage of the main rate paid for No match and fuzzy segments (75-84% match and 85-99% match)

INSERT INTO rate_percentages(match_type, percent_of_full_rate)
VALUES
    ('No Match', 100),
    ('FZ/75-84', 50),
    ('FZ/85-99', 30)
;
