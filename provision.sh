#!/bin/bash
set -e -u -o pipefail

## https://help.replicated.com/docs/kb/developer-resources/automate-install/

declare -r license_file="/vagrant/vagrant-terraform-enterprise.rli"

if [ ! -e "${license_file}" ]; then
    echo "no license file not found: ${license_file}"
    exit 1
fi

replicated_bootstrap_url='https://get.replicated.com/docker'

replicated_installer_args=(
    no-proxy
    "tags=workers"
)

var_lib_docker_dev="/dev/sdc"
public_hostname="tfe.example.com"

## "public" IP is hard-coded in Vagrantfile, need private IP
public_addr="203.0.113.10"
private_addr=$(
    ip -o addr show scope global | \
        grep -E -v "docker0|${public_addr}" | \
        awk '{split($4, a, "/"); print a[1]}'
)

replicated_installer_args=(
    "${replicated_installer_args[@]}"
    "private-address=${private_addr}"
    "public-address=${public_addr}"
)

apt-get update
apt-get install -y jq

mkfs.ext4 -F -L docker "${var_lib_docker_dev}"
echo 'LABEL=docker /var/lib/docker ext4 defaults 0 0' >> /etc/fstab
mkdir /var/lib/docker
mount /var/lib/docker

import_settings_file="/etc/replicated-ptfe.json"
jq -n \
    --arg hostname "${public_hostname}" \
    '{
        "hostname": {
            "value": $hostname
        },
        "installation_type": {
            "value": "poc"
        }
    }' \
    > "${import_settings_file}"

jq -n \
    --arg settings     "${import_settings_file}" \
    --arg license_file "${license_file}" \
    '{
        "DaemonAuthenticationType": "anonymous",
        "TlsBootstrapType":         "self-signed",
        "ImportSettingsFrom":       $settings,
        "LicenseFileLocation":      $license_file,
        "BypassPreflightChecks":    true
    }' \
    > /etc/replicated.conf

curl -sfSL "${replicated_bootstrap_url}" | bash -s "${replicated_installer_args[@]}"

usermod -a -G docker ubuntu
if id vagrant &> /dev/null
then
  usermod -a -G docker vagrant
fi

echo
echo "begin setup: https://${public_hostname}:8800/"
echo "while ! curl -ksfS --connect-timeout 5 https://${public_hostname}/_health_check; do sleep 5; done"
