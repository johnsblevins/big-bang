# Run:
# Run ./3-configure-bigbang.yaml.sh -u "GitHub Repo URL" -b "GitHub Branch"
#!/bin/bash

while getopts u:b: option
do 
    case "${option}"
        in
        u)repourl=${OPTARG};;
        b)repobranch=${OPTARG};;
    esac
done

cd dev

# Encrypt the existing certificate
cp bigbang.yaml.original bigbang.yaml
sed -i "s#url: https://replace-with-your-git-repo.git#url: ${repourl}#" bigbang.yaml
sed -i "s#branch: replace-with-your-branch#branch: $repobranch#" bigbang.yaml

git add bigbang.yaml
git commit -m "chore: updated git repo"
git push
