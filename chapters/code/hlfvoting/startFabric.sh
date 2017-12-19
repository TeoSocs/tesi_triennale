#!/bin/bash

# Exit on first error, print all commands.
set -ev

#Detect architecture
ARCH=`uname -m`

# Grab the current directory
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

#

ARCH=$ARCH docker-compose -f "${DIR}"/voting/docker-compose.yml down
ARCH=$ARCH docker-compose -f "${DIR}"/voting/docker-compose.yml up -d

# wait for Hyperledger Fabric to start
# incase of errors when running later commands, issue export FABRIC_START_TIMEOUT=<larger number>
echo ${FABRIC_START_TIMEOUT}
sleep ${FABRIC_START_TIMEOUT}

# Create the channel
docker exec peer0.Stato.eurasia.com peer channel create -o orderer.eurasia.com:7050 -c votingchannel -f /etc/hyperledger/configtx/voting-channel.tx

# Join peer0.stato.eurasia.com to the channel.
docker exec -e "CORE_PEER_MSPCONFIGPATH=/etc/hyperledger/msp/users/Admin@stato.eurasia.com/msp" peer0.Stato.eurasia.com peer channel join -b votingchannel.block
