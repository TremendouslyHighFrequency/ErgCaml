let pkToPropBytes = pk => {
  /* Implementation needed */
};

/* Initial Variables */
let swampAudioNode = pkToPropBytes("9hKFHa886348VhfM1BRfLPKi8wwXMnyVqqmri9p5zPFE8qgMMui");
let withdrawFee: int64 = 10000000L;

/* SELF Variables */
let initialWithdrawalTokens = SELF.tokens[0];
let tokenOwners = SELF.R4->get((int, bytes) list);
let mintTokenDetails = SELF.R5->get((bytes, int));

/* Successor Variables */
let successor = OUTPUTS[0];
let finalTokenOwners = successor.R4->get((int, bytes) list);
let finalMintTokenDetails = successor.R5->get((bytes, int));

/* Handling No Data Inputs */
if (CONTEXT.dataInputs.size == 0) {
  let heldERG1 = successor.value;
  let heldTokens1 = successor.tokens;
  let finalShares = successor.R4->get((int, bytes) list);
  let finalTokenList = successor.R5->get(bytes list);
  let finalTokenAmount = successor.R6->get(int);
  let finalWithdrawTokens = successor.R7->get((bytes, int));

  let deltaERG = heldERG1 - heldERG0;
  let validSelfSuccessorScript = successor.propositionBytes == SELF.propositionBytes;
  let validDeltaERG = deltaERG >= 0;

  let validRegisters = (
    finalShares == initialShares &&
    finalTokenList == initialTokenList &&
    finalTokenAmount == initialTokenAmount - 1 &&
    finalWithdrawTokens == initialWithdrawTokens
  );

  let validSuccessorTokens = finalTokenList->List.for_all(id =>
    successor.tokens->List.exists((token_id, amount) => token_id == id && amount >= finalTokenAmount)
  );

  let validShares = finalShares->List.for_all((share_amount, share_propBytes) =>
    OUTPUTS->List.exists(output => output.propositionBytes == share_propBytes && output.value >= share_amount)
  );

  /* Combining Validations */
  let sigmaPropEquivalent =
    validSelfSuccessorScript &&
    validDeltaERG &&
    validRegisters &&
    validSuccessorTokens &&
    validShares;

} else {
  /* Else Condition Logic - When There Are Data Inputs */
  let withdrawalIndication = CONTEXT.dataInputs[0];

  let withdrawalTokens = withdrawalIndication.tokens[0];
  
  let validIndication = initialWithdrawTokens == withdrawalTokens;
  let validWithdrawScript = blake2b256(withdrawalIndication.propositionBytes) == withdrawIndictationScript;
  
  let successor = OUTPUTS[0];
  let swampAudioBox = OUTPUTS[1];
  let withdrawalBox = OUTPUTS[2];
  
  let tokenWithdrawalIndex = withdrawalBox.R4->get(int);
  let withdrawnTokens = withdrawalBox.tokens[0];
  
  let heldERG1 = successor.value;
  let heldTokens1 = successor.tokens;
  let finalShares = successor.R4->get((int, bytes) list);
  let finalTokenList = successor.R5->get(bytes list);
  let finalTokenAmount = successor.R6->get(int);
  let finalWithdrawTokens = successor.R7->get((bytes, int));
  
  let validSelfSuccessorScript = successor.propositionBytes == SELF.propositionBytes;
  
  let filteredWithdrawInitialTokens = heldTokens0->List.filter((token_id, _) => token_id != initialTokenList[tokenWithdrawalIndex]);
  let filteredWithdrawFinalTokens = heldTokens1->List.filter((token_id, _) => token_id != initialTokenList[tokenWithdrawalIndex]);
  
  let validSuccessorWithdrawnTokens = filteredWithdrawInitialTokens == filteredWithdrawFinalTokens;
  
  let validRegisters = (
    finalShares == initialShares &&
    finalTokenList == initialTokenList &&
    finalTokenAmount == initialTokenAmount &&
    finalWithdrawTokens == initialWithdrawTokens
  );
  
  let validWithdrawer = withdrawalBox.propositionBytes == initialShares[tokenWithdrawalIndex][1];
  let validTokensWithdrawn = withdrawnTokens[0] == initialTokenList[tokenWithdrawalIndex] && withdrawnTokens[1] >= initialTokenAmount;
  
  let validSwampAudioScript = swampAudioBox.propositionBytes == swampAudioNode;
  let validSwampValue = swampAudioBox.value >= withdrawFee;

  /* Combining All Validations */
  let sigmaPropEquivalentElse =
    validWithdrawer &&
    validTokensWithdrawn &&
    validSwampValue &&
    validSwampAudioScript &&
    validSelfSuccessorScript &&
    validSuccessorWithdrawnTokens &&
    validIndication &&
    validWithdrawScript &&
    validRegisters;
};
