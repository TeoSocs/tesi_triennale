/**
* Vote for a candidate
* @param {eurasia.voting.Voting} voting - the vote to be processed
* @transaction
*/
function newVote(voting) {
	// This computation should be performed off-chain, now it's executed here onlu for test purpose
	var mySig = computeSig(voting.signature);
	// Check if there is another vote created by the same voter
	return getAssetRegistry('eurasia.voting.Vote')
		.then(function (assetRegistry) {
			return assetRegistry.getAll();
		})
		.then(function (voteList) {
			voteList.forEach(function (vote) {
				if (haveSameSigner(mySig, vote.voteSig)) {
					throw new Error('Voter has already voted');
				}
			})
			return;
		})
		// Create the Vote asset
		.then(function () {
			// Get the factory for creating new asset instances
			var factory = getFactory();
			// Create the vote.
			var vote = factory.newResource('eurasia.voting', 'Vote', new Date().getTime().toString());
			vote.voteSig = mySig;
			vote.group = voting.group;
			vote.recipient = voting.recipient;
			voting.recipient.balance++;
			// Update the registry
			return getAssetRegistry('eurasia.voting.Vote')
				.then(function (voteRegistry) {
					// Update the asset in the asset registry. Again, note
					// that update() returns a promise, so so we have to return
					// the promise so that Composer waits for it to be resolved.
					return voteRegistry.add(vote)
				})
				.then(function () {
					return getAssetRegistry('eurasia.voting.Candidate')
				})
				.then(function (candidateRegistry) {
					return candidateRegistry.update(voting.recipient);
				});
		})
}

/**
* Change the recipient of a Vote
* @param {eurasia.voting.Change} change - the change operation to be processed
* @transaction
*/
function changeVote(change) {
	// This computation should be performed off-chain, now it's executed here onlu for test purpose
	var mySig = computeSig(change.signature);
	if (!haveSameSigner(mySig, change.vote.voteSig)) {
		throw new Error("Signature not matching, you can't change this vote");
	}
	var oldRecipient = change.vote.recipient;
	change.vote.recipient.balance--;
	change.vote.recipient = change.newRecipient;
	change.newRecipient.balance++;
	return getAssetRegistry('eurasia.voting.Vote')
		.then(function (voteRegistry) {
			// Update the asset in the asset registry. Again, note
			// that update() returns a promise, so so we have to return
			// the promise so that Composer waits for it to be resolved.
			return voteRegistry.update(change.vote)
		})
		.then(function () {
			return getAssetRegistry('eurasia.voting.Candidate')
		})
		.then(function (candidateRegistry) {
			return candidateRegistry.updateAll([change.newRecipient, oldRecipient]);
		});
}

/*
* This function should represent the implementation of a linkable ring signature algorythm. In this PoC it will return a simple timestamp + an arbitrary id
*/
function computeSig(mySig) {
	var sig = new Array(new Date().getTime().toString());
	sig.push(mySig);
	return sig;
}

/*
* This function should represent the verification of a linkable ring signature
*/
function haveSameSigner(sig1, sig2) {
	if (sig1[1] === sig2[1]) {
		return true;
	}
	return false;
}