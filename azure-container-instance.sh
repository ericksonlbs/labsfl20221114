#!/bin/sh

# Change these four parameters as needed
ACI_PERS_RESOURCE_GROUP=labsfl20221114VM
ACI_PERS_STORAGE_ACCOUNT_NAME=labsfl20221114storage
ACI_PERS_LOCATION=eastus
ACI_PERS_SHARE_NAME=container

#STORAGE_KEY=w7VhOzLUGCcDLDvXCE3HGDnbJNuS9oiSDzzHpjBeEN8WceFGxqF2XVzt4uGdo36wOMvjAfrbU23R+CDtG2hHUw==

# Create the storage account with the parameters
az storage account create \
    --resource-group $ACI_PERS_RESOURCE_GROUP \
    --name $ACI_PERS_STORAGE_ACCOUNT_NAME \
    --location $ACI_PERS_LOCATION \
    --sku Standard_LRS

# Create the file share
az storage share create \
  --name $ACI_PERS_SHARE_NAME \
  --account-name $ACI_PERS_STORAGE_ACCOUNT_NAME

az container create \
    --resource-group $ACI_PERS_RESOURCE_GROUP \
    --name labsfl20221114 \
    --image ericksonlbs/labsfl20221114:latest \
    --dns-name-label labsfl20221114-aci \
    --ports 80 \
    --azure-file-volume-account-name $ACI_PERS_STORAGE_ACCOUNT_NAME \
    --azure-file-volume-account-key $STORAGE_KEY \
    --azure-file-volume-share-name $ACI_PERS_SHARE_NAME \
    --azure-file-volume-mount-path /labsfl20221114/test/ \
	--cpu 2 \
	--memory 8