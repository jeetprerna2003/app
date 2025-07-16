#!/bin/bash
# This script is executed once when the container is created.

set -e # Exit immediately if a command exits with a non-zero status.

echo "Updating package list and installing prerequisites..."
sudo apt-get update
sudo apt-get install -y curl apt-transport-https

echo "Adding Microsoft ODBC repository..."
curl https://packages.microsoft.com/keys/microsoft.asc | sudo apt-key add -
curl https://packages.microsoft.com/config/debian/11/prod.list | sudo tee /etc/apt/sources.list.d/mssql-release.list

echo "Installing Microsoft ODBC Driver for SQL Server..."
sudo apt-get update

# --- KEY CHANGE IS HERE ---
# Instead of hardcoding packages, we read them from packages.txt
# This ensures the dev environment matches the Streamlit Cloud deployment environment.
if [ -f "packages.txt" ]; then
    echo "Found packages.txt. Installing system-level packages..."
    # The 'ACCEPT_EULA' part is crucial for a non-interactive install of msodbcsql18
    # We use 'xargs' to pass the contents of the file to apt-get
    sudo ACCEPT_EULA=Y apt-get install -y $(cat packages.txt)
else
    echo "Warning: packages.txt not found. Skipping system package installation."
fi

echo "Installing Python packages from requirements.txt..."
if [ -f "requirements.txt" ]; then
    echo "Found requirements.txt. Installing packages..."
    pip install --no-cache-dir -r "requirements.txt"
else
    echo "Warning: requirements.txt not found in the project root. Skipping Python package installation."
fi

echo "✅ Environment setup complete!"
