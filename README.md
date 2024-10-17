# Translation-Jobs-and-Payments
  # Purpose:
  The purpose of this evolving project is to create a platform for freelance professionals where they can manage their projects. Currently it is mainly focused on my own translation and review projects (English to Turkish).

  # Technologies:
  Initially I used PostgreSQL to create a database and several procedures, functions and triggers. Then I added an Email Scraper that collects certain relevant information from my email account.

  # Current status:
    Managing my translation jobs and their purchase orders and payments, tracking open and closed projects, payment orders, payment due dates and statuses.
    Collecting some basic information from my job emails.

  # Details: 
  PostgreSQL: Detailed information on each table and function, procedure can be found in the PostgreSQL folder.
  Email Scraper: This code allows the user to enter a certain date and extract certain information (sender, subject, due date) from emails that are sent on that fdate from a given domain. The relevant information is then stored in a notepad file. I used the web page      https://www.datacourses.com/ for reference for the application of the email library of Python and also made use of regex. The scraper avoids the reply emails and collects the relevant information only once.

  # DB structure and example PostgreSQL outputs

 ![image](https://github.com/Polishko/Translation-Jobs-and-Payments/assets/119063181/ec59ae04-c6a2-4e6e-9aa0-99ed28375da5)
    
  projects table with calculated price based on job_type, rate_percentages, no match and fuzzy inputs 
    
  ![image](https://github.com/Polishko/Translation-Jobs-and-Payments/assets/119063181/3725e773-433a-490e-8122-5c0dd9ae2f39)
    
  current purchase orders
  
  ![image](https://github.com/Polishko/Translation-Jobs-and-Payments/assets/119063181/e4ab53a0-0aa8-4f3d-8c45-499f6de3019d)
    
  table showing payment status
    
  ![image](https://github.com/Polishko/Translation-Jobs-and-Payments/assets/119063181/061490a4-a10f-4433-afe9-6c185f1e72a8)
 
  # Example Email Scraper output

  ![image](https://github.com/Polishko/Translation-Jobs-and-Payments/assets/119063181/0c5ca198-06ad-4962-aad1-c22f26375127)







