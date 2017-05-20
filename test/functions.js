var accounts = [];
var accountNames = {};

addAccount(eth.accounts[0], "Account #0 - Miner");
addAccount(eth.accounts[1], "Account #1 - Token Owner");
addAccount(eth.accounts[2], "Account #2");
addAccount(eth.accounts[3], "Account #3");
addAccount(eth.accounts[4], "Account #4");
addAccount(eth.accounts[5], "Account #5");
addAccount(eth.accounts[6], "Account #6");

var minerAccount = eth.accounts[0];
var tokenOwnerAccount = eth.accounts[1];
var account2 = eth.accounts[2];
var account3 = eth.accounts[3];
var account4 = eth.accounts[4];
var account5 = eth.accounts[5];
var account6 = eth.accounts[6];

var baseBlock = eth.blockNumber;
var tokenABIFragment=[{"constant":true,"inputs":[{"name":"_owner","type":"address"}],"name":"balanceOf","outputs":[{"name":"balance","type":"uint256"}],"payable":false,"type":"function"}];

var token = null;
var tokenAddress = null;

function unlockAccounts(password) {
  for (var i = 0; i < 7; i++) {
    personal.unlockAccount(eth.accounts[i], password, 100000);
  }
}

function addAccount(account, accountName) {
  accounts.push(account);
  accountNames[account] = accountName;
}

function printBalances() {
  if (token == null) {
    token = tokenAddress == null ? null : web3.eth.contract(tokenABIFragment).at(tokenAddress);
  }
  var i = 0;
  console.log("RESULT:  # Account                                             EtherBalanceChange                Token Name");
  accounts.forEach(function(e) {
    i++;
    var etherBalanceBaseBlock = eth.getBalance(e, baseBlock);
    var etherBalance = web3.fromWei(eth.getBalance(e).minus(etherBalanceBaseBlock), "ether");
    var tokenBalance = token == null ? new BigNumber(0) : token.balanceOf(e).div(1e8);
    console.log("RESULT: " + pad2(i) + " " + e  + " " + pad(etherBalance) + " " + padToken(tokenBalance, 8) + " " + accountNames[e]);
  });
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

function printTxData(name, txId) {
  var tx = eth.getTransaction(txId);
  var txReceipt = eth.getTransactionReceipt(txId);
  console.log("RESULT: " + name + " gas=" + tx.gas + " gasUsed=" + txReceipt.gasUsed + " cost=" + tx.gasPrice.mul(txReceipt.gasUsed).div(1e18) +
    " block=" + txReceipt.blockNumber + " txId=" + txId);
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

var contractAddress = null;
var contractAbi = null;

function addContractAddressAndAbi(address, abi) {
  contractAddress = address;
  contractAbi = abi;
}

function printContractStaticDetails() {
  var contract = eth.contract(contractAbi).at(contractAddress);
  console.log("RESULT: token.symbol=" + contract.symbol());
  console.log("RESULT: token.name=" + contract.name());
  console.log("RESULT: token.decimals=" + contract.decimals());
  console.log("RESULT: token.totalSupply=" + contract.totalSupply().div(1e8));
}

var dynamicDetailsFromBlock = 0;
function printContractDynamicDetails() {
  var contract = eth.contract(contractAbi).at(contractAddress);
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

  var approvalEvent = contract.Approval({}, { fromBlock: dynamicDetailsFromBlock, toBlock: latestBlock });
  i = 0;
  approvalEvent.watch(function (error, result) {
    console.log("RESULT: Approval Event " + i++ + ": owner=" + result.args._owner + " spender=" + result.args._spender + " " + 
      result.args._value.div(1e8) + " block=" + result.blockNumber);
  });
  approvalEvent.stopWatching();
  
  var transferEvent = contract.Transfer({}, { fromBlock: dynamicDetailsFromBlock, toBlock: latestBlock });
  i = 0;
  transferEvent.watch(function (error, result) {
    console.log("RESULT: Transfer Event " + i++ + ": from=" + result.args.from + " to=" + result.args.to +
      " value=" + result.args.value.div(1e8) + " block=" + result.blockNumber);
  });
  transferEvent.stopWatching();
  dynamicDetailsFromBlock = latestBlock + 1;
}
