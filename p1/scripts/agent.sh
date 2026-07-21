#!/bin/bash
set -euo pipefail

CONFIG_DIRECTORY="/etc/rancher/k3s"
SHARED_TOKEN="/vagrant/.vagrant/k3s-agent-token"
LOCAL_TOKEN="$CONFIG_DIRECTORY/agent-token"

mkdir -p "$CONFIG_DIRECTORY"

cp /vagrant/confs/agent.yaml \
   "$CONFIG_DIRECTORY/config.yaml"

chmod 0600 "$CONFIG_DIRECTORY/config.yaml"

timeout 180 bash -c "
    until [ -s '$SHARED_TOKEN' ]; do
        sleep 2
    done
"

cp "$SHARED_TOKEN" "$LOCAL_TOKEN"
chown root:root "$LOCAL_TOKEN"
chmod 0600 "$LOCAL_TOKEN"

timeout 180 bash -c '
    until curl -kfsS \
        https://192.168.56.110:6443/cacerts \
        >/dev/null; do
        sleep 2
    done
'

curl -sfL https://get.k3s.io |
    INSTALL_K3S_EXEC="agent" sh -