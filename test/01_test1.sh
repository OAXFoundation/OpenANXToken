#!/bin/bash
# ----------------------------------------------------------------------------------------------
# Testing the smart contract
#
# Enjoy. (c) BokkyPooBah / Bok Consulting Pty Ltd 2017. The MIT Licence.
# ----------------------------------------------------------------------------------------------

MODE=${1:-test}

GETHATTACHPOINT=`grep ^IPCFILE= settings.txt | sed "s/^.*=//"`
PASSWORD=`grep ^PASSWORD= settings.txt | sed "s/^.*=//"`
ERC20INTERFACESOL=`grep ^ERC20INTERFACESOL= settings.txt | sed "s/^.*=//"`
ERC20INTERFACETEMPSOL=`grep ^ERC20INTERFACETEMPSOL= settings.txt | sed "s/^.*=//"`
OWNEDSOL=`grep ^OWNEDSOL= settings.txt | sed "s/^.*=//"`
OWNEDTEMPSOL=`grep ^OWNEDTEMPSOL= settings.txt | sed "s/^.*=//"`
SAFEMATHSOL=`grep ^SAFEMATHSOL= settings.txt | sed "s/^.*=//"`
SAFEMATHTEMPSOL=`grep ^SAFEMATHTEMPSOL= settings.txt | sed "s/^.*=//"`
LOCKEDTOKENSSOL=`grep ^LOCKEDTOKENSSOL= settings.txt | sed "s/^.*=//"`
LOCKEDTOKENSTEMPSOL=`grep ^LOCKEDTOKENSTEMPSOL= settings.txt | sed "s/^.*=//"`
LOCKEDTOKENSJS=`grep ^LOCKEDTOKENSJS= settings.txt | sed "s/^.*=//"`
KYCSOL=`grep ^KYCSOL= settings.txt | sed "s/^.*=//"`
KYCJS=`grep ^KYCJS= settings.txt | sed "s/^.*=//"`
TOKENSOL=`grep ^TOKENSOL= settings.txt | sed "s/^.*=//"`
TOKENTEMPSOL=`grep ^TOKENTEMPSOL= settings.txt | sed "s/^.*=//"`
TOKENJS=`grep ^TOKENJS= settings.txt | sed "s/^.*=//"`
DEPLOYMENTDATA=`grep ^DEPLOYMENTDATA= settings.txt | sed "s/^.*=//"`

INCLUDEJS=`grep ^INCLUDEJS= settings.txt | sed "s/^.*=//"`
TEST1OUTPUT=`grep ^TEST1OUTPUT= settings.txt | sed "s/^.*=//"`
TEST1RESULTS=`grep ^TEST1RESULTS= settings.txt | sed "s/^.*=//"`

CURRENTTIME=`date +%s`
CURRENTTIMES=`date -r $CURRENTTIME -u`

if [ "$MODE" == "dev" ]; then
  # Start time now
  STARTTIME=`echo "$CURRENTTIME" | bc`
else
  # Start time 1 minute in the future
  STARTTIME=`echo "$CURRENTTIME+60" | bc`
fi
STARTTIME_S=`date -r $STARTTIME -u`
ENDTIME=`echo "$CURRENTTIME+60*5" | bc`
ENDTIME_S=`date -r $ENDTIME -u`

printf "MODE                  = '$MODE'\n"
printf "GETHATTACHPOINT       = '$GETHATTACHPOINT'\n"
printf "PASSWORD              = '$PASSWORD'\n"
printf "ERC20INTERFACESOL     = '$ERC20INTERFACESOL'\n"
printf "ERC20INTERFACETEMPSOL = '$ERC20INTERFACETEMPSOL'\n"
printf "OWNEDSOL              = '$OWNEDSOL'\n"
printf "OWNEDTEMPSOL          = '$OWNEDTEMPSOL'\n"
printf "SAFEMATHSOL           = '$SAFEMATHSOL'\n"
printf "SAFEMATHTEMPSOL       = '$SAFEMATHTEMPSOL'\n"
printf "LOCKEDTOKENSSOL       = '$LOCKEDTOKENSSOL'\n"
printf "LOCKEDTOKENSTEMPSOL   = '$LOCKEDTOKENSTEMPSOL'\n"
printf "LOCKEDTOKENSJS        = '$LOCKEDTOKENSJS'\n"
printf "TOKENSOL              = '$TOKENSOL'\n"
printf "TOKENTEMPSOL          = '$TOKENTEMPSOL'\n"
printf "KYCSOL                = '$KYCSOL'\n"
printf "KYCJS                 = '$KYCJS'\n"
printf "TOKENSOL              = '$TOKENSOL'\n"
printf "TOKENTEMPSOL          = '$TOKENTEMPSOL'\n"
printf "TOKENJS               = '$TOKENJS'\n"
printf "DEPLOYMENTDATA        = '$DEPLOYMENTDATA'\n"
printf "INCLUDEJS             = '$INCLUDEJS'\n"
printf "TEST1OUTPUT           = '$TEST1OUTPUT'\n"
printf "TEST1RESULTS          = '$TEST1RESULTS'\n"
printf "CURRENTTIME           = '$CURRENTTIME' '$CURRENTTIMES'\n"
printf "STARTTIME             = '$STARTTIME' '$STARTTIME_S'\n"
printf "ENDTIME               = '$ENDTIME' '$ENDTIME_S'\n"

