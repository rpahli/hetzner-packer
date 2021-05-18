#!/bin/sh

set -o errexit
set -o nounset
set -o pipefail

cat <<EOF > /etc/yum.repos.d/kubernetes.repo
[kubernetes]
name=Kubernetes
baseurl=https://packages.cloud.google.com/yum/repos/kubernetes-el7-x86_64
enabled=1
gpgcheck=1
repo_gpgcheck=1
gpgkey=https://packages.cloud.google.com/yum/doc/yum-key.gpg https://packages.cloud.google.com/yum/doc/rpm-package-key.gpg
EOF

dnf install --setopt=obsoletes=0 -y kubelet-0:$KUBERNETES_VERSION-0 kubeadm-0:$KUBERNETES_VERSION-0 kubectl-0:$KUBERNETES_VERSION-0 python3-dnf-plugin-versionlock bash-completion --disableexcludes=kubernetes
dnf versionlock kubelet kubectl kubeadm
systemctl enable kubelet

mkdir -p /etc/systemd/system/kubelet.service.d
cat <<EOF > /etc/systemd/system/kubelet.service.d/11-cgroups.conf
[Service]
CPUAccounting=true
MemoryAccounting=true
EOF

cat <<EOF > /etc/sysconfig/kubelet
KUBELET_EXTRA_ARGS=--cgroup-driver=systemd
EOF

cat <<EOF > /etc/modules-load.d/k8s.conf
# load bridge netfilter
br_netfilter
EOF

# Set up required sysctl params, these persist across reboots.
cat > /etc/sysctl.d/99-kubernetes-cri.conf <<EOF
net.bridge.bridge-nf-call-iptables  = 1
net.bridge.bridge-nf-call-ip6tables = 1
net.ipv4.ip_forward                 = 1
EOF

systemctl start crio
kubeadm config images pull --kubernetes-version $KUBERNETES_VERSION

dnf install -y policycoreutils-python-utils

semanage fcontext -a -t container_file_t /var/lib/etcd
mkdir -p /var/lib/etcd
restorecon -rv /var /etc

# enable completion
echo 'source <(kubectl completion bash)' >>~/.bashrc

# set the kubeadm default path for kubeconfig
echo 'export KUBECONFIG=/etc/kubernetes/admin.conf' >>~/.bashrc