#!/bin/sh

set -o errexit
set -o nounset
set -o pipefail

# Set locale
localectl set-locale LANG=en_US.UTF-8 
localectl set-locale LANGUAGE=en_US.UTF-9

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
ExecStart=/bin/sh -c 'nmcli connection down "System eth0" && sed -i -e '/^ONBOOT/s/^.*$/ONBOOT=false/' /etc/sysconfig/network-scripts/ifcfg-eth0'

[Install]
WantedBy=multi-user.target
EOF

cat > /usr/bin/setup_gateway.sh <<EOF
#!/bin/sh

ip route add default via 10.0.0.1 dev ens10

while [ $? -ne 0 ]; do
    ip route add default via 10.0.0.1 dev ens10
done
EOF

chmod +x /usr/bin/setup_gateway.sh

cat > /etc/systemd/system/setup-default-gateway.service <<EOF
[Unit]
Description=Disable Public Interface
Wants=network-online.target
After=network-online.target

[Service]
ExecStart=/bin/sh -c '/usr/bin/setup_gateway.sh'

[Install]
WantedBy=multi-user.target
EOF

systemctl enable disable-public-interface.service
systemctl enable setup-default-gateway.service