# Run:
# Run ./2-configure-secrets.enc.yaml.sh -u "IronBank Username" -p "IronBank Password"
#!/bin/bash

while getopts u:p: option
do 
    case "${option}"
        in
        u)ironbankusername=${OPTARG};;
        p)ironbankpassword=${OPTARG};;
    esac
done

cd base

# Encrypt the existing certificate
cp bigbang-dev-cert.yaml secrets.enc.yaml.temp
sed -i "s/username: IRONBANK_USER/username: $ironbankusername/" secrets.enc.yaml.temp
sed -i "s/password: IRONBANK_PASSWORD/password: $ironbankpassword/" secrets.enc.yaml.temp
sops -e secrets.enc.yaml.temp > secrets.enc.yaml
rm secrets.enc.yaml.temp

# Save encrypted TLS certificate into Git
git add secrets.enc.yaml
git commit -m "chore: add bigbang.dev tls certificates"
git push
