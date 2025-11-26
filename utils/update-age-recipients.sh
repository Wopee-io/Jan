#!/bin/bash

for folder in default battle.wopee.io
do
    # load default public keys from ./SOPS_AGE_RECIPIENTS
    # concatenate files using new line as a separator | remove empty lines | replace new lines with commas | remove trailing comma
    export SOPS_AGE_RECIPIENTS="$(sed -e '$s/$/\n/' ./SOPS_AGE_RECIPIENTS/*.txt | sed '/^$/d' | tr '\n' ',' | sed 's/,$//')"
    # load additional public keys from ./environment/dev.wopee.io/additional_SOPS_AGE_RECIPIENTS
    export SOPS_AGE_RECIPIENTS="$SOPS_AGE_RECIPIENTS,$(sed -e '$s/$/\n/' ./deployment/$folder/additional_SOPS_AGE_RECIPIENTS/*.txt | sed '/^$/d' | tr '\n' ',' | sed 's/,$//')"

    sops -d -i ./deployment/$folder/secrets.enc.env
    sops -e -i ./deployment/$folder/secrets.enc.env

done