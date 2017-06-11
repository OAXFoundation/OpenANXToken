// May 20 2017
var ethPriceUSD = 127.2;

// -----------------------------------------------------------------------------
// Accounts
// -----------------------------------------------------------------------------
var accounts = [];
var accountNames = {};

addAccount(eth.accounts[0], "Account #0 - Miner");
addAccount(eth.accounts[1], "Account #1 - Token Owner");
addAccount(eth.accounts[2], "Account #2 - KYCed");
addAccount(eth.accounts[3], "Account #3 - KYCed");
addAccount(eth.accounts[4], "Account #4");
addAccount(eth.accounts[5], "Account #5");
addAccount(eth.accounts[6], "Account #6 - Crowdfund Wallet");
addAccount(eth.accounts[7], "Account #7 - Foundation");
addAccount(eth.accounts[8], "Account #8 - Advisors");
addAccount(eth.accounts[9], "Account #9 - Directors");
addAccount(eth.accounts[10], "Account #10 - Early Backers");
addAccount(eth.accounts[11], "Account #11 - Developers");
addAccount(eth.accounts[12], "Account #12 - Precommitments");

var minerAccount = eth.accounts[0];
var tokenOwnerAccount = eth.accounts[1];
var account2 = eth.accounts[2];
var account3 = eth.accounts[3];
var account4 = eth.accounts[4];
var account5 = eth.accounts[5];
var crowdfundWallet = eth.accounts[6];
var foundationAccount = eth.accounts[7];
var advisorsAccount = eth.accounts[8];
var directorsAccount = eth.accounts[9];
var earlyBackersAccount = eth.accounts[10];
var developersAccount = eth.accounts[11];
var precommitmentsAccount = eth.accounts[12];


var baseBlock = eth.blockNumber;

function unlockAccounts(password) {
  for (var i = 0; i < 12; i++) {
    personal.unlockAccount(eth.accounts[i], password, 100000);
  }
}

function addAccount(account, accountName) {
  accounts.push(account);
  accountNames[account] = accountName;
}


// -----------------------------------------------------------------------------
// Token Contract
// -----------------------------------------------------------------------------
var tokenContractAddress = null;
var tokenContractAbi = null;
var lockedTokenContractAbi = null;

function addTokenContractAddressAndAbi(address, tokenAbi, lockedTokenAbi) {
  tokenContractAddress = address;
  tokenContractAbi = tokenAbi;
  lockedTokenContractAbi = lockedTokenAbi;
}


