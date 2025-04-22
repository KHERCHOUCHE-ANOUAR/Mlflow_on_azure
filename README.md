# MLflow + Azure: Water Quality Regression with ElasticNet

This project demonstrates how to deploy an MLflow tracking server on Azure and log an ElasticNet regression model that predicts water quality. It includes experiment tracking, model logging, and optional Azure Blob Storage integration.

---

## 🚀 What You Get

- 📈 MLflow Tracking Server hosted on an Azure VM
- ☁️ Azure Blob Storage for artifact logging (optional)
- 🔧 Python training script with ElasticNet regression
- ✅ Logs parameters, metrics, and models using MLflow

---

## 🧰 Prerequisites

- Azure CLI installed
- Conda (for environment setup)
- Run `bash setup_env.sh` to create a conda environment
- Run `pip install -r requirements.txt` to install the required Python dependencies

---

## 🏗️ Steps to Deploy MLflow on Azure

### 1. Create Azure Resources

#### ➤ Create a resource group and other resources:

Run the following setup script to create the Azure resources:

```bash
bash setup_azure.sh
```

This script will:
1. Create Azure ResourcesCreate a resource group
2. Set up a storage account and blob container
3. Create a virtual machine
4. Open port 5000 for MLflow UI access

## 2. Setup MLflow on the VM

#### ➤ SSH into the VM

After the resources are created, SSH into the VM:

```bash
ssh azureuser@<VM_PUBLIC_IP>
```

#### ➤ Install Python packages
Inside the VM, install the necessary Python packages:
```bash
sudo apt update && sudo apt install -y python3-pip
pip3 install --user "mlflow[extras]" azure-storage-blob scikit-learn pandas
echo 'export PATH=$PATH:~/.local/bin' >> ~/.bashrc && source ~/.bashrc
```
#### ➤ Export the Azure Blob connection string
To set up the connection to Azure Blob Storage, run:
```bash
export AZURE_STORAGE_CONNECTION_STRING="DefaultEndpointsProtocol=https;AccountName=<STORAGE_ACCOUNT>;AccountKey=<STORAGE_KEY>;EndpointSuffix=core.windows.net"
```
#### ➤ Run the MLflow tracking server
Start the MLflow tracking server on the VM:
```bash
mlflow server \
  --host 0.0.0.0 \
  --port 5000 \
  --backend-store-uri sqlite:///mlflow.db \
  --default-artifact-root wasbs://mlflow-artifacts@<STORAGE_ACCOUNT>.blob.core.windows.net/
```
#### ➤Access the MLflow UI at:
```bash
http://<VM_PUBLIC_IP>:5000
```
## 3. Run the Training Script from Local
#### ➤ Run the script
On your local machine, run the training script with the desired hyperparameters:

```bash
python train.py 0.5 0.5
```
This will:
1. Use the hosted MLflow tracking server
2. Log alpha, l1_ratio, rmse, mae, r2
3. Save and register the trained model remotely

## 4. Cleanup
```bash
az group delete --name mlflow-rg --yes --no-wait
```

## 📂 Project Structure
```bash
.
├── app.py              # ElasticNet training script with MLflow logging
├── README.md           # This file
├── requirements.txt    # Python dependencies
├── setup_azure.sh      # Azure resource creation script
├── setup_env.sh        # Conda environment setup script
```