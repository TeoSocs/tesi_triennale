################################################################################
#
#   Lancia la rete
#   Devono essere pronti e preconfigurati i seguenti file:
#       - crypto-config.yaml
#       - configtx.yaml
#       - docker-compose.yml
#           - al momento e' commentato, vuole del chaincode in ./chaincode
#
################################################################################

mkdir channel-artifacts
cryptogen generate --config=./crypto-config.yaml
# crea rispettive chiavi nella cartella ./crypto-config

export FABRIC_CFG_PATH=$PWD
mkdir channel-artifacts
configtxgen -profile EurasiaOrdererGenesis -outputBlock ./channel-artifacts/genesis.block
configtxgen -profile SignatureChannel -outputCreateChannelTx ./channel-artifacts/signature_channel.tx -channelID sigChannel
configtxgen -profile VoteChannel -outputCreateChannelTx ./channel-artifacts/vote_channel.tx -channelID vtChannel

# Fisso gli anchor peer per ogni organizzazione in ciascun canale
configtxgen -profile SignatureChannel -outputAnchorPeersUpdate ./channel-artifacts/sigStatoMSPanchors.tx -channelID sigChannel -asOrg Stato
configtxgen -profile VoteChannel -outputAnchorPeersUpdate ./channel-artifacts/vtStatoMSPanchors.tx -channelID vtChannel -asOrg Stato
configtxgen -profile VoteChannel -outputAnchorPeersUpdate ./channel-artifacts/vtRepubblicaniMSPanchors.tx -channelID vtChannel -asOrg Repubblicani
configtxgen -profile VoteChannel -outputAnchorPeersUpdate ./channel-artifacts/vtMonarchiciMSPanchors.tx -channelID vtChannel -asOrg Monarchici

# Butto su tutto
# Exit on first error, print all commands.
set -ev
# don't rewrite paths for Windows Git Bash users
export MSYS_NO_PATHCONV=1
docker-compose -f docker-compose.yml down
TIMEOUT=72000 docker-compose -f docker-compose.yml up -d

# wait for Hyperledger Fabric to start
# incase of errors when running later commands, issue export FABRIC_START_TIMEOUT=<larger number>
export FABRIC_START_TIMEOUT=10
#echo ${FABRIC_START_TIMEOUT}
sleep ${FABRIC_START_TIMEOUT}


