# Dogecoin Full Node

## VPS

You will need a server which is online most of the time (more than 6 hours every day is good, 24/7 is best). You can buy cheap(-ish) servers online at places like Digital Ocean, Linode or UpCloud. [Best VPS under $10](https://www.vpsbenchmarks.com/best_vps/2020/under/10).

**Minimum requirements:**
- 2GB RAM
- 80GB storage
    - 40GB+ blockchain
    - Operating system
- Unmetered internet connection

**Recommended specs:**
- 2 cores
- 4GB RAM

## Installation

### Prep

```sh
sudo apt update && sudo apt upgrade -y
sudo apt install -y aria2
```

### Downloading dogecoind

```sh
# Download and extract dogecoin binaries (including dogecoind)
cd ~
wget "https://github.com/dogecoin/dogecoin/releases/download/v1.14.3/dogecoin-1.14.3-x86_64-linux-gnu.tar.gz" -O dogecoin.tar.gz
tar -zxvvf dogecoin.tar.gz
rm dogecoin.tar.gz

# Installing binaries
sudo install -m 0755 -o root -g root -t /usr/bin dogecoin-1.14.3/bin/*
```

### Configuring dogecoind

```sh
# Download the template dogecoin.conf
wget https://raw.githubusercontent.com/incognitojam/dogecoin-full-node/main/dogecoin.conf

# Set a long random password for RPC
dogepw=`cat /dev/urandom | tr -dc 'a-zA-Z0-9' | head -c 64`
echo rpcpassword=$dogepw >> dogecoin.conf

mkdir -p /etc/dogecoin
mv dogecoin.conf /etc/dogecoin
```

### Downloading blockchain

This will take a while, depending on your connection speed and the number of seeders of the torrent.

```sh
# Download the torrent
# TODO: update this link to the more recent bootstrap
cd ~/
aria2c --seed-ratio=0.1 "magnet:?xt=urn:btih:fd425a8feffac887701eeb8059172589efb3369d&dn=dogecoin-blockchain-2021-01-03&tr=udp%3a%2f%2ftracker.openbittorrent.com%3a80%2fannounce"

# Make a cup of coffee ☕

# Move the downloaded files to the correct location
mkdir -p /var/lib/dogecoind
mv dogecoin-blockchain-2021-01-03/* /var/lib/dogecoind
rm -r dogecoin-blockchain-2021-01-03
```

### Creating a "dogecoin" user and systemd service

```sh
# Create the dogecoin user
sudo useradd -r -s /bin/false dogecoin

# Add the systemd service and enable it to start at boot
wget https://raw.githubusercontent.com/incognitojam/dogecoin-full-node/main/dogecoind.service
sudo cp dogecoind.service /etc/systemd/system/dogecoind.service
sudo chmod 644 /etc/systemd/system/dogecoind.service
sudo systemctl enable dogecoind

# Start the service immediately and check the status
sudo systemctl start dogecoind
sudo systemctl status dogecoind
```
