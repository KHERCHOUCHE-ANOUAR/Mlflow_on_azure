#!/bin/bash

# Name of the conda environment
ENV_NAME="my_env"
PYTHON_VERSION="3.10"

# Path to your requirements file (change this if needed)
REQUIREMENTS_FILE="requirements.txt"

# Check if conda is installed
if ! command -v conda &> /dev/null
then
    echo "❌ Conda could not be found. Please install Anaconda or Miniconda first."
    exit 1
fi

# Check if the environment already exists
if conda info --envs | grep -q "^$ENV_NAME\s"; then
    echo "⚠️  Conda environment '$ENV_NAME' already exists."
    read -p "❓ Do you want to delete and recreate it? (y/n): " choice
    if [[ "$choice" == "y" || "$choice" == "Y" ]]; then
        echo "🗑️  Deleting existing environment '$ENV_NAME'..."
        conda remove -y -n "$ENV_NAME" --all
    else
        echo "✅ Keeping the existing environment. Exiting setup."
        exit 0
    fi
fi

# Create the conda environment
echo "🚀 Creating Conda environment '$ENV_NAME' with Python $PYTHON_VERSION..."
conda create -y -n "$ENV_NAME" python="$PYTHON_VERSION"



# Check if requirements.txt exists
if [ ! -f "$REQUIREMENTS_FILE" ]; then
    echo "⚠️  Requirements file '$REQUIREMENTS_FILE' not found!"
    exit 1
fi

# Install dependencies
echo "📦 Installing dependencies from $REQUIREMENTS_FILE..."
pip install -r "$REQUIREMENTS_FILE"
echo "⚠️  To activate the environment in your current shell, run:"
echo "    conda activate $ENV_NAME"

echo "✅ Environment setup complete!"