#!/bin/bash

# Define the location of the credentials file
CREDENTIALS_FILE="$HOME/.hyperp/credentials"

# Define the API URL
API_URL="https://qfs2hbn1pl.execute-api.us-east-1.amazonaws.com/login"

# Function to log in and save credentials
login() {
  local email=""
  local password=""

  # Parse command-line arguments
  while [[ $# -gt 0 ]]; do
    case "$1" in
      -e | --email)
        email="$2"
        shift
        ;;
      -p | --password)
        password="$2"
        shift
        ;;
      *)
        echo "Usage: hyperp login -e email -p password"
        exit 1
        ;;
    esac
    shift
  done

  # Perform the login request and save credentials
  local response
  response=$(curl -s -X POST -d "email=$email&password=$password" "$API_URL/login")
  echo "response: $resonse"
  if [[ "$response" == *"authentication_key"* ]]; then
    echo "$response" > "$CREDENTIALS_FILE"
    echo "Login successful. Credentials saved to $CREDENTIALS_FILE"
  else
    echo "Login failed. Please check your credentials."
    exit 1
  fi
}

# Function to convert YAML to JSON and send a request
create() {
  local config_file="myconfig.yaml"

  # Check if the credentials file exists
  if [ ! -f "$CREDENTIALS_FILE" ]; then
    echo "Please log in using 'hyperp login' before using 'create' command."
    exit 1
  fi

  # Parse the authentication key from the credentials file
  local auth_key
  auth_key=$(jq -r '.authentication_key' < "$CREDENTIALS_FILE")

  # Convert YAML to JSON
  json_data=$(yq eval . "$config_file")

  # Send a request with the authentication key in the header
  local response
  response=$(curl -s -X POST -H "Authorization: Bearer $auth_key" -d "$json_data" "$API_URL/create")

  # Handle the response as needed
  echo "$response"
}

# Main command parsing
case "$1" in
  login)
    shift
    login "$@"
    ;;
  create)
    create
    ;;
  *)
    echo "Usage: hyperp [login | create]"
    exit 1
    ;;
esac