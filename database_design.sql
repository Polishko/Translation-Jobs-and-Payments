CREATE TABLE IF NOT EXISTS accounts(
    id SERIAL PRIMARY KEY,
    name VARCHAR(100),
    code VARCHAR(5)
);

CREATE TABLE IF NOT EXISTS job_types(
    id SERIAL PRIMARY KEY,
    name VARCHAR(20),
    main_rate NUMERIC NOT NULL
);

CREATE TABLE IF NOT EXISTS rate_percentages(
    id SERIAL PRIMARY KEY,
    match_type VARCHAR(10) NOT NULL,
    percent_of_full_rate INT NOT NULL CHECK (percent_of_full_rate BETWEEN 0 AND 100)
);

CREATE TABLE IF NOT EXISTS projects(
  id SERIAL PRIMARY KEY,
  name VARCHAR NOT NULL,
  start_date TIMESTAMP NOT NULL,
  end_date TIMESTAMP NOT NULL,
  account_id INT NOT NULL CHECK (account_id > 0),
  status_paid BOOL DEFAULT FALSE,
  job_type_id INT NOT NULL CHECK (job_type_id > 0),
  low_fuzzy INT NOT NULL,
  high_fuzzy INT NOT NULL,
  no_match INT NOT NULL,
  price NUMERIC,
  CONSTRAINT fk_projects_accounts
    FOREIGN KEY(account_id)
        REFERENCES accounts(id)
        ON DELETE CASCADE
        ON UPDATE CASCADE,
  CONSTRAINT fk_projects_job_types
    FOREIGN KEY(job_type_id)
        REFERENCES job_types(id)
        ON DELETE CASCADE
        ON UPDATE CASCADE
);

CREATE TABLE IF NOT EXISTS purchase_orders(
  id SERIAL PRIMARY KEY,
  project_id INT NOT NULL CHECK (project_id > 0),
  time_created TIMESTAMP,
  order_code TEXT UNIQUE,
  CONSTRAINT fk_purchase_orders_projects
    FOREIGN KEY(project_id)
        REFERENCES projects(id)
        ON DELETE CASCADE
        ON UPDATE CASCADE
);

CREATE TABLE IF NOT EXISTS payments(
  id SERIAL PRIMARY KEY,
  date_due TIMESTAMP,
  date_paid TIMESTAMP,
  project_id INT NOT NULL CHECK (project_id > 0),
  CONSTRAINT fk_payments_projects
    FOREIGN KEY(project_id)
        REFERENCES projects(id)
        ON DELETE CASCADE
        ON UPDATE CASCADE
);

