#!/bin/bash

# Step 1: Set Variables (Change these as needed)
RESOURCE_GROUP="mlflow-rg"
LOCATION="eastus"
VM_NAME="mlflow-vm"
VM_USER="azureuser"
STORAGE_ACCOUNT="mlflowstorage$RANDOM"
CONTAINER_NAME="mlflow-artifacts"

# Step 2: Create Resource Group
echo "Creating Resource Group: $RESOURCE_GROUP"
az group create --name $RESOURCE_GROUP --location $LOCATION

# Step 3: Create Storage Account and Container
echo "Creating Storage Account: $STORAGE_ACCOUNT"
az storage account create \
  --name $STORAGE_ACCOUNT \
  --resource-group $RESOURCE_GROUP \
  --location $LOCATION \
  --sku Standard_LRS

# Get storage account key
STORAGE_KEY=$(az storage account keys list \
  --account-name $STORAGE_ACCOUNT \
  --resource-group $RESOURCE_GROUP \
  --query "[0].value" -o tsv)

# Create blob container for MLflow artifacts
echo "Creating Blob Container: $CONTAINER_NAME"
az storage container create \
  --account-name $STORAGE_ACCOUNT \
  --name $CONTAINER_NAME \
  --public-access off \
  --account-key $STORAGE_KEY

# Step 4: Create Virtual Machine (Ubuntu)
echo "Creating VM: $VM_NAME"
az vm create \
  --name $VM_NAME \
  --resource-group $RESOURCE_GROUP \
  --image Ubuntu2204 \
  --admin-username $VM_USER \
  --generate-ssh-keys \
  --size Standard_B1s \
  --output json

# Step 5: Open port 5000 to access MLflow UI
echo "Opening port 5000 for MLflow UI"
az vm open-port \
  --port 5000 \
  --resource-group $RESOURCE_GROUP \
  --name $VM_NAME

# Step 6: Get the Public IP of the VM
VM_IP=$(az vm show \
  --name $VM_NAME \
  --resource-group $RESOURCE_GROUP \
  --show-details \
  --query "publicIps" \
  -o tsv)

echo "✅ VM created successfully. Public IP: $VM_IP"
echo "SSH into the VM using: ssh $VM_USER@$VM_IP"

# Step 7: Create SSH Command to Install MLflow & Start Server
SSH_COMMAND="
  # Update the system and install Python, pip, and MLflow
  sudo apt update && sudo apt install -y python3-pip
  
  # Install MLflow and Azure Blob support
  pip3 install mlflow azure-storage-blob
  
  # Export Azure Blob Storage connection string
  export AZURE_STORAGE_CONNECTION_STRING='DefaultEndpointsProtocol=https;AccountName=$STORAGE_ACCOUNT;AccountKey=$STORAGE_KEY;EndpointSuffix=core.windows.net'
  
  # Start MLflow server
  mlflow server --host 0.0.0.0 --port 5000 --backend-store-uri sqlite:///mlflow.db --default-artifact-root wasbs://$CONTAINER_NAME@$STORAGE_ACCOUNT.blob.core.windows.net/
"

# Step 8: Output the SSH command to run in the VM
echo "To set up MLflow, SSH into your VM and run the following commands:"
echo "$SSH_COMMAND"

# Step 9: Open the MLflow UI
echo "🌐 Access the MLflow UI at: http://$VM_IP:5000"

