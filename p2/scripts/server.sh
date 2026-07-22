#!/bin/bash
set -euo pipefail

export DEBIAN_FRONTEND=noninteractive

apt-get update
apt-get install -y curl ca-certificates

CONFIG_DIRECTORY="/etc/rancher/k3s"

mkdir -p "$CONFIG_DIRECTORY"

cp /vagrant/confs/server.yaml "$CONFIG_DIRECTORY/config.yaml"

chmod 0600 "$CONFIG_DIRECTORY/config.yaml"

curl -sfL https://get.k3s.io | sh -

KUBECTL_ALIAS="alias k='sudo kubectl'"
VAGRANT_BASHRC="/home/vagrant/.bashrc"

grep -qxF "$KUBECTL_ALIAS" "$VAGRANT_BASHRC" || echo "$KUBECTL_ALIAS" >> "$VAGRANT_BASHRC"