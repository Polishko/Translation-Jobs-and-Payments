CREATE OR REPLACE PROCEDURE fn_add_purchase_order(project_name VARCHAR, new_order_code TEXT)
AS $$
    BEGIN
        INSERT INTO purchase_orders(project_id, time_created, order_code)
        VALUES ((SELECT id FROM projects WHERE name = project_name), (SELECT CURRENT_TIMESTAMP), new_order_code);
    END
$$
LANGUAGE plpgsql;