// -----------------------------------------------------------------------------
// Account ETH and token balances
// -----------------------------------------------------------------------------
function printBalances() {
  console.log("DEBUG: tokenContractAddress: " + tokenContractAddress);
  console.log("DEBUG: tokenContractAbi: " + tokenContractAbi);
  var token = tokenContractAddress == null || tokenContractAbi == null ? null : web3.eth.contract(tokenContractAbi).at(tokenContractAddress);
  var decimals = token == null ? 18 : token.decimals();
  var lockedTokenContract = token == null || lockedTokenContractAbi == null ? null : web3.eth.contract(lockedTokenContractAbi).at(token.lockedTokens());
  var i = 0;
  var totalTokenBalanceUnlocked = new BigNumber(0);
  var totalTokenBalance1Y = new BigNumber(0);
  var totalTokenBalance2Y = new BigNumber(0);
  var totalTokenBalance = new BigNumber(0);
  console.log("RESULT:  # Account                                             EtherBalanceChange                 Unlocked Token                      Locked 1Y                      Locked 2Y                          Total Name");
  console.log("RESULT: -- ------------------------------------------ --------------------------- ------------------------------ ------------------------------ ------------------------------ ------------------------------ ---------------------------");
  accounts.forEach(function(e) {
    i++;
    var etherBalanceBaseBlock = eth.getBalance(e, baseBlock);
    var etherBalance = web3.fromWei(eth.getBalance(e).minus(etherBalanceBaseBlock), "ether");
    var tokenBalanceUnlocked = token == null ? new BigNumber(0) : token.balanceOf(e).shift(-decimals);
    var tokenBalance1Y = lockedTokenContract == null ? new BigNumber(0) : lockedTokenContract.balanceOfLocked1Y(e).shift(-decimals);
    var tokenBalance2Y = lockedTokenContract == null ? new BigNumber(0) : lockedTokenContract.balanceOfLocked2Y(e).shift(-decimals);
    var tokenBalance = tokenBalanceUnlocked.add(tokenBalance1Y).add(tokenBalance2Y);
    totalTokenBalanceUnlocked = totalTokenBalanceUnlocked.add(tokenBalanceUnlocked);
    totalTokenBalance1Y = totalTokenBalance1Y.add(tokenBalance1Y);
    totalTokenBalance2Y = totalTokenBalance2Y.add(tokenBalance2Y);
    totalTokenBalance = totalTokenBalance.add(tokenBalance);
    console.log("RESULT: " + pad2(i) + " " + e  + " " + pad(etherBalance) + " " + padToken(tokenBalanceUnlocked, decimals) + " " + padToken(tokenBalance1Y, decimals) + " " + 
        padToken(tokenBalance2Y, decimals) + " " + padToken(tokenBalance, decimals) + " " + accountNames[e]);
  });
  console.log("RESULT: -- ------------------------------------------ --------------------------- ------------------------------ ------------------------------ ------------------------------ ------------------------------ ---------------------------");
  console.log("RESULT:                                                                           " + padToken(totalTokenBalanceUnlocked, decimals) + " " + 
      padToken(totalTokenBalance1Y, decimals) + " " + padToken(totalTokenBalance2Y, decimals) + " " + padToken(totalTokenBalance, decimals) + " Total Token Balances *");
  console.log("RESULT: -- ------------------------------------------ --------------------------- ------------------------------ ------------------------------ ------------------------------ ------------------------------ ---------------------------");
  console.log("RESULT: * Note that the sum of all the locked tokens is represented in the unlocked balance at the token contract address, and this will be double counted in the grand total balance above");
  console.log("RESULT: ");
}

function pad2(s) {
  var o = s.toFixed(0);
  while (o.length < 2) {
    o = " " + o;
  }
  return o;
}

function pad(s) {
  var o = s.toFixed(18);
  while (o.length < 27) {
    o = " " + o;
  }
  return o;
}

function padToken(s, decimals) {
  var o = s.toFixed(decimals);
  var l = parseInt(decimals)+12;
  while (o.length < l) {
    o = " " + o;
  }
  return o;
}


// -----------------------------------------------------------------------------
// Transaction status
// -----------------------------------------------------------------------------
function printTxData(name, txId) {
  var tx = eth.getTransaction(txId);
  var txReceipt = eth.getTransactionReceipt(txId);
  var gasPrice = tx.gasPrice;
  var gasCostETH = tx.gasPrice.mul(txReceipt.gasUsed).div(1e18);
  var gasCostUSD = gasCostETH.mul(ethPriceUSD);
  console.log("RESULT: " + name + " gas=" + tx.gas + " gasUsed=" + txReceipt.gasUsed + " costETH=" + gasCostETH +
    " costUSD=" + gasCostUSD + " @ ETH/USD=" + ethPriceUSD + " gasPrice=" + gasPrice + " block=" + 
    txReceipt.blockNumber + " txId=" + txId);
}

function assertEtherBalance(account, expectedBalance) {
  var etherBalance = web3.fromWei(eth.getBalance(account), "ether");
  if (etherBalance == expectedBalance) {
    console.log("RESULT: OK " + account + " has expected balance " + expectedBalance);
  } else {
    console.log("RESULT: FAILURE " + account + " has balance " + etherBalance + " <> expected " + expectedBalance);
  }
}

