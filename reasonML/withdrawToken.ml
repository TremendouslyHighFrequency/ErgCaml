/* Initial Variables */
let swampAudioNode = pkToPropBytes("9hKFHa886348VhfM1BRfLPKi8wwXMnyVqqmri9p5zPFE8qgMMui");
let withdrawFee: int64 = 10000000L;
let withdrawIndictationScript = fromBase58("5XykR68c3FDk2edgiug1WVS9RYnZjm7egu9VGHq9kiNWmTYxKMLUb652hBwssbL4e4rhwcLJVzWBWoMVeBmrmCzz5");

/* SELF Variables */
let heldERG0 = SELF.value;
let heldTokens0 = SELF.tokens;
let initialShares = SELF.R4->get((int, bytes) list);
let initialTokenList = SELF.R5->get(bytes list);
let initialTokenAmount = SELF.R6->get(int);
let initialWithdrawTokens = SELF.R7->get((bytes, int));
if (CONTEXT.dataInputs->List.size == 0) {
  /* Deposit Scenario */
  let successor = OUTPUTS->Array.get(0);
  let heldERG1 = successor.value;
  let heldTokens1 = successor.tokens;
  let finalShares = successor.R4->Option.get;
  let finalTokenList = successor.R5->Option.get;
  let finalTokenAmount = successor.R6->Option.get;
  let finalWithdrawTokens = successor.R7->Option.get;
  let deltaERG = heldERG1 - heldERG0;
  let validSelfSuccessorScript = successor.propositionBytes == SELF.propositionBytes;
  let validDeltaERG = deltaERG >= 0;
  let validRegisters = (
    finalShares == initialShares &&
    finalTokenList == initialTokenList &&
    finalTokenAmount == initialTokenAmount - 1 &&
    finalWithdrawTokens == initialWithdrawTokens
  );
  let validSuccessorTokens = initialTokenList->List.for_all(id =>
    successor.tokens->List.exists((token_id, amount) => token_id == id && amount >= finalTokenAmount)
  );
  let validShares = initialShares->List.for_all((share_amount, share_propBytes) =>
    OUTPUTS->List.exists(output => output.propositionBytes == share_propBytes && output.value >= share_amount)
  );
  let depositConditions = (
    validSelfSuccessorScript &&
    validDeltaERG &&
    validSuccessorTokens &&
    validRegisters
  );
  depositConditions;
} else {
  /* Withdrawal Scenario */
  let withdrawalIndication = CONTEXT.dataInputs->List.get(0);
  let withdrawalTokens = withdrawalIndication.tokens->Array.get(0);
  let validIndication = initialWithdrawTokens == withdrawalTokens;
  let validWithdrawScript = blake2b256(withdrawalIndication.propositionBytes) == withdrawIndictationScript;
  let successor = OUTPUTS->Array.get(0);
  let swampAudioBox = OUTPUTS->Array.get(1);
  let withdrawalBox = OUTPUTS->Array.get(2);
  let tokenWithdrawalIndex = withdrawalBox.R4->Option.get;
  let withdrawnTokens = withdrawalBox.tokens->Array.get(0);
  let heldERG1 = successor.value;
  let heldTokens1 = successor.tokens;
  let finalShares = successor.R4->Option.get;
  let finalTokenList = successor.R5->Option.get;
  let finalTokenAmount = successor.R6->Option.get;
  let finalWithdrawTokens = successor.R7->Option.get;
  let validSelfSuccessorScript = successor.propositionBytes == SELF.propositionBytes;
  let filteredWithdrawInitialTokens = heldTokens0->Array.filter(token =>
    token._0 != initialTokenList->Array.get(tokenWithdrawalIndex)
  );
  let filteredWithdrawFinalTokens = heldTokens1->Array.filter(token =>
    token._0 != initialTokenList->Array.get(tokenWithdrawalIndex)
  );
  let validSuccessorWithdrawnTokens = filteredWithdrawInitialTokens == filteredWithdrawFinalTokens;
  let validRegisters = (
    finalShares == initialShares &&
    finalTokenList == initialTokenList &&
    finalTokenAmount == initialTokenAmount &&
    finalWithdrawTokens == initialWithdrawTokens
  );
  let validWithdrawer = withdrawalBox.propositionBytes == initialShares->Array.get(tokenWithdrawalIndex)._2;
  let validTokensWithdrawn = (
    withdrawnTokens._0 == initialTokenList->Array.get(tokenWithdrawalIndex) &&
    withdrawnTokens._1 >= initialTokenAmount
  );
  let validSwampAudioScript = swampAudioBox.propositionBytes == swampAudioNode;
  let validSwampValue = swampAudioBox.value >= withdrawFee;
  let withdrawalConditions = (
    validWithdrawer &&
    validTokensWithdrawn &&
    validSwampValue &&
    validSwampAudioScript &&
    validSelfSuccessorScript &&
    validSuccessorWithdrawnTokens &&
    validIndication &&
    validWithdrawScript &&
    validRegisters
  );
  withdrawalConditions;
};
let validDeposit = (
  validSelfSuccessorScript &&
  validDeltaERG &&
  validDeltaTokens &&
  validRegisters
);

