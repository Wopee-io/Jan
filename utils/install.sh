#!/bin/bash
echo
echo "Install start..."
echo

echo
echo "Set up the repository"
echo

sudo apt-get update

sudo apt-get -y upgrade

sudo apt-get -y install \
    ca-certificates \
    curl \
    gnupg \
    lsb-release \
    acl \
    mc \
    nmon \
    iputils-ping \
    traceroute \
    dnsutils \
    iproute2 \
    net-tools \
    rdiff-backup \
    apache2-utils \
    ncdu \
    zip \
    nodejs \
    npm \
    skopeo \
    pandoc \
    pv \
    btrfs-progs \
    parted \
    jq


echo
echo "Install jwt"
echo

sudo npm install --global jsonwebtokencli

echo
echo "Install Micro editor"
echo

if [ ! -f /usr/bin/micro ]; then
  curl https://getmic.ro | bash
  sudo mv micro /usr/bin
fi

echo
echo "Install GitHub CLI"
echo

curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg | sudo dd of=/usr/share/keyrings/githubcli-archive-keyring.gpg
sudo chmod go+r /usr/share/keyrings/githubcli-archive-keyring.gpg
echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" | sudo tee /etc/apt/sources.list.d/github-cli.list > /dev/null
sudo apt-get update
sudo apt-get -y install gh

echo
echo "Install sops"
echo

SOPS_LATEST_VERSION=$(curl -s "https://api.github.com/repos/getsops/sops/releases/latest" | grep -Po '"tag_name": "v\K[0-9.]+')
curl -Lo sops.deb "https://github.com/getsops/sops/releases/latest/download/sops_${SOPS_LATEST_VERSION}_amd64.deb"
sudo apt --fix-broken install ./sops.deb
rm -rf sops.deb
sops -version

echo
echo "Install age"
echo
AGE_VERSION=$(curl -s "https://api.github.com/repos/FiloSottile/age/releases/latest" | grep -Po '"tag_name": "v\K[0-9.]+')
curl -Lo age.tar.gz "https://github.com/FiloSottile/age/releases/latest/download/age-v${AGE_VERSION}-linux-amd64.tar.gz"
tar xf age.tar.gz
sudo mv age/age /usr/local/bin
sudo mv age/age-keygen /usr/local/bin
rm -rf age.tar.gz
rm -rf age
age -version

echo
echo "Install Docker Engine and Compose plugin"
echo

if [ ! -f /usr/share/keyrings/docker-archive-keyring.gpg ]; then
  # sudo rm -f /usr/share/keyrings/docker-archive-keyring.gpg
  curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg

  echo \
    "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu \
    $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
fi

sudo apt-get update
sudo apt-get -y install docker-ce docker-ce-cli containerd.io docker-compose-plugin

echo
echo "Setup user permissions"
echo

# sudo setfacl --modify user:$USER:rw /var/run/docker.sock
# sudo setfacl --modify user:gitlab-runner:rw /var/run/docker.sock

if ! grep -q docker /etc/group; then sudo groupadd docker; fi
sudo usermod -aG docker $USER
#sudo usermod -aG docker gitlab-runner
newgrp docker


echo
echo "Check Docker nad Docker Compose"
echo

docker info
docker compose version

# # For memory monitoring by cadviser
# GRUB_CMDLINE_LINUX_DEFAULT="cgroup_enable=memory swapaccount=1"
# sudo update-grub && sudo reboot

echo
echo "Create swap"
echo

if [ ! -f /swapfile ]; then
  sudo fallocate -l 8G /swapfile
  sudo dd if=/dev/zero of=swapfile bs=1K count=8M
  sudo chmod 600 /swapfile
  sudo mkswap /swapfile
  sudo swapon /swapfile
  echo '/swapfile swap swap defaults 0 0' | sudo tee -a /etc/fstab
fi


echo
echo "srv dir"
echo

[ ! -d "/srv" ] && sudo mkdir -p "/srv"
sudo chown $USER:$USER /srv

echo
echo "backup dir"
echo

[ ! -d "/backup" ] && sudo mkdir -p "/backup"
sudo chown $USER:$USER /backup


echo
echo "Install end!"
echo
