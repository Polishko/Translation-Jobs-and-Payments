"""
Connects to Gmail’s IMAP server, searches for emails from a specific domain on a given date,
extracts due date information, and saves it to a text file.
"""

"""
imaplib: Library for working with email servers using the IMAP (Internet Message Access Protocol).

It allows the script to connect to an email inbox, search for emails, read their content, and fetch details.
Unlike POP3, IMAP doesn’t download emails; it just reads them directly from the server.
"""

from email_details import EMAIL_UN, EMAIL_PW, domain
import imaplib
import email
import os
import re
from datetime import datetime, timedelta


def details(domain_info, date):
    try:
        date = datetime.strptime(date, '%d-%m-%Y').strftime('%d-%b-%Y') # str date to datetime obj, then to IMAP required str format
    except ValueError:
        return None

    search_criteria = f'(FROM "@{domain_info}" ON {date})'
    return search_criteria


def extract_info(mail): # mail is an email.message.EmailMessage object from Python’s email module and behaves like a dictionary.
    sender = mail['From']
    subject = mail['Subject']
    due_date_line = None

    if not re.search(r're:', subject, flags=re.IGNORECASE): # ignore reply emails
        for part in mail.walk():
            if part.get_content_maintype() == 'text':
                email_body = part.get_payload(decode=True).decode('utf-8') # extracts raw encoded content and decodes to eadable UTF-8 string
                lines = email_body.split('\n')

                relevant_lines = [line.strip() for line in lines if re.search(
                    r'teslim|teslim tarihi', line, flags=re.IGNORECASE | re.UNICODE)] # teslim/teslim tarihi: delivery/delivery date in Turkish

                if relevant_lines:
                    if re.search(r'rev', subject, flags=re.IGNORECASE): # if review date, then due date is the review date
                        if len(relevant_lines) > 1:
                            due_date_line = relevant_lines[1] # line 0 is the  translation delivery date
                        else:
                            due_date_line = relevant_lines[0]
                    else:
                        due_date_line = relevant_lines[0]

                    match = re.search(r'(\d+(.)+)', due_date_line)
                    if match:
                        if 'yarın' in due_date_line.lower(): # yarin = tomorrow in Turkish
                            due_date_line = (f'{(datetime.now() + timedelta(days=1)).strftime("%d.%m.%Y")}'
                                             f' {match.group(1)}')
                        else:
                            due_date_line = match.group(1)

                    break

        sender_email = re.search(r'<([^>]+)>', sender).group(1) \
            if re.search(r'<([^>]+)>', sender) else sender

        if due_date_line:
            return sender_email, subject, due_date_line

    return None


def process_email_list(items, m):
    extracted_info_list = []

    for email_id in items:
        resp, data = m.fetch(email_id, '(RFC822)')
        email_body = data[0][1]
        mail = email.message_from_bytes(email_body)

        extracted_info = extract_info(mail)

        if extracted_info is not None:
            sender, subject, due_date_info = extracted_info

            email_info = {
                'Sender': sender,
                'Subject': subject,
                'Due date info': due_date_info
            }

            extracted_info_list.append(email_info)

    return extracted_info_list


def process_emails():
    un = EMAIL_UN
    pw = EMAIL_PW
    url = 'imap.gmail.com'
    domain_info = domain

    m = None

    try:
        while True:
            m = imaplib.IMAP4_SSL(url, 993) # IMAP connection obj, Connect to Gmail's IMAP server (SSL for security)
            m.login(un, pw) # Log in using credentials
            m.select()  # Select the inbox (default is "INBOX")

            input_date = input('Enter date (format: DD-MM-YYYY), press Enter for today: ')

            if not input_date:
                input_date = datetime.now().strftime('%d-%m-%Y')
            else:
                try:
                    input_date_obj = datetime.strptime(input_date, '%d-%m-%Y')
                    today_date_obj = datetime.now()

                    if input_date_obj > today_date_obj:
                        print('Please enter a date that is not in the future.')
                        continue
                except ValueError:
                    print('Invalid date format. Please use the format DD-MM-YYYY.')
                    continue

            search_criteria = details(domain_info, input_date)

            if search_criteria is not None:
                break
            else:
                print('Invalid input. Please try again.')

        resp, items = m.search(None, search_criteria)
        items = items[0].split()  # a list of email ids

        extracted_info_list = process_email_list(items, m)

    except Exception as e:
        print(f'Error: {e}')

    finally:
        if m is not None:
            m.logout()

    if not extracted_info_list:
        print(f'No jobs assigned on {input_date}.')
        return

    file_path = os.path.join(os.path.dirname(os.getcwd()), f'{input_date}.txt')

    with open(file_path, 'w', encoding='utf-8') as file:
        for email_info in extracted_info_list:
            file.write(f'Sender: {email_info["Sender"]}\n')
            file.write(f'Subject: {email_info["Subject"]}\n')
            file.write(f'Due date info: {email_info["Due date info"]}\n')
            file.write('\n')


if __name__ == "__main__":
    process_emails()