# Make copy of SOL file and modify start and end times ---
`cp $ERC20INTERFACESOL $ERC20INTERFACETEMPSOL`
`cp $OWNEDSOL $OWNEDTEMPSOL`
`cp $TOKENSOL $TOKENTEMPSOL`
`cp $SAFEMATHSOL $SAFEMATHTEMPSOL`
`cp $LOCKEDTOKENSSOL $LOCKEDTOKENSTEMPSOL`

# --- Modify dates ---
# PRESALE_START_DATE = +1m
`perl -pi -e "s/START_DATE = 1498089600;/START_DATE = $STARTTIME; \/\/ $STARTTIME_S/" $TOKENTEMPSOL`
`perl -pi -e "s/END_DATE = 1500595200;/END_DATE = $ENDTIME; \/\/ $ENDTIME_S/" $TOKENTEMPSOL`

# --- Un-internal safeMaths ---
`perl -pi -e "s/internal/constant/" $TOKENTEMPSOL`

DIFFS=`diff $TOKENSOL $TOKENTEMPSOL`
echo "--- Differences ---"
echo "$DIFFS"

echo "var kycOutput=`solc --optimize --combined-json abi,bin,interface $KYCSOL`;" > $KYCJS
echo "var tokenOutput=`solc --optimize --combined-json abi,bin,interface $TOKENTEMPSOL`;" > $TOKENJS
echo "var lockedTokensOutput=`solc --optimize --combined-json abi,bin,interface $LOCKEDTOKENSTEMPSOL`;" > $LOCKEDTOKENSJS

geth --verbosity 3 attach $GETHATTACHPOINT << EOF | tee $TEST1OUTPUT
loadScript("$KYCJS");
loadScript("$TOKENJS");
loadScript("$LOCKEDTOKENSJS");
loadScript("functions.js");

var kycAbi = JSON.parse(kycOutput.contracts["$KYCSOL:OpenANXTokenKYC"].abi);
var kycBin = "0x" + kycOutput.contracts["$KYCSOL:OpenANXTokenKYC"].bin;
var tokenAbi = JSON.parse(tokenOutput.contracts["$TOKENTEMPSOL:OpenANXToken"].abi);
var tokenBin = "0x" + tokenOutput.contracts["$TOKENTEMPSOL:OpenANXToken"].bin;
var lockedTokensAbi = JSON.parse(tokenOutput.contracts["$LOCKEDTOKENSTEMPSOL:LockedTokens"].abi);
// var lockedTokensAbi = JSON.parse(lockedTokensOutput.contracts["$LOCKEDTOKENSTEMPSOL:LockedTokens"].abi);
// var lockedTokensBin = "0x" + lockedTokensOutput.contracts["$LOCKEDTOKENSTEMPSOL:LockedTokens"].bin;

console.log("DATA: kycAbi=" + JSON.stringify(kycAbi));
console.log("DATA: tokenABI=" + JSON.stringify(tokenAbi));
console.log("DATA: lockedTokensAbi=" + JSON.stringify(lockedTokensAbi));

unlockAccounts("$PASSWORD");
printBalances();
console.log("RESULT: ");

var skipKycContract = "$MODE" == "dev" ? true : false;
var skipSafeMath = "$MODE" == "dev" ? true : false;

