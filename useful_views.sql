/*1. MISSING POs
A view which is used to check whether a certain project that is completed (and not paid) lacks a purchase order.
It can be retrieved before the end of the month, prior to preparing the necessary invoices.*/

DROP VIEW IF EXISTS projects_without_po;
CREATE VIEW projects_without_po AS(

    SELECT a.code,
           pr.name
    FROM projects AS pr
             JOIN accounts AS a
                  ON pr.account_id = a.id
             LEFT JOIN purchase_orders AS po
                       ON pr.id = po.project_id
    WHERE delivered_status = TRUE
      AND pr.status_paid = FALSE
      AND po.id IS NULL
    ORDER BY pr.end_date
);