function gasEqualsGasUsed(tx) {
  var gas = eth.getTransaction(tx).gas;
  var gasUsed = eth.getTransactionReceipt(tx).gasUsed;
  return (gas == gasUsed);
}

function failIfGasEqualsGasUsed(tx, msg) {
  var gas = eth.getTransaction(tx).gas;
  var gasUsed = eth.getTransactionReceipt(tx).gasUsed;
  if (gas == gasUsed) {
    console.log("RESULT: FAIL " + msg);
    return 0;
  } else {
    console.log("RESULT: PASS " + msg);
    return 1;
  }
}

function passIfGasEqualsGasUsed(tx, msg) {
  var gas = eth.getTransaction(tx).gas;
  var gasUsed = eth.getTransactionReceipt(tx).gasUsed;
  if (gas == gasUsed) {
    console.log("RESULT: PASS " + msg);
    return 1;
  } else {
    console.log("RESULT: FAIL " + msg);
    return 0;
  }
}

function failIfGasEqualsGasUsedOrContractAddressNull(contractAddress, tx, msg) {
  if (contractAddress == null) {
    console.log("RESULT: FAIL " + msg);
    return 0;
  } else {
    var gas = eth.getTransaction(tx).gas;
    var gasUsed = eth.getTransactionReceipt(tx).gasUsed;
    if (gas == gasUsed) {
      console.log("RESULT: FAIL " + msg);
      return 0;
    } else {
      console.log("RESULT: PASS " + msg);
      return 1;
    }
  }
}


// -----------------------------------------------------------------------------
// Token Contract details
// -----------------------------------------------------------------------------
function printTokenContractStaticDetails() {
  if (tokenContractAddress != null && tokenContractAbi != null) {
    var contract = eth.contract(tokenContractAbi).at(tokenContractAddress);
    console.log("RESULT: token.symbol=" + contract.symbol());
    console.log("RESULT: token.name=" + contract.name());
    console.log("RESULT: token.decimals=" + contract.decimals());
    var startDate = contract.START_DATE();
    console.log("RESULT: token.START_DATE=" + startDate + " " + new Date(startDate * 1000).toUTCString()  + 
        " / " + new Date(startDate * 1000).toGMTString());
    var endDate = contract.END_DATE();
    console.log("RESULT: token.END_DATE=" + endDate + " " + new Date(endDate * 1000).toUTCString() + 
        " / " + new Date(endDate * 1000).toGMTString());
  }
}