if (!skipKycContract) {
  // -----------------------------------------------------------------------------
  var testMessage = "Test 1.1 Deploy KYC Contract";
  console.log("RESULT: " + testMessage);
  var kycContract = web3.eth.contract(kycAbi);
  var kycTx = null;
  var kyc = kycContract.new({from: tokenOwnerAccount, data: kycBin, gas: 4000000},
    function(e, contract) {
      if (!e) {
        if (!contract.address) {
          kycTx = contract.transactionHash;
        } else {
          kycAddress = contract.address;
          addAccount(kycAddress, "KYC");
          addKYCContractAddressAndAbi(kycAddress, kycAbi);
          console.log("DATA: kycAddress=" + kycAddress);
          printTxData("kycAddress=" + kycAddress, kycTx);
        }
      }
    }
  );
  while (txpool.status.pending > 0) {
  }
  printBalances();
  failIfGasEqualsGasUsed(kycTx, testMessage);
  printKYCContractDetails();
  console.log("RESULT: ");
}


if (!skipKycContract) {
  // -----------------------------------------------------------------------------
  var testMessage = "Test 1.2 KYC account2 (a22a) and account3 (a33a)";
  console.log("RESULT: " + testMessage);
  var account2 = eth.accounts[2];
  var account3 = eth.accounts[3];
  var tx1_2_1 = kyc.kyc(account2, 1, { from: tokenOwnerAccount, gas: 90000 });
  var tx1_2_2 = kyc.kyc(account3, 1, { from: tokenOwnerAccount, gas: 90000 });
  while (txpool.status.pending > 0) {
  }
  printTxData("tx1_2_1", tx1_2_1);
  printTxData("tx1_2_2", tx1_2_2);
  printBalances();
  failIfGasEqualsGasUsed(tx1_2_1, testMessage + " - account2 (a22a)");
  failIfGasEqualsGasUsed(tx1_2_2, testMessage + " - account3 (a33a)");
  printKYCContractDetails();
  console.log("RESULT: ");
}


// -----------------------------------------------------------------------------
var testMessage = "Test 1.3 Deploy Token Contract";
console.log("RESULT: " + testMessage);
var tokenContract = web3.eth.contract(tokenAbi);
console.log(JSON.stringify(tokenContract));
var tokenTx = null;
var tokenAddress = null;
console.log("DEBUG: Deploy Token 1a");
var token = tokenContract.new({from: tokenOwnerAccount, data: tokenBin, gas: 6000000},
  function(e, contract) {
    if (!e) {
      if (!contract.address) {
        console.log("DEBUG: Deploy Token 2a");
        tokenTx = contract.transactionHash;
        console.log("DEBUG: Deploy Token 2b - tokenTx=" + tokenTx);
      } else {
        console.log("DEBUG: Deploy Token 3a");
        tokenAddress = contract.address;
        console.log("DEBUG: Deploy Token 3b");
        addAccount(tokenAddress, "TOKEN");
        console.log("DEBUG: Deploy Token 3c");
        addTokenContractAddressAndAbi(tokenAddress, tokenAbi, lockedTokensAbi);
        console.log("DEBUG: Deploy Token 3d");
        console.log("DATA: tokenAddress=" + tokenAddress);
        printTxData("tokenAddress=" + tokenAddress, tokenTx);
        console.log("DEBUG: Deploy Token 3e");
      }
    }
  }
);
while (txpool.status.pending > 0) {
}
printTxData("tokenAddress=" + tokenAddress, tokenTx);
console.log("DEBUG: Deploy Token 1b");
printBalances();
failIfGasEqualsGasUsed(tokenTx, testMessage);
printTokenContractStaticDetails();
printTokenContractDynamicDetails();
console.log("RESULT: ");
console.log(JSON.stringify(token));


// -----------------------------------------------------------------------------
var testMessage = "Test 1.4 Buy tokens. 123.456789012345678901 ETH = 12345.678901234567890100 OAX from account2";
console.log("RESULT: " + testMessage);
var tx1_4_1 = eth.sendTransaction({from: account2, to: tokenAddress, gas: 400000, value: web3.toWei("123.456789012345678901", "ether")});
while (txpool.status.pending > 0) {
}
printBalances();
failIfGasEqualsGasUsed(tx1_4_1, testMessage);
printTokenContractDynamicDetails();
console.log("RESULT: ");


