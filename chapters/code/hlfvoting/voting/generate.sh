#!/bin/bash

# Exit on first error
set -e
# Grab the current directory
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

rm -rf crypto-config voting-genesis.block voting-channel.tx

ls -laG

${DIR}/../../bin/cryptogen generate --config=${DIR}/crypto-config.yaml
export FABRIC_CFG_PATH=$PWD/
${DIR}/../../bin/configtxgen -profile VotingOrdererGenesis -outputBlock ${DIR}/voting-genesis.block
${DIR}/../../bin/configtxgen -profile VotingChannel -outputCreateChannelTx ${DIR}/voting-channel.tx -channelID votingchannel

ls -laG
