#!/bin/bash

source /var/snap/microstack/common/etc/microstack.rc
export OS_CACERT=""
export PYTHONWARNINGS="ignore"

VMS=("vm-web-1" "vm-web-2" "vm-monitor")
LOGFILE="/var/log/autoheal.log"


log() {
  echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" | tee -a $LOGFILE
}

check_and_heal() {
  for VM in "${VMS[@]}"; do

    # Vérifier si la VM existe
    VM_EXISTS=$(sudo microstack.openstack server list -f value -c Name | grep -w "$VM")

    if [ -z "$VM_EXISTS" ]; then
      log "$VM n'existe pas - Attente avant recréation..."
      sleep 90
      log "$VM - Recréation via Terraform..."
      cd /home/hiba/cloud-autoheal/terraform
      export OS_AUTH_URL="https://10.20.20.1:5000/v3"
      export OS_USERNAME="admin"
      export OS_PASSWORD="$(sudo snap get microstack config.credentials.keystone-password)"
      export OS_PROJECT_NAME="admin"
      export OS_REGION_NAME="microstack"
      export OS_IDENTITY_API_VERSION=3
      export TF_VAR_insecure=true
      terraform apply -auto-approve >> $LOGFILE 2>&1
      log "$VM recréée via Terraform"
      continue
    fi

    STATUS=$(sudo microstack.openstack server show "$VM" -f value -c status)

    if [ "$STATUS" == "ACTIVE" ]; then
      log " $VM est en bon état (ACTIVE)"

    elif [ "$STATUS" == "SHUTOFF" ]; then
      log " WARNING - $VM éteinte (SHUTOFF) - Attente avant réparation..."
      sleep 90
      log " Démarrage de $VM..."
      sudo microstack.openstack server start "$VM"
      sleep 15
      NEW_STATUS=$(sudo microstack.openstack server show "$VM" -f value -c status)
      if [ "$NEW_STATUS" == "ACTIVE" ]; then
        log " $VM démarrée avec succes"
      else
        log " $VM toujours en panne (status: $NEW_STATUS)"
      fi

    elif [ "$STATUS" == "ERROR" ]; then
      log " $VM en ERROR - Rebuild en cours..."
      sudo microstack.openstack server rebuild "$VM" --image cirros
      log " $VM rebuild lancé"

    else
      log " $VM status inconnu: $STATUS"
    fi
  done
}

log "== Début du cycle Auto-Healing =="
check_and_heal
log "== fin du cycle =="