if (!skipSafeMath) {
  // -----------------------------------------------------------------------------
  // Notes: 
  // = To simulate failure, comment out the throw lines in safeAdd() and safeSub()
  //
  var testMessage = "Test 2.0 Safe Maths";
  console.log("RESULT: " + testMessage);
  console.log(JSON.stringify(token));
  var result = token.safeAdd("1", "2");
  if (result == 3) {
    console.log("RESULT: PASS safeAdd(1, 2) = 3");
  } else {
    console.log("RESULT: FAIL safeAdd(1, 2) <> 3");
  }

  var minusOneInt = "0xffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff";
  result = token.safeAdd(minusOneInt, "124");
  if (result == 0) {
    console.log("RESULT: PASS safeAdd(" + minusOneInt + ", 124) = 0. Result=" + result);
  } else {
    console.log("RESULT: FAIL safeAdd(" + minusOneInt + ", 124) = 123. Result=" + result);
  }

  result = token.safeAdd("124", minusOneInt);
  if (result == 0) {
    console.log("RESULT: PASS safeAdd(124, " + minusOneInt + ") = 0. Result=" + result);
  } else {
    console.log("RESULT: FAIL safeAdd(124, " + minusOneInt + ") = 123. Result=" + result);
  }

    result = token.safeSub("124", 1);
  if (result == 123) {
    console.log("RESULT: PASS safeSub(124, 1) = 123. Result=" + result);
  } else {
    console.log("RESULT: FAIL safeSub(124, 1) <> 123. Result=" + result);
  }

    result = token.safeSub("122", minusOneInt);
  if (result == 0) {
    console.log("RESULT: PASS safeSub(122, " + minusOneInt + ") = 0. Result=" + result);
  } else {
    console.log("RESULT: FAIL safeSub(122, " + minusOneInt + ") = 123. Result=" + result);
  }

}



exit;






// -----------------------------------------------------------------------------
var testMessage = "Test 1.2 Initial Transfer Of Tokens";
console.log("RESULT: " + testMessage);
var tx12_1 = token.transfer(account2, "100000000000", {from: tokenOwnerAccount, gas: 100000});
var tx12_2 = token.transfer(account3, "100000000000", {from: tokenOwnerAccount, gas: 100000});
var tx12_3 = token.transfer(account4, "100000000000", {from: tokenOwnerAccount, gas: 100000});
while (txpool.status.pending > 0) {
}
printTxData("tx12_1", tx12_1);
printTxData("tx12_2", tx12_2);
printTxData("tx12_3", tx12_3);
printBalances();
failIfGasEqualsGasUsed(tx12_1, testMessage + " -> Account #2");
failIfGasEqualsGasUsed(tx12_2, testMessage + " -> Account #3");
failIfGasEqualsGasUsed(tx12_3, testMessage + " -> Account #4");
printContractDynamicDetails();
console.log("RESULT: ");


// -----------------------------------------------------------------------------
var testMessage = "Test 1.3 Execute Invalid Functions - sending ethers to token contract; sending more tokens than owned";
console.log("RESULT: " + testMessage);
var tx13_1 = eth.sendTransaction({from: tokenOwnerAccount, to: tokenAddress, gas: 400000, value: web3.toWei("100", "ether")});
var tx13_2 = token.transfer(account2, "10000000000000000000", {from: tokenOwnerAccount, gas: 100000});
while (txpool.status.pending > 0) {
}
printTxData("tx13_1", tx13_1);
printTxData("tx13_2", tx13_2);
printBalances();
passIfGasEqualsGasUsed(tx13_1, testMessage + " - CHECK no ethers moved");
failIfGasEqualsGasUsed(tx13_2, testMessage + " - CHECK no tokens moved");
printContractDynamicDetails();
console.log("RESULT: ");


// -----------------------------------------------------------------------------
var testMessage = "Test 1.4 Change Ownership";
console.log("RESULT: " + testMessage);
var tx14_1 = token.transferOwnership(minerAccount, {from: tokenOwnerAccount, gas: 100000});
while (txpool.status.pending > 0) {
}
var tx14_2 = token.acceptOwnership({from: minerAccount, gas: 100000});
while (txpool.status.pending > 0) {
}
printTxData("tx14_1", tx14_1);
printTxData("tx14_2", tx14_2);
printBalances();
failIfGasEqualsGasUsed(tx14_1, testMessage + " - Change owner");
failIfGasEqualsGasUsed(tx14_2, testMessage + " - Accept ownership");
printContractDynamicDetails();
console.log("RESULT: ");


