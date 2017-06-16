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
TOKENCONFIGSOL=`grep ^TOKENCONFIGSOL= settings.txt | sed "s/^.*=//"`
TOKENCONFIGTEMPSOL=`grep ^TOKENCONFIGTEMPSOL= settings.txt | sed "s/^.*=//"`
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
printf "TOKENCONFIGSOL        = '$TOKENCONFIGSOL'\n"
printf "TOKENCONFIGTEMPSOL    = '$TOKENCONFIGTEMPSOL'\n"
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
`cp $SAFEMATHSOL $SAFEMATHTEMPSOL`
`cp $LOCKEDTOKENSSOL $LOCKEDTOKENSTEMPSOL`
`cp $TOKENCONFIGSOL $TOKENCONFIGTEMPSOL`
`cp $TOKENSOL $TOKENTEMPSOL`

# --- Modify dates ---
# PRESALE_START_DATE = +1m
`perl -pi -e "s/START_DATE = 1498136400;/START_DATE = $STARTTIME; \/\/ $STARTTIME_S/" $TOKENCONFIGTEMPSOL`
`perl -pi -e "s/END_DATE = 1500728400;/END_DATE = $ENDTIME; \/\/ $ENDTIME_S/" $TOKENCONFIGTEMPSOL`

# --- Un-internal safeMaths ---
#`perl -pi -e "s/internal/constant/" $TOKENTEMPSOL`

DIFFS=`diff $TOKENCONFIGSOL $TOKENCONFIGTEMPSOL`
echo "--- Differences ---"
echo "$DIFFS"

echo "var tokenOutput=`solc --optimize --combined-json abi,bin,interface $TOKENTEMPSOL`;" > $TOKENJS

geth --verbosity 3 attach $GETHATTACHPOINT << EOF | tee $TEST1OUTPUT
loadScript("$TOKENJS");
loadScript("functions.js");

var tokenAbi = JSON.parse(tokenOutput.contracts["$TOKENTEMPSOL:OpenANXToken"].abi);
var tokenBin = "0x" + tokenOutput.contracts["$TOKENTEMPSOL:OpenANXToken"].bin;
var lockedTokensAbi = JSON.parse(tokenOutput.contracts["$LOCKEDTOKENSTEMPSOL:LockedTokens"].abi);

console.log("DATA: tokenABI=" + JSON.stringify(tokenAbi));
console.log("DATA: lockedTokensAbi=" + JSON.stringify(lockedTokensAbi));

unlockAccounts("$PASSWORD");
printBalances();
console.log("RESULT: ");

var skipKycContract = "$MODE" == "dev" ? true : false;
var skipSafeMath = "$MODE" == "dev" ? true : false;

// -----------------------------------------------------------------------------
var testMessage = "Test 1.1 Deploy Token Contract";
console.log("RESULT: " + testMessage);
var tokenContract = web3.eth.contract(tokenAbi);
console.log(JSON.stringify(tokenContract));
var tokenTx = null;
var tokenAddress = null;
var token = tokenContract.new(tokenOwnerAccount, {from: tokenOwnerAccount, data: tokenBin, gas: 6000000},
  function(e, contract) {
    if (!e) {
      if (!contract.address) {
        tokenTx = contract.transactionHash;
      } else {
        tokenAddress = contract.address;
        addAccount(tokenAddress, token.symbol() + " '" + token.name() + "' *");
        addAccount(token.lockedTokens(), "Locked Tokens");
        addTokenContractAddressAndAbi(tokenAddress, tokenAbi, lockedTokensAbi);
        console.log("DATA: tokenAddress=" + tokenAddress);
        printTxData("tokenAddress=" + tokenAddress, tokenTx);
      }
    }
  }
);
while (txpool.status.pending > 0) {
}
printTxData("tokenAddress=" + tokenAddress, tokenTx);
printBalances();
failIfGasEqualsGasUsed(tokenTx, testMessage);
printTokenContractStaticDetails();
printTokenContractDynamicDetails();
console.log("RESULT: ");
console.log(JSON.stringify(token));


// -----------------------------------------------------------------------------
var testMessage = "Test 1.2 Precommitments, TokensPerKEther, Wallet";
console.log("RESULT: " + testMessage);
var tx1_2_1 = token.addPrecommitment(precommitmentsAccount, "10000000000000000000000000", {from: tokenOwnerAccount, gas: 4000000});
var tx1_2_2 = token.setTokensPerKEther("1000000", {from: tokenOwnerAccount, gas: 4000000});
var tx1_2_3 = token.setWallet(crowdfundWallet, {from: tokenOwnerAccount, gas: 4000000});
while (txpool.status.pending > 0) {
}
printTxData("tx1_2_1", tx1_2_1);
printTxData("tx1_2_2", tx1_2_2);
printTxData("tx1_2_3", tx1_2_3);
printBalances();
failIfGasEqualsGasUsed(tx1_2_1, testMessage + " - precommitments");
failIfGasEqualsGasUsed(tx1_2_2, testMessage + " - tokensPerKEther Rate From 343,734 To 1,000,000");
failIfGasEqualsGasUsed(tx1_2_3, testMessage + " - change crowdsale wallet");
printTokenContractDynamicDetails();
console.log("RESULT: ");