var dynamicDetailsFromBlock = 0;
function printTokenContractDynamicDetails() {
  if (tokenContractAddress != null && tokenContractAbi != null && lockedTokenContractAbi != null) {
    var contract = eth.contract(tokenContractAbi).at(tokenContractAddress);
    var lockedTokenContract = eth.contract(lockedTokenContractAbi).at(contract.lockedTokens());
    var decimals = contract.decimals();
    console.log("RESULT: token.finalised=" + contract.finalised());
    console.log("RESULT: token.tokensPerKEther=" + contract.tokensPerKEther());
    console.log("RESULT: token.totalSupply=" + contract.totalSupply().shift(-decimals));
    console.log("RESULT: lockedToken.totalSupplyLocked1Y=" + lockedTokenContract.totalSupplyLocked1Y().shift(-decimals));
    console.log("RESULT: lockedToken.totalSupplyLocked2Y=" + lockedTokenContract.totalSupplyLocked2Y().shift(-decimals));
    console.log("RESULT: lockedToken.totalSupplyLocked=" + lockedTokenContract.totalSupplyLocked().shift(-decimals));
    console.log("RESULT: token.owner=" + contract.owner());
    console.log("RESULT: token.newOwner=" + contract.newOwner());

    var latestBlock = eth.blockNumber;
    var i;

    var ownershipTransferredEvent = contract.OwnershipTransferred({}, { fromBlock: dynamicDetailsFromBlock, toBlock: latestBlock });
    i = 0;
    ownershipTransferredEvent.watch(function (error, result) {
      console.log("RESULT: OwnershipTransferred Event " + i++ + ": from=" + result.args._from + " to=" + result.args._to + " " +
        result.blockNumber);
    });
    ownershipTransferredEvent.stopWatching();

    var tokensPerKEtherUpdatedEvent = contract.TokensPerKEtherUpdated({}, { fromBlock: dynamicDetailsFromBlock, toBlock: latestBlock });
    i = 0;
    tokensPerKEtherUpdatedEvent.watch(function (error, result) {
      console.log("RESULT: TokensPerKEtherUpdated Event " + i++ + ": tokensPerKEther=" + result.args.tokensPerKEther + " block=" + result.blockNumber);
    });
    tokensPerKEtherUpdatedEvent.stopWatching();

    var walletUpdatedEvent = contract.WalletUpdated({}, { fromBlock: dynamicDetailsFromBlock, toBlock: latestBlock });
    i = 0;
    walletUpdatedEvent.watch(function (error, result) {
      console.log("RESULT: WalletUpdated Event " + i++ + ": from=" + result.args.newWallet + " block=" + result.blockNumber);
    });
    walletUpdatedEvent.stopWatching();

    var precommitmentAddedEvent = contract.PrecommitmentAdded({}, { fromBlock: dynamicDetailsFromBlock, toBlock: latestBlock });
    i = 0;
    precommitmentAddedEvent.watch(function (error, result) {
      console.log("RESULT: PrecommitmentAdded Event " + i++ + ": participant=" + result.args.participant + 
        " balance=" + result.args.balance.shift(-decimals) + 
        " block=" + result.blockNumber);
    });
    precommitmentAddedEvent.stopWatching();

    var tokensBoughtEvent = contract.TokensBought({}, { fromBlock: dynamicDetailsFromBlock, toBlock: latestBlock });
    i = 0;
    tokensBoughtEvent.watch(function (error, result) {
      console.log("RESULT: TokensBought Event " + i++ + ": buyer=" + result.args.buyer + 
        " ethers=" + web3.fromWei(result.args.ethers, "ether") +
        " newEtherBalance=" + web3.fromWei(result.args.newEtherBalance, "ether") + 
        " tokens=" + result.args.tokens.shift(-decimals) + 
        " newTotalSupply=" + result.args.newTotalSupply.shift(-decimals) + 
        " tokensPerKEther=" + result.args.tokensPerKEther + 
        " block=" + result.blockNumber);
    });
    tokensBoughtEvent.stopWatching();

    var kycVerifiedEvent = contract.KycVerified({}, { fromBlock: dynamicDetailsFromBlock, toBlock: latestBlock });
    i = 0;
    kycVerifiedEvent.watch(function (error, result) {
      console.log("RESULT: KycVerified Event " + i++ + ": participant=" + result.args.participant + " block=" + result.blockNumber);
    });
    kycVerifiedEvent.stopWatching();

    var approvalEvent = contract.Approval({}, { fromBlock: dynamicDetailsFromBlock, toBlock: latestBlock });
    i = 0;
    approvalEvent.watch(function (error, result) {
      console.log("RESULT: Approval Event " + i++ + ": owner=" + result.args._owner + " spender=" + result.args._spender + " " +
        result.args._value.shift(-decimals) + " block=" + result.blockNumber);
    });
    approvalEvent.stopWatching();

    var transferEvent = contract.Transfer({}, { fromBlock: dynamicDetailsFromBlock, toBlock: latestBlock });
    i = 0;
    transferEvent.watch(function (error, result) {
      console.log("RESULT: Transfer Event " + i++ + ": from=" + result.args.from + " to=" + result.args.to +
        " value=" + result.args.value.shift(-decimals) + " block=" + result.blockNumber);
    });
    transferEvent.stopWatching();
    dynamicDetailsFromBlock = latestBlock + 1;
  }
}
