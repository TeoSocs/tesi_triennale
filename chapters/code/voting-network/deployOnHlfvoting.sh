DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

composer runtime install --card PeerAdmin@voting-network --businessNetworkName voting-network

composer network start --card PeerAdmin@voting-network --networkAdmin businessNetworkAdmin --networkAdminEnrollSecret adminpw --archiveFile ${DIR}/voting-network@0.0.1.bna --file ${DIR}/votingnetworkadmin.card

composer card import --file ${DIR}/votingnetworkadmin.card

composer network ping --card businessNetworkAdmin@voting-network