// -----------------------------------------------------------------------------
var testMessage = "Test 1.5 approve() And transferFrom()";
console.log("RESULT: " + testMessage);
var tx15_1 = token.transferOwnership(minerAccount, {from: tokenOwnerAccount, gas: 100000});
while (txpool.status.pending > 0) {
}
var tx14_2 = token.acceptOwnership({from: minerAccount, gas: 100000});
while (txpool.status.pending > 0) {
}
printTxData("tx14_1", tx14_1);
printTxData("tx14_2", tx14_2);
printBalances();
failIfGasEqualsGasUsed(tx14_1, testMessage + " - Change owner");
failIfGasEqualsGasUsed(tx14_2, testMessage + " - Accept ownership");
printContractDynamicDetails();
console.log("RESULT: ");


exit;


var startBlock = eth.blockNumber;
var endBlock = eth.blockNumber;

// Get TokenTrader address
// var tradeListingEvent = tokenTraderFactory.TradeListing({}, { fromBlock: startBlock, toBlock: endBlock });
var tradeListingEvent = tokenTraderFactory.TradeListing({}, { fromBlock: 0, toBlock: "latest" });
var i = 0;
var tokenTrader0Address = null;
var tokenTrader1Address = null;
var tokenTrader2Address = null;
var tokenTrader8Address = null;
var tokenTrader18Address = null;
tradeListingEvent.watch(function (error, result) {
  var asset = result.args.asset;
  if (asset == token0Address) {
    tokenTrader0Address = result.args.tokenTraderAddress;
    addAccount(tokenTrader0Address, "TokenTrader0");
    console.log("DATA: tokenTrader0Address=" + tokenTrader0Address);
  } else if (asset == token1Address) {
    tokenTrader1Address = result.args.tokenTraderAddress;
    addAccount(tokenTrader1Address, "TokenTrader1");
    console.log("DATA: tokenTrader1Address=" + tokenTrader1Address);
  } else if (asset == token2Address) {
    tokenTrader2Address = result.args.tokenTraderAddress;
    addAccount(tokenTrader2Address, "TokenTrader2");
    console.log("DATA: tokenTrader2Address=" + tokenTrader2Address);
  } else if (asset == token8Address) {
    tokenTrader8Address = result.args.tokenTraderAddress;
    addAccount(tokenTrader8Address, "TokenTrader8");
    console.log("DATA: tokenTrader8Address=" + tokenTrader8Address);
  } else if (asset == token18Address) {
    tokenTrader18Address = result.args.tokenTraderAddress;
    addAccount(tokenTrader18Address, "TokenTrader18");
    console.log("DATA: tokenTrader18Address=" + tokenTrader18Address);
  }
  console.log(i++ + ": " + JSON.stringify(result));
});
tradeListingEvent.stopWatching();
printBalances();


// -----------------------------------------------------------------------------
var testMessage = "Setup 1.4 Transfer tokens to TokenTrader";
console.log("RESULT: " + testMessage);
var tx14_0 = token0.transfer(tokenTrader0Address, "100", {from: maker1Account, gas: 100000});
var tx14_1 = token1.transfer(tokenTrader1Address, "1000", {from: maker1Account, gas: 100000});
var tx14_2 = token2.transfer(tokenTrader2Address, "10000", {from: maker1Account, gas: 100000});
var tx14_8 = token8.transfer(tokenTrader8Address, "10000000000", {from: maker1Account, gas: 100000});
var tx14_18 = token18.transfer(tokenTrader18Address, "100000000000000000000", {from: maker1Account, gas: 100000});
while (txpool.status.pending > 0) {
}
printTxData("tx14_0", tx14_0);
printTxData("tx14_1", tx14_1);
printTxData("tx14_2", tx14_2);
printTxData("tx14_8", tx14_8);
printTxData("tx14_18", tx14_18);
printBalances();
failIfGasEqualsGasUsed(tx14_0, testMessage + " Token0");
failIfGasEqualsGasUsed(tx14_1, testMessage + " Token1");
failIfGasEqualsGasUsed(tx14_2, testMessage + " Token2");
failIfGasEqualsGasUsed(tx14_8, testMessage + " Token8");
failIfGasEqualsGasUsed(tx14_18, testMessage + " Token18");
console.log("RESULT: ");


