FROM ubuntu:focal

RUN apt-get update -qq && \
    apt-get install -y --no-install-recommends \
        wget && \
    apt-get autoremove -y \
    apt-get clean -y && \
    rm -rf /var/lib/apt/lists/*

ARG VERSION=1.14.2
ENV VERSION=${VERSION}

RUN mkdir -p /var/lib/dogecoind && \
    useradd -ms /bin/bash dogecoin

RUN wget "https://github.com/dogecoin/dogecoin/releases/download/v${VERSION}/dogecoin-${VERSION}-x86_64-linux-gnu.tar.gz" -O dogecoin.tar.gz && \
    tar -zxf dogecoin.tar.gz && \
    rm dogecoin.tar.gz && \
    install -m 0755 -o root -g root -t /usr/bin dogecoin-${VERSION}/bin/*

# TODO: rpcpassword
RUN mkdir -p /etc/dogecoin && \
    echo rpcuser=dogecoinrpc >> /home/dogecoin/dogecoin.conf && \
    echo maxconnections=40 >> /etc/dogecoin/dogecoin.conf
