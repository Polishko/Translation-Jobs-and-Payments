# Translation-Jobs-and-Payments
This database will be used to manage my translation jobs and their purchase orders and payments.

I will be using this database to track open and closed projects, payment orders, payment due dates and statuses.

Current status: Information for each table, all functions, procedures and triggers and the database design is present.

Short-term goals: 
- Adding views/joined tables to handle most common tasks (some views were added and more can be added as necessary).
- Adding a table to store monthly total payment for comparison reasons.
- Adding a function to calculate expected total payment for a month (for completed projects).

Long-term goals: 
- Adding information about project managers and setting an email trigger to remind them about any missing, overdue purchase orders.
- Creating a user friendly interface where translators can easily manage their own projects by simply entering the necessary information in the provided fields.
- Creating means to store information about invoices.
- Adding a trigger which will change the delivered_status column value in the projects table to true upon delivery of the project on the delivery platform. For the time being this is handled manually.

![image](https://github.com/Polishko/Translation-Jobs-and-Payments/assets/119063181/ec59ae04-c6a2-4e6e-9aa0-99ed28375da5)



Example outputs

projects table with calculated price based on job_type, rate_percentages, no match and fuzzy inputs 

![image](https://github.com/Polishko/Translation-Jobs-and-Payments/assets/119063181/3725e773-433a-490e-8122-5c0dd9ae2f39)

current purchase orders

![image](https://github.com/Polishko/Translation-Jobs-and-Payments/assets/119063181/e4ab53a0-0aa8-4f3d-8c45-499f6de3019d)

table showing payment status

![image](https://github.com/Polishko/Translation-Jobs-and-Payments/assets/119063181/061490a4-a10f-4433-afe9-6c185f1e72a8)






