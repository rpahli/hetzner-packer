#!/bin/sh

set -o errexit
set -o nounset
set -o pipefail

# configure repo
curl -Lo /etc/yum.repos.d/wireguard.repo https://copr.fedorainfracloud.org/coprs/jdoss/wireguard/repo/epel-8/jdoss-wireguard-epel-8.repo

# install wireguard
yum -y install wireguard-dkms wireguard-tools

# ensure dkms modules are build
KERNEL_VERSION=$(find /lib/modules -mindepth 1 -maxdepth 1 -printf "%f\n" -type d | sort -V | tail -n -1)

# check if module are existing
if [ -f "/lib/modules/${KERNEL_VERSION}/kernel/net/wireguard/wireguard.ko.xz" ]; then
    exit 0
fi

# run dkms for latest kernel version
dkms autoinstall -k ${KERNEL_VERSION}

# run dracut to build initramfs
dracut --kver ${KERNEL_VERSION} -f