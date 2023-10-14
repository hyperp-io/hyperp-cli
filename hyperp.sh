#!/bin/bash

# Define the location of the credentials file
CREDENTIALS_FILE="$HOME/.hyperp/credentials"

# Define the API URL
API_URL="https://qfs2hbn1pl.execute-api.us-east-1.amazonaws.com"

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
  response=$(curl -s -X POST -H "Content-Type: application/json" -d "{\"email\":\"$email\",\"password\":\"$password\"}" "$API_URL/login")
  echo "login response: $response"


   # Check if the login was successful
  if [[ "$response" == *"data"* && "$response" == *"auth"* ]]; then
    mkdir -p "$HOME/.hyperp"
    # Extract the authentication key from the response
    auth_key=$(echo "$response" | jq -r '.data.auth')
    
    # Save the authentication key to the credentials file
    echo "{\"authentication_key\":\"$auth_key\"}" > "$CREDENTIALS_FILE"
    echo "Login successful. Authentication key saved to $CREDENTIALS_FILE"
  else
    echo "Login failed. Please check your credentials."
    exit 1
  fi
}

# Function to convert YAML to JSON and send a request
create() {
  local config_file=""

  # Parse command-line arguments
  while [[ $# -gt 0 ]]; do
    case "$1" in
      -f | --file)
        config_file="$2"
        shift
        ;;
      *)
        echo "Usage: hyperp create -f /path/to/config.yaml"
        exit 1
        ;;
    esac
    shift
  done

  # Check if the credentials file exists
  if [ ! -f "$CREDENTIALS_FILE" ]; then
    echo "Please log in using 'hyperp login' before using 'create' command."
    exit 1
  fi

  # Parse the authentication key from the credentials file
  local auth_key
  auth_key=$(jq -r '.authentication_key' < "$CREDENTIALS_FILE")
  # Ensure the config file exists
  if [ ! -f "$config_file" ]; then
    echo "The specified config file does not exist."
    exit 1
  fi
  # Convert YAML to JSON
  json_data=$(yq eval . "$config_file")
  echo "json data: $json_data"
  # Send a request with the authentication key in the header
  local response
  response=$(curl -s -X POST  -H "Content-Type: application/json" -H "Authorization: Bearer $auth_key" -d "$json_data" "$API_URL/create")

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