gpg --batch --full-generate-key --rfc4880 --digest-algo sha512 --cert-digest-algo sha512 <<EOF
    %no-protection
    # %no-protection: means the private key won't be password protected
    # (no password is a fluxcd requirement, it might also be true for argo & sops)
    Key-Type: RSA
    Key-Length: 4096
    Subkey-Type: RSA
    Subkey-Length: 4096
    Expire-Date: 0
    Name-Real: bigbang-dev-environment
    Name-Comment: bigbang-dev-environment
EOF

export fp=$(gpg --list-keys --fingerprint | grep "bigbang-dev-environment" -B 1 | grep -v "bigbang-dev-environment" | tr -d ' ' | tr -d 'Keyfingerprint=')
echo $fp

# The above command will make a key that doesn't expire
# You can optionally run the following if you need the key to expire after 1 year.
gpg --quick-set-expire ${fp} 1y

# cd to the location of the .sops.yaml, then run the following to set the encryption key
# sed: stream editor is like a cli version of find and replace
# This ensures your secrets are only decryptable by your key

## On linux
sed -i "s/pgp: FALSE_KEY_HERE/pgp: ${fp}/" .sops.yaml

## On MacOS
sed -i "" "s/pgp: FALSE_KEY_HERE/pgp: ${fp}/" .sops.yaml

# Save encrypted secrets into Git
# Configuration changes must be stored in Git to take affect
git add .sops.yaml
git commit -m "chore: update default encryption key"
git push --set-upstream origin template-demo