#===============================================================================
# CREO I CHANNEL E FACCIO IL JOIN
#===============================================================================
#-------------------------------------------------------------------------------
# per peer0.Stato
#-------------------------------------------------------------------------------
export CORE_PEER_MSPCONFIGPATH=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/Stato.eurasia.com/users/Admin@Stato.eurasia.com/msp
export CORE_PEER_ADDRESS=peer0.Stato.eurasia.com:7051
export CORE_PEER_LOCALMSPID="StatoMSP"
export CORE_PEER_TLS_ROOTCERT_FILE=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/Stato.eurasia.com/peers/peer0.Stato.eurasia.com/tls/ca.crt
#
#   sigChannel
#
docker exec -e CORE_PEER_LOCALMSPID -e CORE_PEER_MSPCONFIGPATH -e CORE_PEER_ADDRESS -e CORE_PEER_TLS_ROOTCERT_FILE cli peer channel create -o orderer.eurasia.com:7050 -c sigChannel -f ./channel-artifacts/signature_channel.tx --tls $CORE_PEER_TLS_ENABLED --cafile /opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/ordererOrganizations/eurasia.com/orderers/orderer.eurasia.com/msp/tlscacerts/tlsca.eurasia.com-cert.pem
#   anchor peer
docker exec -e CORE_PEER_LOCALMSPID -e CORE_PEER_MSPCONFIGPATH -e CORE_PEER_ADDRESS -e CORE_PEER_TLS_ROOTCERT_FILE cli peer channel update -o orderer.eurasia.com:7050 -c sigChannel -f ./channel-artifacts/sigStatoMSPanchors.tx --tls $CORE_PEER_TLS_ENABLED --cafile /opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/ordererOrganizations/eurasia.com/orderers/orderer.eurasia.com/msp/tlscacerts/tlsca.eurasia.com-cert.pem
#   join
docker exec -e CORE_PEER_LOCALMSPID -e CORE_PEER_MSPCONFIGPATH -e CORE_PEER_ADDRESS -e CORE_PEER_TLS_ROOTCERT_FILE cli peer channel join -b sigChannel.block
#
#   vtChannel
#
docker exec -e CORE_PEER_LOCALMSPID -e CORE_PEER_MSPCONFIGPATH -e CORE_PEER_ADDRESS -e CORE_PEER_TLS_ROOTCERT_FILE cli peer channel create -o orderer.eurasia.com:7050 -c vtChannel -f ./channel-artifacts/vote_channel.tx --tls $CORE_PEER_TLS_ENABLED --cafile /opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/ordererOrganizations/eurasia.com/orderers/orderer.eurasia.com/msp/tlscacerts/tlsca.eurasia.com-cert.pem
#   anchor peer
docker exec -e CORE_PEER_LOCALMSPID -e CORE_PEER_MSPCONFIGPATH -e CORE_PEER_ADDRESS -e CORE_PEER_TLS_ROOTCERT_FILE cli peer channel update -o orderer.eurasia.com:7050 -c vtChannel -f ./channel-artifacts/vtStatoMSPanchors.tx --tls $CORE_PEER_TLS_ENABLED --cafile /opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/ordererOrganizations/eurasia.com/orderers/orderer.eurasia.com/msp/tlscacerts/tlsca.eurasia.com-cert.pem
#   join
docker exec -e CORE_PEER_LOCALMSPID -e CORE_PEER_MSPCONFIGPATH -e CORE_PEER_ADDRESS -e CORE_PEER_TLS_ROOTCERT_FILE cli peer channel join -b vtChannel.block
#
#
#-------------------------------------------------------------------------------
# per peer0.Repubblicani
#-------------------------------------------------------------------------------
export CORE_PEER_MSPCONFIGPATH=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/Repubblicani.eurasia.com/users/Admin@Repubblicani.eurasia.com/msp
export CORE_PEER_ADDRESS=peer0.Repubblicani.eurasia.com:7051
export CORE_PEER_LOCALMSPID="RepubblicaniMSP"
export CORE_PEER_TLS_ROOTCERT_FILE=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/Repubblicani.eurasia.com/peers/peer0.Repubblicani.eurasia.com/tls/ca.crt
#
#   vtChannel
#
docker exec -e CORE_PEER_LOCALMSPID -e CORE_PEER_MSPCONFIGPATH -e CORE_PEER_ADDRESS -e CORE_PEER_TLS_ROOTCERT_FILE cli peer channel create -o orderer.eurasia.com:7050 -c vtChannel -f ./channel-artifacts/vote_channel.tx --tls $CORE_PEER_TLS_ENABLED --cafile /opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/ordererOrganizations/eurasia.com/orderers/orderer.eurasia.com/msp/tlscacerts/tlsca.eurasia.com-cert.pem
#   anchor peer
docker exec -e CORE_PEER_LOCALMSPID -e CORE_PEER_MSPCONFIGPATH -e CORE_PEER_ADDRESS -e CORE_PEER_TLS_ROOTCERT_FILE cli peer channel update -o orderer.eurasia.com:7050 -c vtChannel -f ./channel-artifacts/vtRepubblicaniMSPanchors.tx --tls $CORE_PEER_TLS_ENABLED --cafile /opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/ordererOrganizations/eurasia.com/orderers/orderer.eurasia.com/msp/tlscacerts/tlsca.eurasia.com-cert.pem
#   join
docker exec -e CORE_PEER_LOCALMSPID -e CORE_PEER_MSPCONFIGPATH -e CORE_PEER_ADDRESS -e CORE_PEER_TLS_ROOTCERT_FILE cli peer channel join -b vtChannel.block
#
#
#-------------------------------------------------------------------------------
# per peer0.Monarchici
#-------------------------------------------------------------------------------
export CORE_PEER_MSPCONFIGPATH=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/Monarchici.eurasia.com/users/Admin@Monarchici.eurasia.com/msp
export CORE_PEER_ADDRESS=peer0.Monarchici.eurasia.com:7051
export CORE_PEER_LOCALMSPID="MonarchiciMSP"
export CORE_PEER_TLS_ROOTCERT_FILE=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/Monarchici.eurasia.com/peers/peer0.Monarchici.eurasia.com/tls/ca.crt
#
#   vtChannel
#
docker exec -e CORE_PEER_LOCALMSPID -e CORE_PEER_MSPCONFIGPATH -e CORE_PEER_ADDRESS -e CORE_PEER_TLS_ROOTCERT_FILE cli peer channel create -o orderer.eurasia.com:7050 -c vtChannel -f ./channel-artifacts/vote_channel.tx --tls $CORE_PEER_TLS_ENABLED --cafile /opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/ordererOrganizations/eurasia.com/orderers/orderer.eurasia.com/msp/tlscacerts/tlsca.eurasia.com-cert.pem
#   anchor peer
docker exec -e CORE_PEER_LOCALMSPID -e CORE_PEER_MSPCONFIGPATH -e CORE_PEER_ADDRESS -e CORE_PEER_TLS_ROOTCERT_FILE cli peer channel update -o orderer.eurasia.com:7050 -c vtChannel -f ./channel-artifacts/vtMonarchiciMSPanchors.tx --tls $CORE_PEER_TLS_ENABLED --cafile /opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/ordererOrganizations/eurasia.com/orderers/orderer.eurasia.com/msp/tlscacerts/tlsca.eurasia.com-cert.pem
#   join
docker exec -e CORE_PEER_LOCALMSPID -e CORE_PEER_MSPCONFIGPATH -e CORE_PEER_ADDRESS -e CORE_PEER_TLS_ROOTCERT_FILE cli peer channel join -b vtChannel.block