// -----------------------------------------------------------------------------
var testMessage = "Test 1.5 Buy Tokens from TokenTrader";
console.log("RESULT: " + testMessage);
var tx15_0 = eth.sendTransaction({from: taker1Account, to: tokenTrader0Address, gas: 400000, value: web3.toWei("100", "ether")});
var tx15_1 = eth.sendTransaction({from: taker1Account, to: tokenTrader1Address, gas: 400000, value: web3.toWei("100", "ether")});
var tx15_2 = eth.sendTransaction({from: taker1Account, to: tokenTrader2Address, gas: 400000, value: web3.toWei("100", "ether")});
var tx15_8 = eth.sendTransaction({from: taker1Account, to: tokenTrader8Address, gas: 400000, value: web3.toWei("100", "ether")});
var tx15_18 = eth.sendTransaction({from: taker1Account, to: tokenTrader18Address, gas: 400000, value: web3.toWei("100", "ether")});
while (txpool.status.pending > 0) {
}
printTxData("tx15_0", tx15_0);
printTxData("tx15_1", tx15_1);
printTxData("tx15_2", tx15_2);
printTxData("tx15_8", tx15_8);
printTxData("tx15_18", tx15_18);
printBalances();
failIfGasEqualsGasUsed(tx15_0, testMessage + " Token0");
failIfGasEqualsGasUsed(tx15_1, testMessage + " Token1");
failIfGasEqualsGasUsed(tx15_2, testMessage + " Token2");
failIfGasEqualsGasUsed(tx15_8, testMessage + " Token8");
failIfGasEqualsGasUsed(tx15_18, testMessage + " Token18");
console.log("RESULT: ");

exit;

printContractStaticDetails();
printContractDynamicDetails();
failIfGasEqualsGasUsedOrContractAddressNull(depositContractFactoryAddress, depositContractFactoryTx, testMessage);
console.log("RESULT: ");

// Load source code
loadScript("$INCLUDEJS");
// console.log("depositContractFactorySource=" + depositContractFactorySource);

var depositContractFactoryCompiled = web3.eth.compile.solidity(depositContractFactorySource);
console.log("----------v depositContractFactoryCompiled v----------");
depositContractFactoryCompiled;
console.log("----------^ depositContractFactoryCompiled ^----------");
console.log("DATA: tokenABI=" + JSON.stringify(depositContractFactoryCompiled["<stdin>:CustomerDepositFactory"].info.abiDefinition));

// -----------------------------------------------------------------------------
var testMessage = "Test 1.1 Deploy Deposit Contract";
console.log("RESULT: " + testMessage);
var depositContractFactoryTx = null;
var depositContractFactoryContract = web3.eth.contract(depositContractFactoryCompiled["<stdin>:CustomerDepositFactory"].info.abiDefinition);
var depositContractFactory = depositContractFactoryContract.new({from: customerDepositFactoryOwnerAccount,
  data: depositContractFactoryCompiled["<stdin>:CustomerDepositFactory"].code, gas: 4000000},
  function(e, contract) {
    if (!e) {
      if (!contract.address) {
        depositContractFactoryTx = contract.transactionHash;
        console.log("depositContractFactoryTx=" + depositContractFactoryTx);
      } else {
        depositContractFactoryAddress = contract.address;
        addAccount(depositContractFactoryAddress, "Customer Deposit Factory");
        addContractAddressAndAbi(depositContractFactoryAddress, depositContractFactoryCompiled["<stdin>:CustomerDepositFactory"].info.abiDefinition);
        printTxData("depositContractFactoryAddress=" + depositContractFactoryAddress, depositContractFactoryTx);
      }
    }
  }
);
while (txpool.status.pending > 0) {
}
printBalances();
printContractStaticDetails();
printContractDynamicDetails();
failIfGasEqualsGasUsedOrContractAddressNull(depositContractFactoryAddress, depositContractFactoryTx, testMessage);
console.log("RESULT: ");


// -----------------------------------------------------------------------------
testMessage = "Test 1.2 Create 1 Deposit Contract";
console.log("RESULT: " + testMessage);
var tx12 = depositContractFactory.createDepositContracts(1, {from: customerDepositFactoryOwnerAccount, gas: 4500000});
while (txpool.status.pending > 0) {
}
printBalances();
printContractDynamicDetails();
printTxData("tx12", tx12);
failIfGasEqualsGasUsed(tx12, testMessage);
console.log("RESULT: Transaction input: " + eth.getTransaction(tx12).input);
console.log("RESULT: ");

