#!/bin/sh
#
# Copyright IBM Corp All Rights Reserved
#
# SPDX-License-Identifier: Apache-2.0
#
export PATH=$GOPATH/src/github.com/hyperledger/fabric/build/bin:${PWD}/../bin:${PWD}:$PATH
export FABRIC_CFG_PATH=${PWD}
export CHANNEL_NAME=sigchannel

# remove previous crypto material and config transactions
rm -fr config/*
rm -fr crypto-config/*

# generate crypto material
cryptogen generate --config=./crypto-config.yaml
if [ "$?" -ne 0 ]; then
  echo "Failed to generate crypto material..."
  exit 1
fi

# generate genesis block for orderer
configtxgen -profile OneOrgOrdererGenesis -outputBlock ./config/genesis.block
if [ "$?" -ne 0 ]; then
  echo "Failed to generate orderer genesis block..."
  exit 1
fi

# generate channel configuration transaction
configtxgen -profile OneOrgChannel -outputCreateChannelTx ./config/sigchannel.tx -channelID $CHANNEL_NAME
if [ "$?" -ne 0 ]; then
  echo "Failed to generate channel configuration transaction..."
  exit 1
fi

# generate anchor peer transaction
configtxgen -profile OneOrgChannel -outputAnchorPeersUpdate ./config/StatoMSPanchors.tx -channelID $CHANNEL_NAME -asOrg StatoMSP
if [ "$?" -ne 0 ]; then
  echo "Failed to generate anchor peer update for StatoMSP..."
  exit 1
fi

#-------------------------------------------------------------------------------
#
#   Start the network
#
#-------------------------------------------------------------------------------
# Exit on first error, print all commands.
set -ev

# don't rewrite paths for Windows Git Bash users
export MSYS_NO_PATHCONV=1

docker-compose -f docker-compose.yml down

docker-compose -f docker-compose.yml up -d

# wait for Hyperledger Fabric to start
# incase of errors when running later commands, issue export FABRIC_START_TIMEOUT=<larger number>
export FABRIC_START_TIMEOUT=10
#echo ${FABRIC_START_TIMEOUT}
sleep ${FABRIC_START_TIMEOUT}

# Create the channel
docker exec -e "CORE_PEER_LOCALMSPID=StatoMSP" -e "CORE_PEER_MSPCONFIGPATH=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/stato.eurasia.com/users/Admin@stato.eurasia.com/msp" -e "CORE_PEER_ADDRESS=peer0.stato.eurasia.com:7051" cli peer channel create -o orderer.eurasia.com:7050 -c sigchannel -f /opt/gopath/src/github.com/hyperledger/fabric/peer/config/sigchannel.tx
# Join peer0.stato.eurasia.com to the channel.
docker exec -e "CORE_PEER_LOCALMSPID=StatoMSP" -e "CORE_PEER_MSPCONFIGPATH=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/stato.eurasia.com/users/Admin@stato.eurasia.com/msp" -e "CORE_PEER_ADDRESS=peer0.stato.eurasia.com:7051" cli peer channel join -b sigchannel.block