// -----------------------------------------------------------------------------
// Wait for crowdsale start
// -----------------------------------------------------------------------------
var startDateTime = token.START_DATE();
var startDateTimeDate = new Date(startDateTime * 1000);
console.log("RESULT: Waiting until start date at " + startDateTime + " " + startDateTimeDate +
  " currentDate=" + new Date());
while ((new Date()).getTime() <= startDateTimeDate.getTime()) {
}
console.log("RESULT: Waited until start date at " + startDateTime + " " + startDateTimeDate +
  " currentDate=" + new Date());


// -----------------------------------------------------------------------------
var testMessage = "Test 2.1 Buy tokens";
console.log("RESULT: " + testMessage);
var tx2_1_1 = eth.sendTransaction({from: account2, to: tokenAddress, gas: 400000, value: web3.toWei("100", "ether")});
var tx2_1_2 = eth.sendTransaction({from: account3, to: tokenAddress, gas: 400000, value: web3.toWei("1000", "ether")});
var tx2_1_3 = eth.sendTransaction({from: account4, to: tokenAddress, gas: 400000, value: web3.toWei("10000", "ether")});
var tx2_1_4 = eth.sendTransaction({from: directorsAccount, to: tokenAddress, gas: 400000, value: web3.toWei("1000", "ether")});
var tx2_1_5 = token.proxyPayment(account6, {from: account5, to: tokenAddress, gas: 400000, value: web3.toWei("0.5", "ether")});
while (txpool.status.pending > 0) {
}
printTxData("tx2_1_1", tx2_1_1);
printTxData("tx2_1_2", tx2_1_2);
printTxData("tx2_1_3", tx2_1_3);
printTxData("tx2_1_4", tx2_1_4);
printTxData("tx2_1_5", tx2_1_5);
printBalances();
failIfGasEqualsGasUsed(tx2_1_1, testMessage + " - account2 buys 100,000 OAX for 100 ETH");
failIfGasEqualsGasUsed(tx2_1_2, testMessage + " - account3 buys 1,000,000 OAX for 1,000 ETH");
failIfGasEqualsGasUsed(tx2_1_3, testMessage + " - account4 buys 10,000,000 OAX for 10,000 ETH");
failIfGasEqualsGasUsed(tx2_1_4, testMessage + " - directorsAccount buys 1,000,000 OAX for 1,000 ETH");
failIfGasEqualsGasUsed(tx2_1_5, testMessage + " - account5 buys 500 OAX for 0.5 ETH on behalf of account6");
printTokenContractDynamicDetails();
console.log("RESULT: ");


// -----------------------------------------------------------------------------
var testMessage = "Test 3.1 Cannot Move Tokens Without Finalisation And KYC Verification";
console.log("RESULT: " + testMessage);
var tx3_1_1 = token.transfer(account5, "1000000000000", {from: account2, gas: 100000});
var tx3_1_2 = token.transfer(account6, "200000000000000", {from: account4, gas: 100000});
var tx3_1_3 = token.approve(account7,  "30000000000000000", {from: account3, gas: 100000});
var tx3_1_4 = token.approve(account8,  "4000000000000000000", {from: account4, gas: 100000});
while (txpool.status.pending > 0) {
}
var tx3_1_5 = token.transferFrom(account3, account7, "30000000000000000", {from: account7, gas: 100000});
var tx3_1_6 = token.transferFrom(account4, account8, "4000000000000000000", {from: account8, gas: 100000});
while (txpool.status.pending > 0) {
}
printTxData("tx3_1_1", tx3_1_1);
printTxData("tx3_1_2", tx3_1_2);
printTxData("tx3_1_3", tx3_1_3);
printTxData("tx3_1_4", tx3_1_4);
printTxData("tx3_1_5", tx3_1_5);
printTxData("tx3_1_6", tx3_1_6);
printBalances();
passIfGasEqualsGasUsed(tx3_1_1, testMessage + " - transfer 0.000001 OAX ac2 -> ac5. CHECK no movement");
passIfGasEqualsGasUsed(tx3_1_2, testMessage + " - transfer 0.0002 OAX ac4 -> ac6. CHECK no movement");
failIfGasEqualsGasUsed(tx3_1_3, testMessage + " - approve 0.03 OAX ac3 -> ac7");
failIfGasEqualsGasUsed(tx3_1_4, testMessage + " - approve 4 OAX ac4 -> ac8");
passIfGasEqualsGasUsed(tx3_1_5, testMessage + " - transferFrom 0.03 OAX ac3 -> ac5. CHECK no movement");
passIfGasEqualsGasUsed(tx3_1_6, testMessage + " - transferFrom 4 OAX ac4 -> ac6. CHECK no movement");
printTokenContractDynamicDetails();
console.log("RESULT: ");


