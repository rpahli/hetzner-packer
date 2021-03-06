#!/bin/sh

set -o errexit
set -o nounset
set -o pipefail

# Prerequisites
modprobe overlay
modprobe br_netfilter

sysctl --system

## for cri-o
dnf module -y install go-toolset

dnf install -y \
  containers-common \
  device-mapper-devel \
  git \
  make \
  glib2-devel \
  glibc-devel \
  glibc-static \
  runc \
  go \
  gpgme-devel \
  libassuan \
  libassuan-devel \
  libgpg-error \
  libgpg-error-devel \
  libseccomp \
  libselinux \
  libseccomp-devel \
  libselinux-devel \
  pkgconfig \
  pkgconf-pkg-config

go get github.com/cpuguy83/go-md2man

# Install runc
# wget https://github.com/opencontainers/runc/releases/download/$RUNC/runc.amd64 -O /usr/local/sbin/runc && chmod +x /usr/local/sbin/runc

# Install conmon
# wget https://github.com/containers/conmon/releases/download/$CONMON/conmon.amd64 -O /usr/local/bin/conmon && chmod +x /usr/local/bin/conmon

# install cri-o

wget https://storage.googleapis.com/k8s-conform-cri-o/artifacts/cri-o.amd64.ff0b7feb8e12509076b4b0e338b6334ce466b293.tar.gz
tar zxvf cri-o.amd64.ff0b7feb8e12509076b4b0e338b6334ce466b293.tar.gz -C /tmp/
cd /tmp/cri-o/ && ./install && cd -
rm -f cri-o.amd64.ff0b7feb8e12509076b4b0e338b6334ce466b293.tar.gz
rm -fr /tmp/cri-o

# cri-tool https://github.com/kubernetes-sigs/cri-tools
# Install crictl
#wget https://github.com/kubernetes-sigs/cri-tools/releases/download/$CRI_TOOLS/crictl-$CRI_TOOLS-linux-amd64.tar.gz
#tar zxvf crictl-$CRI_TOOLS-linux-amd64.tar.gz -C /usr/local/bin 
#rm -f crictl-$CRI_TOOLS-linux-amd64.tar.gz

# Install critest
wget https://github.com/kubernetes-sigs/cri-tools/releases/download/$CRI_TOOLS/critest-$CRI_TOOLS-linux-amd64.tar.gz
tar zxvf critest-$CRI_TOOLS-linux-amd64.tar.gz -C /usr/local/bin
rm -f critest-$CRI_TOOLS-linux-amd64.tar.gz

# remove default CNIs
rm -f /etc/cni/net.d/100-crio-bridge.conf /etc/cni/net.d/200-loopback.conf

# add default cni directory the config
perl -i -0pe 's#plugin_dirs\s*=\s*\[[^\]]*\]#plugin_dirs = [\n  "/opt/cni/bin",\n  "/usr/libexec/cni"\n]#g' /etc/crio/crio.conf

wget https://github.com/mikefarah/yq/releases/download/v4.11.2/yq_linux_amd64.tar.gz
tar zxvf yq_linux_amd64.tar.gz -C /usr/local/bin
mv /usr/local/bin/yq_linux_amd64 /usr/local/bin/yq
rm -f yq_linux_amd64.tar.gz

# enable systemd service after next boot
systemctl daemon-reload
systemctl enable crio