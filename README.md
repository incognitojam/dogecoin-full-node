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

Here we download the template `dogecoin.conf`, set a secure rpcpassword and then move it to the configuration directory. Take a look inside dogecoin.conf to see the possible configuration options. I've already set some sane defaults.

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

This will take a while, depending on your connection speed and the number of seeders of the torrent. This torrent is a "bootstrap" for the blockchain, a copy of all the blocks you can use instead of getting them from the network (torrent is faster than the dogecoin core software right now).

```sh
# Download the torrent
cd ~/
aria2c "magnet:?xt=urn:btih:d7a6e8b70bf50121ecf119be87684620ebd31198&dn=dogecoin-bootstrap-2021-04-11&tr=udp%3A%2F%2Ftracker.openbittorrent.com%3A80&tr=udp%3A%2F%2Ftracker.opentrackr.org%3A1337%2Fannounce&tr=udp%3A%2F%2Ftracker.coppersurfer.tk%3A6969%2Fannounce&tr=udp%3A%2F%2Ftracker.publicbt.com%3A80"

# Make a cup of coffee ☕

# Move the downloaded files to the correct location
mkdir -p /var/lib/dogecoind
mv dogecoin-bootstrap-2021-04-11/bootstrap.dat /var/lib/dogecoind
rm -r dogecoin-bootstrap-2021-04-11
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

### Interacting with dogecoind

You can use `dogecoin-cli` to interact with the Dogecoin daemon. Make sure to provide the path to your config file.

`getinfo` is a useful RPC command to get the current status.

```sh
# Run getinfo
dogecoin-cli -conf=/etc/dogecoin/dogecoin.conf getinfo

# Manually addnode
dogecoin-cli -conf=/etc/dogecoin/dogecoin.conf addnode core0-eu.dogecoin.gg add
```
