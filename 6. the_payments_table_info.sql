/*This table shows the payments for the projects with their due date and paymnt_date. It populates automatically each time a project is added to the projects table.
The expected final payment date for a project is 30 days after the project end_date and is set with the trigger trigger_add_payment_due_date (See functions_ procedures and triggers file)
The date_paid column remains Null untill a payment is made. Then the set_payment_date trigger is activated which takes the date when the project paid_staus is changed to True and populates the
date_paid column of the payments table. (See functions_ procedures and triggers file)*/
