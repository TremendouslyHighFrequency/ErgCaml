let fromBase58 = str => {
  /* Implementation needed */
};

let blake2b256 = bytes => {
  /* Implementation needed */
};

let pkToPropBytes = pk => {
  /* Implementation needed */
};

/* Initial Variables */
let withdrawFee: int64 = 10000000L;
let saleSuccessorScript = fromBase58("2wjy8dSAvwKdmCcaz1XwjKdcHjsvHqhHPh4FzshLcZ3AunL6ZykaedY1S3vjevgcSvVoiGJ5K2bGarWmjA5C6R4X");
let terminationScript = fromBase58("32NjucdcZFvQfcjDY3it2jDNerkrG7ue8KMEzzC4eCfosWFb7roQVwFkQ6sH7m97W9zwNLraFw6r1FVUfo2VaZJ1");
let swampAudioNode = pkToPropBytes("9hKFHa886348VhfM1BRfLPKi8wwXMnyVqqmri9p5zPFE8qgMMui");

/* SELF Variables */
let heldERG0 = SELF.value;
let heldTokens0 = SELF.tokens;
let initialShares = SELF.R4->get((int, bytes) list);
let initialTokenList = SELF.R5->get(bytes list);
let initialTokenAmount = SELF.R6->get(int);

/* Successor Variables */
let successor = OUTPUTS[0];
let heldERG1 = successor.value;
let heldTokens1 = successor.tokens;
let finalShares = successor.R4->get((int, bytes) list);
let finalTokenList = successor.R5->get(bytes list);
let finalTokenAmount = successor.R6->get(int);
let finalWithdrawTokens = successor.R7->get((bytes, int));

/* Delta Calculations */
let deltaERG = heldERG1 - heldERG0;

/* Validations */
let validSelfSuccessorScript = successor.propositionBytes == SELF.propositionBytes;
let validDeltaERG = deltaERG >= 0;

let validRegisters = {
  finalShares == initialShares &&
  finalTokenList == initialTokenList &&
  finalTokenAmount == initialTokenAmount - 1 &&
  finalWithdrawTokens == initialWithdrawTokens
};

let validSuccessorTokens = initialTokenList->List.for_all(id =>
  successor.tokens->List.exists((token_id, amount) => token_id == id && amount >= finalTokenAmount)
);

let validShares = initialShares->List.for_all((share_amount, share_propBytes) =>
  OUTPUTS->List.exists(output => output.propositionBytes == share_propBytes && output.value >= share_amount)
);

let sigmaPropEquivalent =
  validSelfSuccessorScript &&
  validDeltaERG &&
  validSuccessorTokens &&
  validRegisters &&
  validShares;
