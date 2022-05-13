
#!/bin/bash
# Run
# ./0-setup-cluster.sh -e "Azure Environment" -s "Subscription ID or Name" -l "Azure Region" -r "Resource Group Name" -c "AKS CLuster Name" 

while getopts r:e:s:c:l: option
do 
    case "${option}"
        in
        r)resourcegroup=${OPTARG};;
        e)environment=${OPTARG};;
        s)subscription=${OPTARG};;
        c)akscluster=${OPTARG};;
        l)location=${OPTARG};;
    esac
done

az cloud set -n $environment
az account set -s $subscription
az group create --resource-group $resourcegroup --location $location
az aks create --resource-group $resourcegroup --name $akscluster --node-count 1 --enable-addons monitoring --generate-ssh-keys
az aks install-cli
az aks get-credentials --resource-group $resourcegroup --name $akscluster
kubectl get nodes

# Connect to Manage
# kubectl debug node/aks-nodepool1-12345678-vmss000000 -it --image=alpine