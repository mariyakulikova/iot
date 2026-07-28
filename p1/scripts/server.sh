#!/bin/bash
set -euo pipefail

CONFIG_DIRECTORY="/etc/rancher/k3s"
SHARED_TOKEN="/vagrant/.vagrant/k3s-agent-token"

rm -f "$SHARED_TOKEN"

mkdir -p "$CONFIG_DIRECTORY"

cp /vagrant/confs/server.yaml "$CONFIG_DIRECTORY/config.yaml"

chmod 0644 "$CONFIG_DIRECTORY/config.yaml"

curl -sfL https://get.k3s.io | sh -s - --write-kubeconfig-mode 644

timeout 180 bash -c '
    until systemctl is-active --quiet k3s &&
          [ -s /var/lib/rancher/k3s/server/agent-token ]; do
        sleep 2
    done
'

cp /var/lib/rancher/k3s/server/agent-token "$SHARED_TOKEN"

KUBECTL_ALIAS="alias k='kubectl'"
VAGRANT_BASHRC="/home/vagrant/.bashrc"

grep -qxF "$KUBECTL_ALIAS" "$VAGRANT_BASHRC" || echo "$KUBECTL_ALIAS" >> "$VAGRANT_BASHRC"