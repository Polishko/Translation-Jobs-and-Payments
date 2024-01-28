import re

from email_details import EMAIL_UN, EMAIL_PW, domain
import imaplib
import email
import os
from datetime import datetime


def details(domain_info, date): # this function prepares the search criteria to look for in the emails
    if not date:
        # If no date is provided, the current date is used
        date = datetime.now().strftime("%d-%b-%Y")
    else:
        # Convert the entered date to the required format
        try:
            date = datetime.strptime(date, "%d-%m-%Y").strftime("%d-%b-%Y")
        except ValueError: # defensive programming check suggested by ChatGPT, a similar check is also present in
            # the final email_processing function
            return None

    search_criteria = f'(FROM "@{domain_info}" ON {date})'
    return search_criteria


def extract_info(mail):
    sender = mail["From"] # mail is the mail object that represents the email message
    subject = mail["Subject"]
    due_date_line = None
    # the email.message.Message class in email module provides a dictionary like interface and headers contain key value
    # pairs for sender, receiver etc.

    # Check if the subject contains "RE:" (case-insensitive), this part is used to ignore the reply emails
    if not re.search(r're:', subject, flags=re.IGNORECASE):
        # Extracting due date containing line from email body: related words in Turkish are 'teslim', 'teslim tarihi'
        for part in mail.walk(): # the email in the email library is represented in tree like structure consisting
            # of parts and walk iterates over these parts (body, html, attachment etc.)
            if part.get_content_maintype() == 'text':
                email_body = part.get_payload(decode=True).decode("utf-8") # this is needed because the email usually
                # contains non-english Turkish characters
                lines = email_body.split('\n')

                # Extracting only the relevant lines: lines containing the keywords are extracted. re.UNICODE ensures
                # proper catching of non-english characters like İ in TESLİM
                relevant_lines = [line.strip() for line in lines if re.search(
                    r'teslim:|teslim tarihi:', line, flags=re.IGNORECASE | re.UNICODE)]

                if relevant_lines:
                    # Check if the subject contains "REV" (case-insensitive)
                    # Sometimes the email contains more than one due date info, one for translator one for reviewer
                    # and the true due date is the review date. These emails contain RE in subject line
                    if re.search(r'rev', subject, flags=re.IGNORECASE):
                        # For subjects containing "REV", take the second occurrence
                        if len(relevant_lines) > 1:
                            due_date_line = relevant_lines[1]
                        else:
                            due_date_line = relevant_lines[0]
                    else:
                        due_date_line = relevant_lines[0]

                    # Extract the due date information from the line
                    match = re.search(r'(\d+(.)+)', due_date_line)
                    if match:
                        due_date_line = match.group(1)

                    break

        # Extracting email address from the sender part: sometimes mails are enclosed in <> hence the conditional case
        # to omit them if present
        sender_email = re.search(r'<([^>]+)>', sender).group(1)\
            if re.search(r'<([^>]+)>', sender) else sender

        # Check if due date information is present
        if due_date_line:
            return sender_email, subject, due_date_line

    return None


def process_email_list(items, m): # items is the list of email id's from IMAP server
    # m is the IMAP4 object that is used to interact with the mail server or the connection object created
    # in the process_emails function
    extracted_info_list = []

    for email_id in items:
        resp, data = m.fetch(email_id, "(RFC822)") # resp response from server, # data is mail data
        # RFC822: a retrieval option, means fetch entire mail in original format
        email_body = data[0][1]
        mail = email.message_from_bytes(email_body) # creates an email.message.Message object from a bytes-like object

        extracted_info = extract_info(mail) # here we can extract the necessary information

        # Check if extract_info returned None
        if extracted_info is not None:
            sender, subject, due_date_info = extracted_info

            email_info = {
                "Sender": sender,
                "Subject": subject,
                "Due date info": due_date_info
            }

            extracted_info_list.append(email_info)

    return extracted_info_list


def process_emails():
    un = EMAIL_UN
    pw = EMAIL_PW
    url = 'imap.gmail.com'
    domain_info = domain

    m = None  # Initialize m outside the try block for proper cleanup in the finally block

    try:
        while True:
            m = imaplib.IMAP4_SSL(url, 993) # establish connection with server
            m.login(un, pw) # login to specific account
            m.select() # when no folder name is provided the default is the inbox

            # Prompt user for date input
            input_date = input("Enter date (format: DD-MM-YYYY), press Enter for today: ")

            try:
                # Convert the entered date to the required format
                input_date_obj = datetime.strptime(input_date, "%d-%m-%Y")
                today_date_obj = datetime.now()

                # Check if the entered date is not a future date
                if input_date_obj > today_date_obj:
                    print("Please enter a date that is not in the future.")
                    continue
            except ValueError:
                print("Invalid date format. Please use the format DD-MM-YYYY.")
                continue

            search_criteria = details(domain_info, input_date) # get the search criteria string

            if search_criteria is not None:
                break
            else:
                print("Invalid date. Please try again.")

        resp, items = m.search(None, search_criteria) # None indicates entire mailbox should be searched
        # resp is server response code, items is string with mail ids
        items = items[0].split() # a list of mail ids

        extracted_info_list = process_email_list(items, m)

    except Exception as e: # if there is error durin interaction with server
        print(f"Error: {e}")

    finally:
        if m is not None:
            m.logout() # closes the connection with the email server

    if extracted_info_list:
        # Save the Notepad file in the parent directory
        file_path = os.path.join(os.path.dirname(os.getcwd()), "extracted_info.txt") # join adds platform independent
        # path separator. the current working directory path is obtained

        with open(file_path, "w", encoding="utf-8") as file: # the encoding will handle non-English characters properly
            for email_info in extracted_info_list:
                file.write(f"Sender: {email_info['Sender']}\n")
                file.write(f"Subject: {email_info['Subject']}\n")
                file.write(f"Due date info: {email_info['Due date info']}\n")
                file.write("\n")


if __name__ == "__main__":
    process_emails()
