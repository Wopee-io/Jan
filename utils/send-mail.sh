#!/bin/bash

# EMAIL_SMTP_HOST='smtp-relay.brevo.com'
# EMAIL_SMTP_PORT='465'
# EMAIL_USERNAME='7c7747001@smtp-brevo.com'
# EMAIL_PASSWORD='...'
# EMAIL_FROM='infra@wopee.io'
# EMAIL_FROM_NAME='Wopee.io Infra'
# EMAIL_REPLY_TO='jan.beranek@wopee.io'

# EMAIL_TO='honza@beranku.cz'
# EMAIL_SUBJECT='Nice final version'
# EMAIL_BODY_TEXT='First line text.\nSecond line text.'
# EMAIL_BODY_HTML_FILENAME='email_body.html'

echo "$EMAIL_BODY_TEXT" > "email_body.txt"

echo "sending ...."
curl --ssl-reqd --url "smtps://$EMAIL_SMTP_HOST:$EMAIL_SMTP_PORT" \
    --user "$EMAIL_USERNAME:$EMAIL_PASSWORD" \
    --mail-from "$EMAIL_FROM" \
    --mail-rcpt "$EMAIL_TO" \
    --mail-rcpt-allowfails \
    --header "Subject: $EMAIL_SUBJECT" \
    --header "From: $EMAIL_FROM_NAME <$EMAIL_FROM>" \
    --header "Reply-to: $EMAIL_REPLY_TO" \
    --header "To: $EMAIL_TO" \
    -F "=(;type=multipart/alternative" \
    -F "=<email_body.txt;encoder=quoted-printable" \
    -F "=<$EMAIL_BODY_HTML_FILENAME;encoder=quoted-printable" \
    -F "=)"
    # -F "=@files.zip;encoder=base64"