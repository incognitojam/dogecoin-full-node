#!/bin/bash

# TODO: determine latest automatically
VERSION=1.14.4

set_os() {
    #!/bin/bash
    # Check for FreeBSD in the uname output
    # If it's not FreeBSD, then we move on!
    if [ "$(uname -s)" = 'FreeBSD' ]; then
        OS='freebsd'
    # Check for a redhat-release file and see if we can
    # tell which Red Hat variant it is
    elif [ -f "/etc/redhat-release" ]; then
        RHV=$(egrep -o 'Fedora|CentOS|Red\ Hat|Red.Hat' /etc/redhat-release)
        case $RHV in
            Fedora)  OS='fedora';;
            CentOS)  OS='centos';;
        Red\ Hat)  OS='redhat';;
        Red.Hat)  OS='redhat';;
        esac
    # Check for debian_version
    elif [ -f "/etc/debian_version" ]; then
        OS='debian'
    # Check for arch-release
    elif [ -f "/etc/arch-release" ]; then
        OS='arch'
    # Check for SuSE-release
    elif [ -f "/etc/SuSE-release" ]; then
        OS='suse'
    fi
}

update_linux() {
    # TODO: support more distros
    set_os
        case $OS in
            debian )  update_debian ;;
            * )       err "OS $OS unsupported." ;;
        esac
}

update_debian() {
    need_cmd apt-get
    need_cmd sleep
    # TODO: support not using systemd
    need_cmd systemctl

    ignore sudo apt-get update -qq

    say "Installing wget..."
    ignore sudo apt-get install -qq wget

    say "Downloading Dogecoin binaries..."
    ensure wget "https://github.com/dogecoin/dogecoin/releases/download/v$VERSION/dogecoin-$VERSION-x86_64-linux-gnu.tar.gz" -O dogecoin.tar.gz
    ensure tar -xf dogecoin.tar.gz
    ensure rm dogecoin.tar.gz

    say "Installing Dogecoin binaries..."
    need_cmd install
    ensure sudo install -m 0755 -o root -g root -t /usr/bin dogecoin-$VERSION/bin/*
    ignore rm -r dogecoin-$VERSION

    say "Restarting dogecoind..."
    ensure sudo systemctl restart dogecoind
    systemctl is-active --quiet dogecoind
    local _retval=$?
    if [ $_retval != 0 ]; then
        # TODO: handle
        err "warning! dogecoind service is not running!"
        # journalctl -u dogecoind -b --no-pager
    fi
}

update() {
    # TODO: support Darwin
    unamestr=`uname`
    if [ "$unamestr" = 'Linux' ]; then
        update_linux "$@"
    else
        err "OS $unamestr unsupported."
    fi

    say "dogecoind is now running"

    # TODO: monitor bootstrap indexing (check block height higher than 3684000)

    echo ""
    say "run the following command to get dogecoind status:"
    echo "dogecoin-cli -conf=/etc/dogecoin/dogecoin.conf getinfo"
    echo ""
    say "thanks for running a full node!"
}

# Copyright 2016 The Rust Project Developers. See the COPYRIGHT
# file at the top-level directory of this distribution and at
# http://rust-lang.org/COPYRIGHT.
#
# Licensed under the Apache License, Version 2.0 <LICENSE-APACHE or
# http://www.apache.org/licenses/LICENSE-2.0> or the MIT license
# <LICENSE-MIT or http://opensource.org/licenses/MIT>, at your
# option. This file may not be copied, modified, or distributed
# except according to those terms.
say() {
    echo "dogecoin-full-node: $@"
}

say_err() {
    say "$@" >&2
}

err() {
    say "$@" >&2
    exit 1
}

need_cmd() {
    if ! command -v "$1" > /dev/null 2>&1
    then err "need '$1' (command not found)"
    fi
}

need_ok() {
    if [ $? != 0 ]; then err "$1"; fi
}

assert_nz() {
    if [ -z "$1" ]; then err "assert_nz $2"; fi
}

# Run a command that should never fail. If the command fails execution
# will immediately terminate with an error showing the failing
# command.
ensure() {
    "$@"
    need_ok "command failed: $*"
}

# This is just for indicating that commands' results are being
# intentionally ignored. Usually, because it's being executed
# as part of error handling.
ignore() {
    run "$@"
}

# Runs a command and prints it to stderr if it fails.
run() {
    "$@"
    local _retval=$?
    if [ $_retval != 0 ]; then
        say_err "command failed: $*"
    fi
    return $_retval
}

update "$@"
