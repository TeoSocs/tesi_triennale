/**
* Vote for a candidate
* @param {eurasia.voting.Voting} voting - the vote to be processed
* @transaction
*/
function newVote(voting) {	
	// Get the factory for creating new asset instances
	var factory = getFactory();
	// Create the vote.
	var vote = factory.newResource('eurasia.voting', 'Vote', computeSig(voting.signature));
	vote.group = voting.group;
	vote.recipient = voting.recipient;
	voting.recipient.balance++;
	return getAssetRegistry('eurasia.voting.Vote')
		.then(function (assetRegistry) {
			// Update the asset in the asset registry. Again, note
			// that update() returns a promise, so so we have to return
			// the promise so that Composer waits for it to be resolved.
			return assetRegistry.add(vote)
		})
		.then(function () {
			return getParticipantRegistry('eurasia.voting.Candidate')
		})
		.then(function (participantRegistry) {
			return participantRegistry.update(voting.recipient);
		});
}

/*
* This function should represent the implementation of a linkable ring signature algorythm. In this PoC it will return a simple timestamp + an arbitrary id
*/
function computeSig(mySig){
	var sig = new Date().valueOf();
	sig += mySig;
	return sig;
}