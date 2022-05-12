cd base

# Encrypt the existing certificate
sops -e bigbang-dev-cert.yaml > secrets.enc.yaml

# Save encrypted TLS certificate into Git
git add secrets.enc.yaml
git commit -m "chore: add bigbang.dev tls certificates"
git push
