
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
    esac
done

az cloud set -n $environment
az account set -s $subscription
az aks delete --resource-group $resourcegroup --name $akscluster --no-wait