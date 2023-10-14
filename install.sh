#!/bin/bash

# Define the installation directory for the 'hyperp' script
INSTALL_DIR="/usr/local/bin"

# URL to the 'hyperp' script
HYPERP_SCRIPT_URL="https://raw.githubusercontent.com/hyperp-io/hyperp-cli/master/hyperp.sh"

# Define a list of necessary dependencies
DEPENDENCIES=("yaml2json" "jq")

# Function to install a dependency
install_dependency() {
  local dependency="$1"
  if ! command -v "$dependency" &>/dev/null; then
    echo "Installing $dependency..."
    if [[ "$dependency" == "jq" ]]; then
      wget https://github.com/mikefarah/yq/releases/latest/download/yq_linux_amd64 -O /usr/bin/yq &&\ chmod +x /usr/bin/yq
    fi
  else
    echo "$dependency is already installed."
  fi
}

# Function to install the 'hyperp' script
install_hyperp() {
  curl -o "$INSTALL_DIR/hyperp" -fsSL "$HYPERP_SCRIPT_URL"
  chmod +x "$INSTALL_DIR/hyperp"
}

# Function to uninstall the 'hyperp' script
uninstall_hyperp() {
  if [ -f "$INSTALL_DIR/hyperp" ]; then
    echo "Uninstalling the 'hyperp' script..."
    rm -f "$INSTALL_DIR/hyperp"
    echo "Uninstallation complete."
  else
    echo "The 'hyperp' script is not installed."
  fi
}

# Check if the script is run with the uninstall argument
if [ "$1" == "uninstall" ]; then
  uninstall_hyperp
else
  # Check and install necessary dependencies
  for dep in "${DEPENDENCIES[@]}"; do
    install_dependency "$dep"
  done

  # Check if the 'hyperp' script already exists, if not, install it
  if [ -f "$INSTALL_DIR/hyperp" ]; then
    echo "The 'hyperp' script is already installed."
  else
    echo "Installing the 'hyperp' script..."
    install_hyperp
    echo "Installation complete. You can now use 'hyperp login' and 'hyperp create'."
  fi
fi
