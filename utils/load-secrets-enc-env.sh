echo #!/=$bin/bash

echo "Load secrets into environment variables from env files."
echo "-------------------------------------------------------"

if [ -f $SECRETS_ENC_FILE ]; then
    eval "$(bash ./utils/shdotenv --env <(sops -d $SECRETS_ENC_FILE))" # exports only not existing environment variables from env specific file
    echo "Not yet existing environmet variables succesfully loaded from file $SECRETS_ENC_FILE."
fi
if [ -f $DEFAULT_SECRETS_ENC_FILE ]; then
    eval "$(bash ./utils/shdotenv --env <(sops -d $DEFAULT_SECRETS_ENC_FILE))" # exports only not existing environment variables from .env file
    echo "Not yet existing environmet variables succesfully loaded from file $DEFAULT_SECRETS_ENC_FILE."
fi