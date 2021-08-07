#!/bin/sh

set -o errexit
set -o nounset
set -o pipefail
# localectl set-locale LANGUAGE=en_US.UTF-9

# install hetzner cloud networks configuration package
curl https://packages.hetzner.com/hcloud/rpm/hc-utils-0.0.3-1.el8.noarch.rpm -o /tmp/hc-utils-0.0.3-1.el8.noarch.rpm -s
dnf -y install /tmp/hc-utils-0.0.3-1.el8.noarch.rpm
