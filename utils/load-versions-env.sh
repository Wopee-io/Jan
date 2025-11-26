echo #!/=$bin/bash

echo "Load versions into environment variables from env files."
echo "--------------------------------------------------------"

if [ -f $VERSIONS_ENV_FILE ]; then
    eval "$(bash ./utils/shdotenv --env $VERSIONS_ENV_FILE)" # exports only not existing environment variables from env specific file
    echo "Not yet existing environmet variables succesfully loaded from file $VERSIONS_ENV_FILE."
fi

if [ -f $DEFAULT_VERSIONS_ENV_FILE ]; then
    eval "$(bash ./utils/shdotenv --env $DEFAULT_VERSIONS_ENV_FILE)" # exports only not existing environment variables from .env file
    echo "Not yet existing environmet variables succesfully loaded from file $DEFAULT_VERSIONS_ENV_FILE."
fi