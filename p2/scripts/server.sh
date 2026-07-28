#!/bin/bash
set -euo pipefail

export DEBIAN_FRONTEND=noninteractive

apt-get update
apt-get install -y curl ca-certificates

CONFIG_DIRECTORY="/etc/rancher/k3s"

mkdir -p "$CONFIG_DIRECTORY"

cp /vagrant/confs/server.yaml "$CONFIG_DIRECTORY/config.yaml"

chmod 0600 "$CONFIG_DIRECTORY/config.yaml"

curl -sfL https://get.k3s.io | sh -s - --write-kubeconfig-mode 644

KUBECTL_ALIAS="alias k='kubectl'"
VAGRANT_BASHRC="/home/vagrant/.bashrc"

grep -qxF "$KUBECTL_ALIAS" "$VAGRANT_BASHRC" || echo "$KUBECTL_ALIAS" >> "$VAGRANT_BASHRC"

timeout 180 bash -c '
    until kubectl get nodes >/dev/null 2>&1; do
        sleep 2
    done
'

kubectl wait --for=condition=Ready node --all --timeout=180s

kubectl apply -f /vagrant/confs/manifests/