#!/bin/sh

# Generate a random string
random_string=$(head /dev/urandom | tr -dc A-Za-z0-9 | head -c 32)

# Perform substitution using sed
sed "s/key: ''/key: $random_string/g" /config.yaml > /tmp/temp_config.yaml

# Copy the content of the temporary file back to the original file
cat /tmp/temp_config.yaml > /config.yaml

# Remove the temporary file
rm /tmp/temp_config.yaml
