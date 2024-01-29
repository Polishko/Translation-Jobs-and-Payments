# the details function:
this function prepares the search criteria to look for in the emails
If no date is provided, the current date is used
Convert the entered date to the required format
exception is double handled in the final email_processing function, but
ChatGPT suggested leaving it here as well defensive programming check


# the extract_info function:
this function serves to extract the necessary information
mail: the mail object that represents the email message,
the email.message.Message class in email module provides a dictionary like interface and headers contain key value pairs for sender, receiver etc.
1st check: if the mail subject contains "RE:" (case-insensitive), email is ignored --> this part is used to ignore the reply emails
for cycle: walk in the email and extract the due date info containing line from email body: related words in Turkish are 'teslim', 'teslim tarihi'
the email in the email library is represented in a tree like structure consisting
of parts and walk iterates over these parts (body, html, attachment etc.)
the utf-8 decoding is needed because the email usually contains non-english Turkish characters that create problem during conversion to lowercase characters
Only the relevant lines containing the keywords are extracted. re.UNICODE ensures
proper catching of non-english characters like the İ in TESLİM
Check if the subject contains "REV" (case-insensitive)
Sometimes the email contains more than one due date info, one for translator one for reviewer and the true due date for teh job is the review date. These emails contain RE in subject line. For subjects containing "REV", the second occurrence is taken
The conditional check for sender email extraction was suggested by ChatGPT. Since sometimes mails are enclosed in <>, the conditional case was used to omit them if present.
Final check to see if due date information is present


# the process_email_list function:
Here items is the list of email id's obtained from IMAP server
m is the IMAP4 object that is used to interact with the mail server or the connection object created in the process_emails function
resp is the response from the server, data is mail data and RFC822 is a retrieval option, means fetch the entire mail in original format
mail = email.message_from_bytes(email_body) creates an email.message.Message object from a bytes-like object
After setting these, the extract_info fnct is applied to the mail object
If the extracted info is not None then the information is collected in key value pairs and saved in a list which is finally returned, otherwise the list remains empty.

# the process_emails function:
Here the necessary variables for connection and login to the email account are set. The connection m is initialized outside the connection try block for proper cleanup in the finally block
m = imaplib.IMAP4_SSL(url, 993) # establish connection with server
m.login(un, pw) # login to specific account
m.select() # when no folder name is provided the default is the inbox
The user is prompted to enter a date.
If possible the entered date is converted to the required format
A check if the entered date is not a future date, if not or valid date format the cycle is broken and the information goes as an input to the details function together with the domain information. If the search criteria returned is not none, the function proceeds to search in the email using the returned search criteria.
resp, items = m.search(None, search_criteria) # None indicates entire mailbox should be searched
resp is server response code, items is string with mail ids
items = items[0].split() is a list of mail ids
The extracted information goes as input to the process_email_list function
Exception handling is used in case there is error during interaction with the server
m.logout() closes the connection with the email server
Eventually, if the extracted list is not none or empty the information is saved as a txt file in the parent working directory. The encoding setting again handles the non-English characters properly