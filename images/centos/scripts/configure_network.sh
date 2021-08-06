#!/bin/sh

set -o errexit
set -o nounset
set -o pipefail
# localectl set-locale LANGUAGE=en_US.UTF-9

# install hetzner cloud networks configuration package
curl https://packages.hetzner.com/hcloud/rpm/hc-utils-0.0.3-1.el8.noarch.rpm -o /tmp/hc-utils-0.0.3-1.el8.noarch.rpm -s
dnf -y install /tmp/hc-utils-0.0.3-1.el8.noarch.rpm

# disable public interface
cat > /etc/systemd/system/disable-public-interface.service <<EOF
[Unit]
Description=Disable Public Interface
Wants=network-online.target
After=network-online.target

[Service]
ExecStart=/bin/sh -c 'nmcli connection down "System eth0"'

[Install]
WantedBy=multi-user.target
EOF

sed -i -e '/^ONBOOT/s/^.*$/ONBOOT=false/' /etc/sysconfig/network-scripts/ifcfg-eth0
sed -i -e '/^DEFROUTE/s/^.*$/DEFROUTE=false/' /etc/sysconfig/network-scripts/ifcfg-eth0

cat > /etc/sysconfig/network-scripts/ifcfg-ens10 <<EOF
DEVICE=ens10
BOOTPROTO=dhcp
ONBOOT=yes
DEFROUTE=yes
EOF

#cat > /etc/sysconfig/network-scripts/ifcfg-ens10 <<EOF
#gateway.of.the.network/32 via 0.0.0.0 dev ens10 scope link
#net.work.ip.range via gateway.of.the.network dev ens10
#EOF

cat > /etc/cloud/cloud.cfg.d/98-disable-network.cfg <<EOF
network:
  config: disabled
EOF

systemctl enable disable-public-interface.service