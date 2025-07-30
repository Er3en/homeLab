#!/bin/zsh

set -e
if ! command -v terraform &> /dev/null; then
    echo "[ERROR] Terraform is not installed. Please install Terraform and try again."
    exit 1
fi
if ! command -v ansible &> /dev/null; then
    echo "[ERROR] Ansible is not installed. Please install Ansible and try again."
    exit 1
fi
if ! command -v jq &> /dev/null; then
    echo "[ERROR] jq is not installed. Please install jq and try again."
    exit 1
fi

echo "[INFO] Running Terraform..."
cd terraform || exit
terraform init
terraform apply -auto-approve

echo "[INFO] Creating Ansible inventory..."
cd ../ansible || exit
rm -f inventory.ini
echo "[all]" > inventory.ini
terraform -chdir=../terraform output -json public_ips | jq -r '.[] | .[]' >> inventory.ini

echo "[INFO] Running Ansible Playbook..."
ansible-playbook -i inventory.ini -u ubuntu --private-key ~/.ssh/id_rsa playbook.yml