// -----------------------------------------------------------------------------
var testMessage = "Test 4.1 Finalise crowdsale";
console.log("RESULT: " + testMessage);
var tx4_1 = token.finalise({from: tokenOwnerAccount, gas: 4000000});
while (txpool.status.pending > 0) {
}
printTxData("tx4_1", tx4_1);
printBalances();
failIfGasEqualsGasUsed(tx4_1, testMessage);
printTokenContractDynamicDetails();
console.log("RESULT: ");


// -----------------------------------------------------------------------------
var testMessage = "Test 5.1 KYC Verify";
console.log("RESULT: " + testMessage);
var tx5_1_1 = token.kycVerify(account2, {from: tokenOwnerAccount, gas: 4000000});
var tx5_1_2 = token.kycVerify(account3, {from: tokenOwnerAccount, gas: 4000000});
while (txpool.status.pending > 0) {
}
printTxData("tx5_1_1", tx5_1_1);
printTxData("tx5_1_2", tx5_1_2);
printBalances();
failIfGasEqualsGasUsed(tx5_1_1, testMessage + " - account2");
failIfGasEqualsGasUsed(tx5_1_2, testMessage + " - account3");
printTokenContractDynamicDetails();
console.log("RESULT: ");


// -----------------------------------------------------------------------------
var testMessage = "Test 6.1 Move Tokens After Finalising";
console.log("RESULT: " + testMessage);
console.log("RESULT: kyc(account3)=" + token.kycRequired(account3));
console.log("RESULT: kyc(account4)=" + token.kycRequired(account4));
var tx6_1_1 = token.transfer(account5, "1000000000000", {from: account2, gas: 100000});
var tx6_1_2 = token.transfer(account6, "200000000000000", {from: account4, gas: 100000});
var tx6_1_3 = token.approve(account7, "30000000000000000", {from: account3, gas: 100000});
var tx6_1_4 = token.approve(account8, "4000000000000000000", {from: account4, gas: 100000});
while (txpool.status.pending > 0) {
}
var tx6_1_5 = token.transferFrom(account3, account7, "30000000000000000", {from: account7, gas: 100000});
var tx6_1_6 = token.transferFrom(account4, account8, "4000000000000000000", {from: account8, gas: 100000});
while (txpool.status.pending > 0) {
}
printTxData("tx6_1_1", tx6_1_1);
printTxData("tx6_1_2", tx6_1_2);
printTxData("tx6_1_3", tx6_1_3);
printTxData("tx6_1_4", tx6_1_4);
printTxData("tx6_1_5", tx6_1_5);
printTxData("tx6_1_6", tx6_1_6);
printBalances();
failIfGasEqualsGasUsed(tx6_1_1, testMessage + " - transfer 0.000001 OAX ac2 -> ac5. CHECK for movement");
passIfGasEqualsGasUsed(tx6_1_2, testMessage + " - transfer 0.0002 OAX ac4 -> ac5. CHECK no movement");
failIfGasEqualsGasUsed(tx6_1_3, testMessage + " - approve 0.03 OAX ac3 -> ac5");
failIfGasEqualsGasUsed(tx6_1_4, testMessage + " - approve 4 OAX ac4 -> ac5");
failIfGasEqualsGasUsed(tx6_1_5, testMessage + " - transferFrom 0.03 OAX ac3 -> ac5. CHECK for movement");
passIfGasEqualsGasUsed(tx6_1_6, testMessage + " - transferFrom 4 OAX ac4 -> ac6. CHECK no movement");
printTokenContractDynamicDetails();
console.log("RESULT: ");



exit;


// TODO: Update test for this
if (!skipSafeMath && false) {
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

EOF
grep "DATA: " $TEST1OUTPUT | sed "s/DATA: //" > $DEPLOYMENTDATA
cat $DEPLOYMENTDATA
grep "RESULT: " $TEST1OUTPUT | sed "s/RESULT: //" > $TEST1RESULTS
cat $TEST1RESULTS
