#!/bin/bash

source /var/snap/microstack/common/etc/microstack.rc
export OS_CACERT=""
export PYTHONWARNINGS="ignore"

METRICS_FILE="/var/lib/prometheus/node-exporter/openstack.prom"
COUNTER_FILE="/var/lib/prometheus/node-exporter/counters.txt"
STATE_FILE="/var/lib/prometheus/node-exporter/states.txt"

sudo mkdir -p /var/lib/prometheus/node-exporter

VMS=("vm-web-1" "vm-web-2" "vm-monitor")

if [ ! -f "$COUNTER_FILE" ]; then
  for VM in "${VMS[@]}"; do
    echo "$VM=0" | sudo tee -a $COUNTER_FILE
  done
fi

if [ ! -f "$STATE_FILE" ]; then
  for VM in "${VMS[@]}"; do
    echo "$VM=ACTIVE" | sudo tee -a $STATE_FILE
  done
fi

{
echo "# HELP openstack_vm_status Status des VMs OpenStack"
echo "# TYPE openstack_vm_status gauge"
echo "# HELP openstack_vm_failures Nombre de pannes par VM"
echo "# TYPE openstack_vm_failures counter"

for VM in "${VMS[@]}"; do
  COUNT=$(grep "^$VM=" $COUNTER_FILE | cut -d= -f2)
  PREV_STATE=$(grep "^$VM=" $STATE_FILE | cut -d= -f2)
  VM_EXISTS=$(sudo microstack.openstack server list -f value -c Name | grep -w "$VM")

  if [ -z "$VM_EXISTS" ]; then
    echo "openstack_vm_status{vm=\"$VM\"} 0"
    if [ "$PREV_STATE" != "DOWN" ]; then
      COUNT=$((COUNT + 1))
      sudo sed -i "s/^$VM=.*/$VM=$COUNT/" $COUNTER_FILE
      sudo sed -i "s/^$VM=.*/$VM=DOWN/" $STATE_FILE
    fi
  else
    STATUS=$(sudo microstack.openstack server show "$VM" -f value -c status)
    if [ "$STATUS" == "ACTIVE" ]; then
      echo "openstack_vm_status{vm=\"$VM\"} 1"
      sudo sed -i "s/^$VM=.*/$VM=ACTIVE/" $STATE_FILE
    else
      echo "openstack_vm_status{vm=\"$VM\"} 0"
      if [ "$PREV_STATE" != "DOWN" ]; then
        COUNT=$((COUNT + 1))
        sudo sed -i "s/^$VM=.*/$VM=$COUNT/" $COUNTER_FILE
        sudo sed -i "s/^$VM=.*/$VM=DOWN/" $STATE_FILE
      fi
    fi
  fi

  echo "openstack_vm_failures{vm=\"$VM\"} $COUNT"
done
} | sudo tee $METRICS_FILE






































































