#!/usr/bin/python

import smtplib
from email.MIMEText import MIMEText

GMAIL_LOGIN = '__me__@gmail.com'
GMAIL_PASSWORD = '__secret__'
TO_EMAIL = '__you__@gmail.com'

def send_email(subject, message,to_addr=GMAIL_LOGIN,from_addr=GMAIL_LOGIN):
    msg = MIMEText(message)
    msg['Subject'] = subject
    msg['From'] = from_addr
    msg['To'] = to_addr

    server = smtplib.SMTP('smtp.gmail.com',587) #port 465 or 587
    server.ehlo()
    server.starttls()
    server.ehlo()
    server.login(GMAIL_LOGIN,GMAIL_PASSWORD)
    server.sendmail(from_addr, to_addr, msg.as_string())
    server.close()

if __name__=="__main__":
    send_email('test', 'This is a test email', TO_EMAIL)
