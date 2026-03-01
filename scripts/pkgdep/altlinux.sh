#!/usr/bin/env bash
#  SPDX-License-Identifier: BSD-3-Clause
#  Copyright (C) 2020 Intel Corporation
#  Copyright (c) 2022 NVIDIA CORPORATION & AFFILIATES.
#  All rights reserved.
#  Copyright (c) 2022 Dell Inc, or its subsidiaries.
#

set -e

echo "Here's altlinux installing."

apt-get update

apt-get install -y gcc gcc-c++ make CUnit-devel libaio-devel libssl-devel openssl-devel libjson-c-devel libcmocka-devel libuuid-devel libiscsi-devel \
    libkeyutils-devel libncurses-devel libncursesw-devel python python-dev python3 pip python3-dev unzip libfuse3-devel patchelf \
    curl procps pkgconf python3-module-pip # python3-pip python3-venv

virtdir=${PIP_VIRTDIR:-/var/spdk/dependencies/pip}
python3 -m venv --system-site-packages "$virtdir"
source "$virtdir/bin/activate"
python -m pip install -U "pip<26" setuptools wheel pip-tools
pip-compile --extra dev --strip-extras -o "$rootdir/scripts/pkgdep/requirements.txt" "${rootdir}/python/pyproject.toml"
pip3 install -r "$rootdir/scripts/pkgdep/requirements.txt"

pkgdep_toolpath meson "${virtdir}/bin"

apt-get install -y python3-module-configshell-fb python3-module-pexpect python-module-jinja2
apt-get install -y python3-module-tabulate
apt-get install -y nasm libnuma-devel
apt-get install -y autoconf automake libtool help2man

# Programmable system-wide instrumentation system available only in p11 altlinux
# apt-get install -y systemtap

if [[ $INSTALL_DEV_TOOLS == "true" ]]; then
    # Tools for developers
    apt-get install -y git cmake lcov clang sg3_utils pciutils shellcheck \
        abigail-tools bash-completion ruby-devel python-module-pycodestyle bundle rake
    # Additional dependencies for nvmf performance test script
    apt-get install -y python-module-paramiko
fi
if [[ $INSTALL_RBD == "true" ]]; then
    # Additional dependencies for RBD bdev in NVMe over Fabrics
    apt-get install -y librados-devel librbd-devel
fi
if [[ $INSTALL_RDMA == "true" ]]; then
    # Additional dependencies for RDMA transport in NVMe over Fabrics
    apt-get install -y libibverbs-utils rdma-core-devel librdmacm-utils
fi
if [[ $INSTALL_DOCS == "true" ]]; then
    # Additional dependencies for building docs
    apt-get install -y doxygen mscgen graphviz
fi
# Additional dependencies for Avahi
if [[ $INSTALL_AVAHI == "true" ]]; then
    # Additional dependencies for Avahi
    apt-get install -y libavahi-devel
fi
if [[ $INSTALL_IDXD == "true" ]]; then
    # accel-config-devel is required for kernel IDXD implementation used in DSA accel module
    if [[ $ID == "ubuntu" && ${VERSION_ID:0:2} -ge "23" ]]; then
        apt-get install -y libaccel-config-dev
    else
        echo "libaccel-config is only present on Ubuntu 23.04 or higher."
    fi
fi
if [[ $INSTALL_LZ4 == "true" ]]; then
    apt-get install -y liblz4-devel
fi
