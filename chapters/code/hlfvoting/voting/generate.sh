cryptogen generate --config=./crypto-config.yaml
export FABRIC_CFG_PATH=$PWD
configtxgen -profile VotingOrdererGenesis -outputBlock ./voting-genesis.block
configtxgen -profile VotingChannel -outputCreateChannelTx ./voting-channel.tx -channelID votingchannel