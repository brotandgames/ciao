# SMTP Configuration

Following is a list of all possible configuration variables.

````
SMTP_ADDRESS=smtp.yourhost.com
SMTP_EMAIL_FROM="ciao@yourhost.com"
SMTP_EMAIL_TO="you@yourhost.com"
SMTP_PORT=587
SMTP_DOMAIN=smtp.yourhost.com
SMTP_AUTHENTICATION=plain
SMTP_ENABLE_STARTTLS_AUTO=true
SMTP_USERNAME=ciao
SMTP_PASSWORD="sensitive_password"
SMTP_SSL=true
````

## Notes

* When `SMTP_ADDRESS` variable is not set no e-mail notifications are sent
* You can send emails to several addresses by separating them with a comma eg. `SMTP_EMAIL_TO="a@yourhost.com,b@yourhost.com"`

## Example configurations

### Gmail

Don’t forget to change `you@gmail.com` to your email address and `sensitive_password` to your own password.

If you encounter authentication errors, ensure you have allowed less secure apps to access the account.

````
SMTP_ADDRESS=smtp.gmail.com
SMTP_EMAIL_FROM="you@gmail.com"
SMTP_EMAIL_TO="you@yourhost.com"
SMTP_PORT=587
SMTP_DOMAIN=smtp.yourhost.com
SMTP_AUTHENTICATION=plain
SMTP_ENABLE_STARTTLS_AUTO=true
SMTP_USERNAME="you@gmail.com"
SMTP_PASSWORD="sensitive_password"
````

### Sendgrid

Port 587 (STARTTLS)

````
SMTP_ADDRESS=smtp.sendgrid.net
SMTP_EMAIL_FROM="ciao@yourhost.com"
SMTP_EMAIL_TO="you@yourhost.com"
SMTP_PORT=587
SMTP_DOMAIN=smtp.yourhost.com
SMTP_AUTHENTICATION=plain
SMTP_ENABLE_STARTTLS_AUTO=true
SMTP_USERNAME=ciao
SMTP_PASSWORD="sensitive_password"
````

Port 465 (explicit SSL/TLS)

````
SMTP_ADDRESS=smtp.sendgrid.net
SMTP_EMAIL_FROM="ciao@yourhost.com"
SMTP_EMAIL_TO="you@yourhost.com"
SMTP_PORT=465
SMTP_DOMAIN=smtp.yourhost.com
SMTP_AUTHENTICATION=plain
SMTP_ENABLE_STARTTLS_AUTO=true
SMTP_USERNAME=ciao
SMTP_PASSWORD="sensitive_password"
SMTP_SSL=true
````

