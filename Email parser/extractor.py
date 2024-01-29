from email_details import EMAIL_UN, EMAIL_PW, domain
import imaplib
import email
import os
import re
from datetime import datetime


def details(domain_info, date):
    try:
        date = datetime.strptime(date, "%d-%m-%Y").strftime("%d-%b-%Y")
    except ValueError:
        return None

    search_criteria = f'(FROM "@{domain_info}" ON {date})'
    return search_criteria


def extract_info(mail):
    sender = mail["From"]
    subject = mail["Subject"]
    due_date_line = None

    if not re.search(r're:', subject, flags=re.IGNORECASE):
        for part in mail.walk():
            if part.get_content_maintype() == 'text':
                email_body = part.get_payload(decode=True).decode("utf-8")
                lines = email_body.split('\n')

                relevant_lines = [line.strip() for line in lines if re.search(
                    r'teslim:|teslim tarihi:', line, flags=re.IGNORECASE | re.UNICODE)]

                if relevant_lines:
                    if re.search(r'rev', subject, flags=re.IGNORECASE):
                        if len(relevant_lines) > 1:
                            due_date_line = relevant_lines[1]
                        else:
                            due_date_line = relevant_lines[0]
                    else:
                        due_date_line = relevant_lines[0]

                    match = re.search(r'(\d+(.)+)', due_date_line)
                    if match:
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
        resp, data = m.fetch(email_id, "(RFC822)")
        email_body = data[0][1]
        mail = email.message_from_bytes(email_body)

        extracted_info = extract_info(mail)

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

    m = None

    try:
        while True:
            m = imaplib.IMAP4_SSL(url, 993)
            m.login(un, pw)
            m.select()

            input_date = input("Enter date (format: DD-MM-YYYY), press Enter for today: ")

            if not input_date:
                input_date = datetime.now().strftime("%d-%m-%Y")
            else:
                try:
                    input_date_obj = datetime.strptime(input_date, "%d-%m-%Y")
                    today_date_obj = datetime.now()

                    if input_date_obj > today_date_obj:
                        print("Please enter a date that is not in the future.")
                        continue
                except ValueError:
                    print("Invalid date format. Please use the format DD-MM-YYYY.")
                    continue

            search_criteria = details(domain_info, input_date)

            if search_criteria is not None:
                break
            else:
                print("Invalid input. Please try again.")

        resp, items = m.search(None, search_criteria)
        items = items[0].split()  # a list of mail ids

        extracted_info_list = process_email_list(items, m)

    except Exception as e:
        print(f"Error: {e}")

    finally:
        if m is not None:
            m.logout()

    if extracted_info_list:
        file_path = os.path.join(os.path.dirname(os.getcwd()), "extracted_info.txt")

        with open(file_path, "w", encoding="utf-8") as file:
            for email_info in extracted_info_list:
                file.write(f"Sender: {email_info['Sender']}\n")
                file.write(f"Subject: {email_info['Subject']}\n")
                file.write(f"Due date info: {email_info['Due date info']}\n")
                file.write("\n")


if __name__ == "__main__":
    process_emails()
