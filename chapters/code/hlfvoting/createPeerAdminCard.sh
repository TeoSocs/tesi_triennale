#!/bin/bash

# Exit on first error
set -e
# Grab the current directory
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

echo
# check that the composer command exists at a version >v0.14
if hash composer 2>/dev/null; then
    composer --version | awk -F. '{if ($2<15) exit 1}'
    if [ $? -eq 1 ]; then
        echo 'Sorry, Use createConnectionProfile for versions before v0.15.0' 
        exit 1
    else
        echo Using composer-cli at $(composer --version)
    fi
else
    echo 'Need to have composer-cli installed at v0.15 or greater'
    exit 1
fi
# need to get the certificate 

cat << EOF > /tmp/.connection.json
{
    "name": "voting-network",
    "type": "hlfv1",
    "orderers": [
       { "url" : "grpc://localhost:7050" }
    ],
    "ca": { "url": "http://localhost:7054", "name": "ca.Stato.eurasia.com"},
    "peers": [
        {
            "requestURL": "grpc://localhost:7051",
            "eventURL": "grpc://localhost:7053"
        }
    ],
    "channel": "votingchannel",
    "mspID": "StatoMSP",
    "timeout": 300
}
EOF

PRIVATE_KEY="${DIR}"/voting/crypto-config/peerOrganizations/Stato.eurasia.com/users/Admin@Stato.eurasia.com/msp/keystore/d4d96ae0abb5b66eb9077b2e18383ccaed9b8243b83032635175cfa17a91724b_sk
CERT="${DIR}"/voting/crypto-config/peerOrganizations/Stato.eurasia.com/users/Admin@Stato.eurasia.com/msp/signcerts/Admin@Stato.eurasia.com-cert.pem

if composer card list -n PeerAdmin@hlfvoting > /dev/null; then
    composer card delete -n PeerAdmin@hlfvoting
fi
composer card create -p /tmp/.connection.json -u PeerAdmin -c "${CERT}" -k "${PRIVATE_KEY}" -r PeerAdmin -r ChannelAdmin --file /tmp/PeerAdmin@hlfvoting.card
composer card import --file /tmp/PeerAdmin@hlfvoting.card 

rm -rf /tmp/.connection.json

echo "Hyperledger Composer card for PeerAdmin at voting-network has been imported"
composer card list

