#!/bin/bash

if [ $# -ne 1 ]
then
	echo >&2 "Usage: $0 IMAGE_EIF"
	exit 1
fi
image_eif="$1"

# gvproxy is the untrusted proxy application that runs on the EC2 host.  It
# acts as the bridge between the Internet and the enclave.  The code is
# available here:
# https://github.com/brave-intl/bat-go/tree/master/nitro-shim/tools/gvproxy
echo "[ec2] Starting gvproxy."
wget -O gvproxy https://github.com/containers/gvisor-tap-vsock/releases/download/v0.7.3/gvproxy-linux-amd64
chmod +x ./gvproxy

killall gvproxy
./gvproxy -listen vsock://:1024 -listen unix:///tmp/network.sock &
pid="$!"

sleep 10

curl --unix-socket /tmp/network.sock http:/unix/services/forwarder/expose -X POST -d '{"local":":8443","remote":"192.168.127.2:443"}'

# Run enclave in debug mode and attach console, to see what's going on
# inside.  Note that this disables remote attestation.
echo "[ec2] Starting enclave."
nitro-cli run-enclave \
	--cpu-count 2 \
	--memory 600 \
	--enclave-cid 4 \
	--eif-path "$image_eif" 

echo "[ec2] Stopping gvproxy."
sudo kill -INT "$pid"
