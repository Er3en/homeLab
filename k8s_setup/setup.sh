#!/bin/bash

set -euo pipefail

TERRAFORM_DIR="terraform"
ANSIBLE_DIR="ansible"
INVENTORY_FILE="inventory.ini"
PRIVATE_KEY="$HOME/.ssh/id_rsa"
ANSIBLE_USER="ubuntu"

echo "[INFO] Running Terraform..."
cd "$TERRAFORM_DIR"
terraform init -input=false
terraform apply -auto-approve || {
  echo "[ERROR] Terraform apply failed. Destroying resources..."
  terraform destroy -auto-approve
  exit 1
}

echo "[INFO] Fetching public IPs from Terraform output..."
IPS=$(terraform output -json public_ips | jq -r '.[]')

if [[ -z "$IPS" ]]; then
  echo "[ERROR] No IPs received from Terraform output!"
  terraform destroy -auto-approve
  exit 1
fi

echo "[DEBUG] Extracted IPs:"
echo "$IPS"

cd "../$ANSIBLE_DIR" || exit

echo "[INFO] Creating Ansible inventory file..."
rm -f "$INVENTORY_FILE"
echo "[all]" > "$INVENTORY_FILE"

echo "[INFO] Adding hosts to inventory and known_hosts..."
set +e  # temporarily allow non-breaking errors
for ip in $IPS; do
  echo "$ip" >> "$INVENTORY_FILE"
  ssh-keygen -R "$ip" >/dev/null 2>&1 || true
  ssh-keyscan -H "$ip" >> ~/.ssh/known_hosts 2>/dev/null || true
done
set -e

echo "[DEBUG] Inventory and known_hosts setup complete ✅"

if [ ! -f playbook.yml ]; then
  echo "[ERROR] Missing playbook.yml in ansible directory!"
  cd "../$TERRAFORM_DIR"
  terraform destroy -auto-approve
  exit 1
fi

echo "[INFO] Waiting 60s for EC2 instances to boot..."
sleep 60

# Check if SSH key is already loaded
if ! ssh-add -L | grep -q "$(ssh-keygen -lf "$PRIVATE_KEY" | awk '{print $2}')" 2>/dev/null; then
  echo "[INFO] Adding SSH key to ssh-agent..."
  eval "$(ssh-agent -s)"
  ssh-add "$PRIVATE_KEY" || {
    echo "[ERROR] Could not add private key. Check passphrase."
    exit 1
  }
fi

echo "[INFO] Running Ansible playbook..."
ANSIBLE_HOST_KEY_CHECKING=False \
ansible-playbook -i "$INVENTORY_FILE" -u "$ANSIBLE_USER" --private-key "$PRIVATE_KEY" playbook.yml || {
  echo "[ERROR] Ansible playbook failed. Cleaning up..."
  cd "../$TERRAFORM_DIR"
  terraform destroy -auto-approve
  exit 1
}

echo "[SUCCESS ✅] EC2 instances configured via Ansible successfully!"