// -----------------------------------------------------------------------------
testMessage = "Test 1.3 Contribute before contribution period is active - unsuccessful";
console.log("RESULT: " + testMessage);
var depositContract0 = depositContractFactory.depositContracts(0);
var tx13 = eth.sendTransaction({from: customer1Account, to: depositContract0, gas: 400000, value: web3.toWei(100, "ether")});
while (txpool.status.pending > 0) {
}
printBalances();
printTxData("tx13", tx13);
passIfGasEqualsGasUsed(tx13, testMessage);
console.log("RESULT: ");


// -----------------------------------------------------------------------------
testMessage = "Test 1.4 Create 10 Deposit Contracts";
console.log("RESULT: " + testMessage);
var tx14 = depositContractFactory.createDepositContracts(10, {from: customerDepositFactoryOwnerAccount, gas: 4500000});
while (txpool.status.pending > 0) {
}
printTxData("tx14", tx14);
printBalances();
printContractDynamicDetails();
failIfGasEqualsGasUsed(tx14, testMessage);
console.log("RESULT: Transaction input: " + eth.getTransaction(tx14).input);
console.log("RESULT: ");


// -----------------------------------------------------------------------------
testMessage = "Test 1.5 Create 20 Deposit Contracts";
console.log("RESULT: " + testMessage);
var tx15 = depositContractFactory.createDepositContracts(20, {from: customerDepositFactoryOwnerAccount, gas: 4500000});
while (txpool.status.pending > 0) {
}
printTxData("tx15", tx15);
printBalances();
printContractDynamicDetails();
failIfGasEqualsGasUsed(tx15, testMessage);
console.log("RESULT: Transaction input: " + eth.getTransaction(tx15).input);
console.log("RESULT: ");


// -----------------------------------------------------------------------------
testMessage = "Test 1.6 Customer1 Deposit 10.23456789 ETH";
console.log("RESULT: " + testMessage);

var depositDateFromTime = depositContractFactory.DEPOSIT_DATE_FROM();
var depositDateFromDate = new Date(depositDateFromTime * 1000);
console.log("RESULT: Waiting until deposit period is active at " + depositDateFromTime + " " + depositDateFromDate +
  " currentDate=" + new Date());
while ((new Date()).getTime() <= depositDateFromDate.getTime()) {
}
console.log("RESULT: Waited until deposit period is active at " + depositDateFromTime + " " + depositDateFromDate +
  " currentDate=" + new Date());

var depositContract0 = depositContractFactory.depositContracts(0);
var tx16 = eth.sendTransaction({from: customer1Account, to: depositContract0, gas: 400000, value: web3.toWei(10.23456789, "ether")});
while (txpool.status.pending > 0) {
}
printTxData("tx16", tx16);
printBalances();
printContractDynamicDetails();
failIfGasEqualsGasUsed(tx16, testMessage);
console.log("RESULT:   CHECK Test 1.6. Test Customer1 Deposit 10.23456789 ETH - split 0.051172839/0.051172839/10.13222221");
console.log("RESULT: ");


// -----------------------------------------------------------------------------
testMessage = "Test 1.7 Customer2 Deposit 1000 ETH";
console.log("RESULT: " + testMessage);
var depositContract1 = depositContractFactory.depositContracts(1);
var tx17 = eth.sendTransaction({from: customer2Account, to: depositContract1, gas: 400000, value: web3.toWei(1000, "ether")});
while (txpool.status.pending > 0) {
}
printTxData("tx17", tx17);
printBalances();
printContractDynamicDetails();
failIfGasEqualsGasUsed(tx17, testMessage);
console.log("RESULT:   CHECK Test 1.7. Test Customer2 Deposit 1000 ETH - split 5/5/990");
console.log("RESULT: ");


// -----------------------------------------------------------------------------
testMessage = "Test 1.8 Customer2 Deposit 100 ETH with too little gas - unsuccessful";
console.log("RESULT: " + testMessage);
var depositContract1 = depositContractFactory.depositContracts(1);
var tx18 = eth.sendTransaction({from: customer2Account, to: depositContract1, gas: 50000, value: web3.toWei(100, "ether")});
while (txpool.status.pending > 0) {
}
printTxData("tx18", tx18);
printBalances();
printContractDynamicDetails();
passIfGasEqualsGasUsed(tx18, testMessage);
console.log("RESULT:   CHECK Test 1.8. There should be no partial payments");
console.log("RESULT: ");


