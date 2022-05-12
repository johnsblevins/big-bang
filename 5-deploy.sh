# read ironbankusername
# read ironbankpassword
# read repousername
# read repopassword

#!/bin/bash

while getopts n:c: option
do 
    case "${option}"
        in
        u)ironbankusername=${OPTARG};;
        p)ironbankpassword=${OPTARG};;
        x)repousername=${OPTARG};;
        y)repopassword=${OPTARG};;
    esac
done

# The private key is not stored in Git (and should NEVER be stored there).  We deploy it manually by exporting the key into a secret.
kubectl create namespace bigbang
gpg --export-secret-key --armor ${fp} | kubectl create secret generic sops-gpg -n bigbang --from-file=bigbangkey.asc=/dev/stdin

# Image pull secrets for Iron Bank are required to install flux.  After that, it uses the pull credentials we installed above
kubectl create namespace flux-system

# Adding a space before this command keeps our PAT out of our history
 kubectl create secret docker-registry private-registry --docker-server=registry1.dso.mil --docker-username=$ironbankusername --docker-password=$ironbankpassword -n flux-system

 # Flux needs the Git credentials to access your Git repository holding your environment
# Adding a space before this command keeps our PAT out of our history
 kubectl create secret generic private-git --from-literal=username=$repousername --from-literal=password=$repopassword -n bigbang

# Flux is used to sync Git with the the cluster configuration
# If you are using a different version of Big Bang, make sure to update the `?ref=1.33.0` to the correct tag or branch.
kustomize build https://repo1.dso.mil/platform-one/big-bang/bigbang.git//base/flux?ref=1.33.0 | kubectl apply -f -

# Wait for flux to complete
kubectl get deploy -o name -n flux-system | xargs -n1 -t kubectl rollout status -n flux-system

kubectl apply -f bigbang.yaml

# Verify 'bigbang' namespace is created
kubectl get namespaces

# Verify Pull from Git was successful
kubectl get gitrepositories -A

# Verify Kustomization was successful
# NOTE: The Kustomization resource may fail at first with an error about the istio-system namespace.  This is normal since the Helm Release for istio will create that namespace and it has not run yet.  This should resolve itself within a few minutes
kubectl get -n bigbang kustomizations

# Verify secrets and configmaps are deployed
# At a minimum, you will have the following:
#  secrets: sops-gpg, private-git, common-bb, and environment-bb
#  configmaps: common, environment
kubectl get -n bigbang secrets,configmaps

# Watch deployment
watch kubectl get hr,po -A
