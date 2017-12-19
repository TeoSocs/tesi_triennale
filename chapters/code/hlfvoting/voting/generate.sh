../../bin/cryptogen generate --config=./crypto-config.yaml
export FABRIC_CFG_PATH=$PWD/
../../bin/configtxgen -profile VotingOrdererGenesis -outputBlock ./voting-genesis.block
../../bin/configtxgen -profile VotingChannel -outputCreateChannelTx ./voting-channel.tx -channelID votingchannel
