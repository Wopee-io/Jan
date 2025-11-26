echo #!/=$bin/bash

echo "Load environment variables from env files."
echo "------------------------------------------"

if [ -f $ENV_FILE ]; then
    eval "$(bash ./utils/shdotenv --env $ENV_FILE)" # exports only not existing environment variables from env specific file
    echo "Not yet existing environmet variables succesfully loaded from file $ENV_FILE."
fi
if [ -f $DEFAULT_ENV_FILE ]; then
    eval "$(bash ./utils/shdotenv --env $DEFAULT_ENV_FILE)" # exports only not existing environment variables from .env file
    echo "Not yet existing environmet variables succesfully loaded from file $DEFAULT_ENV_FILE."
fi