// -----------------------------------------------------------------------------
testMessage = "Test 1.9 Close funding";
console.log("RESULT: " + testMessage);
var tx19 = depositContractFactory.setFundingClosed(true, {from: customerDepositFactoryOwnerAccount, gas: 400000});
while (txpool.status.pending > 0) {
}
printTxData("tx19", tx19);
printBalances();
printContractDynamicDetails();
failIfGasEqualsGasUsed(tx19, testMessage);
console.log("RESULT: Transaction input: " + eth.getTransaction(tx19).input);
console.log("RESULT: ");


// -----------------------------------------------------------------------------
testMessage = "Test 1.10 Contribute when funding is closed - unsuccessful";
console.log("RESULT: " + testMessage);
var depositContract2 = depositContractFactory.depositContracts(2);
var tx110 = eth.sendTransaction({from: customer2Account, to: depositContract1, gas: 400000, value: web3.toWei(100, "ether")});
while (txpool.status.pending > 0) {
}
printTxData("tx110", tx110);
printBalances();
printContractDynamicDetails();
passIfGasEqualsGasUsed(tx110, testMessage);
console.log("RESULT:   CHECK 1. There should be no payments");
console.log("RESULT: ");


// -----------------------------------------------------------------------------
testMessage = "Test 1.11 Reopen funding";
console.log("RESULT: " + testMessage);
var tx111 = depositContractFactory.setFundingClosed(false, {from: customerDepositFactoryOwnerAccount, gas: 400000});
while (txpool.status.pending > 0) {
}
printTxData("tx111", tx111);
printBalances();
printContractDynamicDetails();
failIfGasEqualsGasUsed(tx111, testMessage);
console.log("RESULT: Transaction input: " + eth.getTransaction(tx111).input);
console.log("RESULT: ");


// -----------------------------------------------------------------------------
testMessage = "Test 1.12 Contribute when funding is re-opened";
console.log("RESULT: " + testMessage);
var depositContract3 = depositContractFactory.depositContracts(3);
var tx111 = eth.sendTransaction({from: customer2Account, to: depositContract1, gas: 400000, value: web3.toWei(100, "ether")});
while (txpool.status.pending > 0) {
}
printTxData("tx111", tx111);
printBalances();
printContractDynamicDetails();
failIfGasEqualsGasUsed(tx111, testMessage);
console.log("RESULT: ");


// -----------------------------------------------------------------------------
testMessage = "Test 2.0 Customer1 Deposit 100 ETH after end - unsuccessful";
console.log("RESULT: " + testMessage);

var depositDateToTime = depositContractFactory.DEPOSIT_DATE_TO();
var depositDateToDate = new Date(depositDateToTime * 1000);
console.log("RESULT: Waiting until deposit period is inactive at " + depositDateToTime + " " + depositDateToDate +
  " currentDate=" + new Date());
while ((new Date()).getTime() <= depositDateToDate.getTime()) {
}
console.log("RESULT: Waited until deposit period is inactive at " + depositDateToTime + " " + depositDateToDate +
  " currentDate=" + new Date());

var depositContract0 = depositContractFactory.depositContracts(0);
var tx20 = eth.sendTransaction({from: customer1Account, to: depositContract0, gas: 400000, value: web3.toWei(100, "ether")});
while (txpool.status.pending > 0) {
}
printTxData("tx20", tx20);
printBalances();
printContractDynamicDetails();
passIfGasEqualsGasUsed(tx20, testMessage);
console.log("RESULT: ");


// -----------------------------------------------------------------------------
testMessage = "Extract Events";
console.log("RESULT: " + testMessage);
var filter = web3.eth.filter({ address: [depositContractFactoryAddress], fromBlock: 0, toBlock: "latest" });
var i = 0;
filter.watch(function (error, result) {
  console.log("RESULT: Filter " + i++ + ": " + JSON.stringify(result));
});
filter.stopWatching();
console.log("RESULT: ");


EOF
grep "DATA: " $TEST1OUTPUT | sed "s/DATA: //" > $DEPLOYMENTDATA
cat $DEPLOYMENTDATA
grep "RESULT: " $TEST1OUTPUT | sed "s/RESULT: //" > $TEST1RESULTS
cat $TEST1RESULTS
