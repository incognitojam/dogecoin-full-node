# Dogecoin Full Node

Dogecoin Core is the official dogecoin wallet implementation and already operates as a full node by serving data to others. It's essential that volunteers operate full nodes otherwise the network would not function! If you already have Dogecoin Core on your computer, keeping it open for as many hours in the day as possible is already helping. However, you can go a step further by configuring a full node on a computer which operates 24/7 with unrestricted bandwidth.

**Table of Contents**

* [VPS ☁️](#vps-%EF%B8%8F)
    + [Server requirements](#server-requirements)
* [Installation](#installation)
    + [Automatic Installer (experimental!) ✨](#automatic-installer-experimental-)
    + [Preparation 📚](#preparation-)
    + [Downloading dogecoind ⬇️](#downloading-dogecoind-%EF%B8%8F)
    + [Configuring dogecoind 🔧](#configuring-dogecoind-)
        - Restricting bandwidth use with `maxuploadtarget`
    + [Downloading the blockchain ⬇️](#downloading-the-blockchain-%EF%B8%8F)
    + [Creating a "dogecoin" user and systemd service 🔁](#creating-a-dogecoin-user-and-systemd-service-)
* [Interacting with `dogecoind` 🔎](#interacting-with-dogecoind-)
    + [Using `dogecoin-cli` 💻](#using-dogecoin-cli-)

## VPS ☁️

You can buy cheap(-ish) servers online at places like Digital Ocean, Linode or UpCloud. [Best VPS under $10](https://www.vpsbenchmarks.com/best_vps/2020/under/10).

⚠️ Be aware of overage charges for bandwidth! You may be charged extra if you use more data than included in the plan. You can see how to limit bandwidth use later in the guide (`maxuploadtarget`).

**TODO:** add comparison table

### Server requirements
**👍 Minimum:**
- 2.5GB RAM*
- 80GB storage
    - 40GB+ blockchain
    - Operating system
- Unmetered internet connection

*2GB may be enough if you configure SWAP.

**⭐️ Recommended:**
- 2 cores
- 4GB RAM

More RAM generally means more blocks can be cached in memory and less reads from disk need to occur.

**TODO:** determine whether a Raspberry Pi or other SBC can be used.

## Installation

### Automatic Installer (experimental!) ✨

Want to try out the automatic installer? Run this! (recommend to read the source code [here](https://github.com/incognitojam/dogecoin-full-node/blob/main/dogecoin-full-node.sh))

```sh
curl https://raw.githubusercontent.com/incognitojam/dogecoin-full-node/main/dogecoin-full-node.sh | sh
```

**Want to install it manually?** You can follow the guide below ⬇️.

### Preparation 📚

It's always a good idea to keep your packages up-to-date 🙂. We will use `aria2` to download the bootstrap torrent later on.

```sh
sudo apt update && sudo apt upgrade -y
sudo apt install -y aria2
```

### Downloading dogecoind ⬇️

We will get the latest Dogecoin Core binaries (1.14.3) and install them.

```sh
# Download and extract dogecoin binaries (including dogecoind)
wget "https://github.com/dogecoin/dogecoin/releases/download/v1.14.3/dogecoin-1.14.3-x86_64-linux-gnu.tar.gz" -O dogecoin.tar.gz
tar -zxvvf dogecoin.tar.gz
rm dogecoin.tar.gz

# Installing binaries
sudo install -m 0755 -o root -g root -t /usr/bin dogecoin-1.14.3/bin/*
```

### Configuring dogecoind 🔧

Here we download the template `dogecoin.conf`, set a secure rpcpassword and then move it to the configuration directory. Take a look inside dogecoin.conf to see the possible configuration options. I've already set some useful defaults:

- Increased max connections to 150 (default is 125, reduce this if your node is falling behind)
- Disabled wallet functionality (not required for full node)
- Added some extra nodes

```sh
# Download the template dogecoin.conf
wget https://raw.githubusercontent.com/incognitojam/dogecoin-full-node/main/dogecoin.conf

# Set a long random password for RPC
dogepw=`cat /dev/urandom | tr -dc 'a-zA-Z0-9' | head -c 64`
echo rpcpassword=$dogepw >> dogecoin.conf

mkdir -p /etc/dogecoin
mv dogecoin.conf /etc/dogecoin
```

If you want to change the configuration later, simply edit the configuration file at `/etc/dogecoin/dogecoin.conf`, save it, and then restart dogecoind.

#### Restricting bandwidth use with `maxuploadtarget`

You can reduce the network upload usage by setting a target for Dogecoin Core. This will limit the amount of data served each day.

```
sudo nano /etc/dogecoin/dogecoin.conf
```

```conf
# un-comment the line below to enable a max upload target.
# the number is measured in MiB per day.
# for example, if you have a 10TiB monthly limit on your VPS
# you could set this to: 10 TB / 30 = 9536740 MiB / 30 = 317890
# maxuploadtarget=100000
```

(Note: to save and exit `nano` press `CTRL+X` and then type `y` and hit `Enter` to confirm)

### Downloading the blockchain ⬇️

This torrent is a "bootstrap" for the blockchain, a copy of all the blocks you can use instead of getting them from the network (torrent is faster than the dogecoin core software right now).

This step will take a while, depending on your connection speed and the number of seeders of the torrent. 

```sh
aria2c --seed-time=0 "magnet:?xt=urn:btih:d7a6e8b70bf50121ecf119be87684620ebd31198&dn=dogecoin-bootstrap-2021-04-11&tr=udp%3A%2F%2Ftracker.openbittorrent.com%3A80&tr=udp%3A%2F%2Ftracker.opentrackr.org%3A1337%2Fannounce&tr=udp%3A%2F%2Ftracker.coppersurfer.tk%3A6969%2Fannounce&tr=udp%3A%2F%2Ftracker.publicbt.com%3A80"
```

Go and make a cup of coffee! ☕

When it's done, you can move the `bootstrap.dat` to the Dogecoin Data directory.

```
# Create the data directory for dogecoind
mkdir -p /var/lib/dogecoind

# Move the bootstrap to the correct location and then delete the torrent folder
mv dogecoin-bootstrap-2021-04-11/bootstrap.dat /var/lib/dogecoind
rm -r dogecoin-bootstrap-2021-04-11
```

### Creating a "dogecoin" user and systemd service 🔁

```sh
# Create the dogecoin user
sudo useradd -r -s /bin/false dogecoin

# Add the systemd service and enable it to start at boot
wget https://raw.githubusercontent.com/incognitojam/dogecoin-full-node/main/dogecoind.service
sudo cp dogecoind.service /etc/systemd/system/dogecoind.service
sudo chmod 644 /etc/systemd/system/dogecoind.service
sudo systemctl enable dogecoind
```

## Interacting with `dogecoind` 🔎

Now that the service is created you can start it!

```sh
sudo systemctl start dogecoind

# Check the status
sudo systemctl status dogecoind
```

### Using `dogecoin-cli` 💻

You can use `dogecoin-cli` to interact with the Dogecoin daemon. Make sure to provide the path to your config file so that it knows your rpcuser/password.

`getinfo` is a useful RPC command to get the current status. You can use it to monitor the current number of connections and the block height. The `"blocks"` will increase as the bootstrap is processed until it catches up with the network. You can check the current network block height at [dogechain.info](https://dogechain.info/).

```sh
# Run getinfo
dogecoin-cli -conf=/etc/dogecoin/dogecoin.conf getinfo

# Manually addnode
dogecoin-cli -conf=/etc/dogecoin/dogecoin.conf addnode core0-eu.dogecoin.gg add
```

If it looks like the block height gets stuck (stops indexing the bootstrap, or stops syncing from the network) you can just restart the dogecoind service.

```sh
sudo systemctl restart dogecoind
```