let validSaleSuccessorScript = blake2b256(successor.propositionBytes) == saleSuccessorScript;

let validSuccessorTokens = initialTokenList->List.for_all(id =>
  successor.tokens->List.exists((token_id, amount) => token_id == id && amount >= finalTokenAmount)
);

let terminationConditions = if (OUTPUTS->List.length > 2 && OUTPUTS->List.get(1).tokens->Array.length > 0) {
  let termination = OUTPUTS->List.get(1);
  let terminationToken = terminationToken->Array.get(0);
  let terminationParties = termination.R7->Option.get;
  let withdrawalRegister = successor.R7->Option.get;
  let validTerminationScript = blake2b256(termination.propositionBytes) == terminationScript;
  let validToken = terminationToken->_0 == SELF.id && terminationToken->_1 == terminationParties->Array.length;
  let validParties = terminationParties == initialShares;
  let validWithdrawalRegister = withdrawalRegister == terminationToken;
  validTerminationScript && validToken && validParties && validWithdrawalRegister;
} else {
  false;
};

let validSaleCombine = (
  validSaleSuccessorScript &&
  validSuccessorTokens &&
  validRegisters &&
  terminationConditions
);

let swampAudioBox = OUTPUTS->List.get(1);

let validSwampAudioScript = swampAudioBox.propositionBytes == swampAudioNode;

let validSwampValue = swampAudioBox.value >= withdrawFee;

let withdrawBoxConditions = if (OUTPUTS->List.length > 3) {
  let withdrawBox = OUTPUTS->List.get(2);
  let providedWithdrawIndex = withdrawBox.R4->Option.get;
  let validWithdrawScript = withdrawBox.propositionBytes == initialShares->Array.get(providedWithdrawIndex)->_1;
  let validWithdrawTokens = (
    withdrawBox.tokens->Array.get(0)->_0 == initialTokenList->Array.get(providedWithdrawIndex) &&
    withdrawBox.tokens->Array.get(0)->_1 >= initialTokenAmount
  );
  let filteredWithdrawInitialTokens = slicedInitialTokens->Array.filter(token =>
    token->_0 != initialTokenList->Array.get(providedWithdrawIndex)
  );
  let filteredWithdrawFinalTokens = slicedFinalTokens->Array.filter(token =>
    token->_0 != initialTokenList->Array.get(providedWithdrawIndex)
  );
  let validSuccessorWithdrawnTokens = filteredWithdrawInitialTokens == filteredWithdrawFinalTokens;
  validWithdrawScript && validWithdrawTokens && validSuccessorWithdrawnTokens;
} else {
  false;
};

let validWithdraw = (
  validSwampAudioScript &&
  validSwampValue &&
  withdrawBoxConditions &&
  validRegisters &&
  validSelfSuccessorScript &&
  validDeltaERG
);

sigmaProp(
  validDeposit ||
  validSaleCombine ||
  validWithdraw
);
