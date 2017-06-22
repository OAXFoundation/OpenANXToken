#!/bin/bash
# ----------------------------------------------------------------------------------------------
# Get Details For The openANX token contract
#
# Enjoy. (c) openANX & BokkyPooBah / Bok Consulting Pty Ltd 2017. The MIT Licence.
# ----------------------------------------------------------------------------------------------

# Set below if you don't want to use IPC
# GETHATTACHPOINT=rpc:http://localhost:8545
# GETHATTACHPOINT=rpc:http://localhost:8646

DATE=`date "+%Y%m%d_%H%M%S"`
# DATE=`date "+%Y%m%d"`
echo "Date: $DATE"

TEMPFILE=Temp-$DATE.txt
MAINFILE=Main-$DATE.txt
TOKENSBOUGHTFILE=TokensBought-$DATE.tsv
TRANSFERFILE=Transfers-$DATE.tsv

geth --verbosity 3 attach $GETHATTACHPOINT << EOF | tee $TEMPFILE

var tokenAddress="0x701c244b988a513c945973defa05de933b23fe1d";
var tokenDeploymentBlock=3908947;
// DEV var tokenAddress="0x90d8927407c79c4a28ee879b821c76fc9bcc2688";
// DEV var tokenDeploymentBlock=0;

var tokenAbi=[{"constant":true,"inputs":[],"name":"name","outputs":[{"name":"","type":"string"}],"payable":false,"type":"function"},{"constant":false,"inputs":[{"name":"_spender","type":"address"},{"name":"_amount","type":"uint256"}],"name":"approve","outputs":[{"name":"success","type":"bool"}],"payable":false,"type":"function"},{"constant":true,"inputs":[],"name":"TOKENS_TOTAL","outputs":[{"name":"","type":"uint256"}],"payable":false,"type":"function"}, \
  {"constant":false,"inputs":[{"name":"_tokensPerKEther","type":"uint256"}],"name":"setTokensPerKEther","outputs":[],"payable":false,"type":"function"},{"constant":true,"inputs":[],"name":"lockedTokens","outputs":[{"name":"","type":"address"}],"payable":false,"type":"function"},{"constant":true,"inputs":[],"name":"totalSupply","outputs":[{"name":"","type":"uint256"}],"payable":false,"type":"function"},{"constant":false,"inputs":[{"name":"participant","type":"address"}],"name":"kycVerify","outputs":[],"payable":false,"type":"function"},{"constant":true,"inputs":[{"name":"account","type":"address"}],"name":"balanceOfLocked1Y","outputs":[{"name":"balance","type":"uint256"}],"payable":false,"type":"function"},{"constant":true,"inputs":[],"name":"finalised","outputs":[{"name":"","type":"bool"}],"payable":false,"type":"function"},{"constant":false,"inputs":[{"name":"_from","type":"address"},{"name":"_to","type":"address"},{"name":"_amount","type":"uint256"}],"name":"transferFrom","outputs":[{"name":"success","type":"bool"}],"payable":false,"type":"function"},{"constant":true,"inputs":[],"name":"CONTRIBUTIONS_MIN","outputs":[{"name":"","type":"uint256"}],"payable":false,"type":"function"},{"constant":true,"inputs":[],"name":"DECIMALS","outputs":[{"name":"","type":"uint8"}],"payable":false,"type":"function"},{"constant":true,"inputs":[],"name":"decimals","outputs":[{"name":"","type":"uint8"}],"payable":false,"type":"function"},{"constant":true,"inputs":[],"name":"START_DATE","outputs":[{"name":"","type":"uint256"}],"payable":false,"type":"function"},{"constant":false,"inputs":[{"name":"participant","type":"address"},{"name":"balance","type":"uint256"}],"name":"addPrecommitment","outputs":[],"payable":false,"type":"function"},{"constant":true,"inputs":[],"name":"TOKENS_SOFT_CAP","outputs":[{"name":"","type":"uint256"}],"payable":false,"type":"function"},{"constant":true,"inputs":[],"name":"wallet","outputs":[{"name":"","type":"address"}],"payable":false,"type":"function"},{"constant":true,"inputs":[],"name":"END_DATE","outputs":[{"name":"","type":"uint256"}],"payable":false,"type":"function"},{"constant":true,"inputs":[],"name":"totalSupplyLocked","outputs":[{"name":"","type":"uint256"}],"payable":false,"type":"function"},{"constant":true,"inputs":[],"name":"totalSupplyLocked2Y","outputs":[{"name":"","type":"uint256"}],"payable":false,"type":"function"},{"constant":true,"inputs":[{"name":"_owner","type":"address"}],"name":"balanceOf","outputs":[{"name":"balance","type":"uint256"}],"payable":false,"type":"function"},{"constant":false,"inputs":[],"name":"acceptOwnership","outputs":[],"payable":false,"type":"function"},{"constant":false,"inputs":[{"name":"_from","type":"address"},{"name":"_amount","type":"uint256"}],"name":"burnFrom","outputs":[{"name":"success","type":"bool"}],"payable":false,"type":"function"},{"constant":true,"inputs":[],"name":"TOKENS_HARD_CAP","outputs":[{"name":"","type":"uint256"}],"payable":false,"type":"function"},{"constant":true,"inputs":[],"name":"DECIMALSFACTOR","outputs":[{"name":"","type":"uint256"}],"payable":false,"type":"function"},{"constant":true,"inputs":[],"name":"owner","outputs":[{"name":"","type":"address"}],"payable":false,"type":"function"},{"constant":true,"inputs":[],"name":"CONTRIBUTIONS_MAX","outputs":[{"name":"","type":"uint256"}],"payable":false,"type":"function"},{"constant":true,"inputs":[],"name":"symbol","outputs":[{"name":"","type":"string"}],"payable":false,"type":"function"},{"constant":true,"inputs":[],"name":"LOCKED_2Y_DATE","outputs":[{"name":"","type":"uint256"}],"payable":false,"type":"function"},{"constant":true,"inputs":[],"name":"NAME","outputs":[{"name":"","type":"string"}],"payable":false,"type":"function"},{"constant":false,"inputs":[],"name":"finalise","outputs":[],"payable":false,"type":"function"},{"constant":true,"inputs":[],"name":"tokensPerKEther","outputs":[{"name":"","type":"uint256"}],"payable":false,"type":"function"},{"constant":false,"inputs":[{"name":"_to","type":"address"},{"name":"_amount","type":"uint256"}],"name":"transfer","outputs":[{"name":"success","type":"bool"}],"payable":false,"type":"function"},{"constant":true,"inputs":[{"name":"","type":"address"}],"name":"kycRequired","outputs":[{"name":"","type":"bool"}],"payable":false,"type":"function"},{"constant":true,"inputs":[{"name":"account","type":"address"}],"name":"balanceOfLocked2Y","outputs":[{"name":"balance","type":"uint256"}],"payable":false,"type":"function"},{"constant":true,"inputs":[],"name":"totalSupplyLocked1Y","outputs":[{"name":"","type":"uint256"}],"payable":false,"type":"function"},{"constant":true,"inputs":[],"name":"totalSupplyUnlocked","outputs":[{"name":"","type":"uint256"}],"payable":false,"type":"function"},{"constant":true,"inputs":[],"name":"newOwner","outputs":[{"name":"","type":"address"}],"payable":false,"type":"function"},{"constant":false,"inputs":[{"name":"tokenAddress","type":"address"},{"name":"amount","type":"uint256"}],"name":"transferAnyERC20Token","outputs":[{"name":"success","type":"bool"}],"payable":false,"type":"function"},{"constant":true,"inputs":[{"name":"_owner","type":"address"},{"name":"_spender","type":"address"}],"name":"allowance","outputs":[{"name":"remaining","type":"uint256"}],"payable":false,"type":"function"},{"constant":false,"inputs":[{"name":"_wallet","type":"address"}],"name":"setWallet","outputs":[],"payable":false,"type":"function"},{"constant":true,"inputs":[{"name":"account","type":"address"}],"name":"balanceOfLocked","outputs":[{"name":"balance","type":"uint256"}],"payable":false,"type":"function"},{"constant":false,"inputs":[{"name":"_newOwner","type":"address"}],"name":"transferOwnership","outputs":[],"payable":false,"type":"function"},{"constant":true,"inputs":[],"name":"LOCKED_1Y_DATE","outputs":[{"name":"","type":"uint256"}],"payable":false,"type":"function"},{"constant":false,"inputs":[{"name":"participant","type":"address"}],"name":"proxyPayment","outputs":[],"payable":true,"type":"function"},{"constant":true,"inputs":[],"name":"SYMBOL","outputs":[{"name":"","type":"string"}],"payable":false,"type":"function"},{"inputs":[{"name":"_wallet","type":"address"}],"payable":false,"type":"constructor"},{"payable":true,"type":"fallback"},{"anonymous":false,"inputs":[{"indexed":false,"name":"newWallet","type":"address"}],"name":"WalletUpdated","type":"event"},{"anonymous":false,"inputs":[{"indexed":false,"name":"tokensPerKEther","type":"uint256"}],"name":"TokensPerKEtherUpdated","type":"event"},{"anonymous":false,"inputs":[{"indexed":true,"name":"buyer","type":"address"},{"indexed":false,"name":"ethers","type":"uint256"},{"indexed":false,"name":"newEtherBalance","type":"uint256"},{"indexed":false,"name":"tokens","type":"uint256"},{"indexed":false,"name":"newTotalSupply","type":"uint256"},{"indexed":false,"name":"tokensPerKEther","type":"uint256"}],"name":"TokensBought","type":"event"},{"anonymous":false,"inputs":[{"indexed":true,"name":"participant","type":"address"},{"indexed":false,"name":"balance","type":"uint256"}],"name":"PrecommitmentAdded","type":"event"},{"anonymous":false,"inputs":[{"indexed":true,"name":"participant","type":"address"}],"name":"KycVerified","type":"event"},{"anonymous":false,"inputs":[{"indexed":true,"name":"_from","type":"address"},{"indexed":true,"name":"_to","type":"address"}],"name":"OwnershipTransferred","type":"event"},{"anonymous":false,"inputs":[{"indexed":true,"name":"_from","type":"address"},{"indexed":true,"name":"_to","type":"address"},{"indexed":false,"name":"_value","type":"uint256"}],"name":"Transfer","type":"event"},{"anonymous":false,"inputs":[{"indexed":true,"name":"_owner","type":"address"},{"indexed":true,"name":"_spender","type":"address"},{"indexed":false,"name":"_value","type":"uint256"}],"name":"Approval","type":"event"}];
var lockedTokensAbi=[{"constant":true,"inputs":[],"name":"TOKENS_TOTAL","outputs":[{"name":"","type":"uint256"}],"payable":false,"type":"function"},{"constant":true,"inputs":[{"name":"","type":"address"}],"name":"balancesLocked2Y","outputs":[{"name":"","type":"uint256"}],"payable":false,"type":"function"},{"constant":true,"inputs":[{"name":"account","type":"address"}],"name":"balanceOfLocked1Y","outputs":[{"name":"balance","type":"uint256"}],"payable":false,"type":"function"},{"constant":true,"inputs":[],"name":"CONTRIBUTIONS_MIN","outputs":[{"name":"","type":"uint256"}],"payable":false,"type":"function"},{"constant":true,"inputs":[],"name":"DECIMALS","outputs":[{"name":"","type":"uint8"}],"payable":false,"type":"function"},{"constant":true,"inputs":[],"name":"START_DATE","outputs":[{"name":"","type":"uint256"}],"payable":false,"type":"function"},{"constant":false,"inputs":[],"name":"unlock1Y","outputs":[],"payable":false,"type":"function"},{"constant":true,"inputs":[],"name":"TOKENS_SOFT_CAP","outputs":[{"name":"","type":"uint256"}],"payable":false,"type":"function"},{"constant":true,"inputs":[],"name":"TOKENS_LOCKED_1Y_TOTAL","outputs":[{"name":"","type":"uint256"}],"payable":false,"type":"function"},{"constant":true,"inputs":[],"name":"END_DATE","outputs":[{"name":"","type":"uint256"}],"payable":false,"type":"function"},{"constant":true,"inputs":[],"name":"tokenContract","outputs":[{"name":"","type":"address"}],"payable":false,"type":"function"},{"constant":true,"inputs":[],"name":"totalSupplyLocked","outputs":[{"name":"","type":"uint256"}],"payable":false,"type":"function"},{"constant":true,"inputs":[],"name":"totalSupplyLocked2Y","outputs":[{"name":"","type":"uint256"}],"payable":false,"type":"function"},{"constant":true,"inputs":[{"name":"","type":"address"}],"name":"balancesLocked1Y","outputs":[{"name":"","type":"uint256"}],"payable":false,"type":"function"},{"constant":true,"inputs":[],"name":"TRANCHE2_ACCOUNT","outputs":[{"name":"","type":"address"}],"payable":false,"type":"function"},{"constant":true,"inputs":[],"name":"TOKENS_HARD_CAP","outputs":[{"name":"","type":"uint256"}],"payable":false,"type":"function"},{"constant":true,"inputs":[],"name":"DECIMALSFACTOR","outputs":[{"name":"","type":"uint256"}],"payable":false,"type":"function"},{"constant":true,"inputs":[],"name":"CONTRIBUTIONS_MAX","outputs":[{"name":"","type":"uint256"}],"payable":false,"type":"function"},{"constant":true,"inputs":[],"name":"LOCKED_2Y_DATE","outputs":[{"name":"","type":"uint256"}],"payable":false,"type":"function"},{"constant":true,"inputs":[],"name":"NAME","outputs":[{"name":"","type":"string"}],"payable":false,"type":"function"},{"constant":true,"inputs":[{"name":"account","type":"address"}],"name":"balanceOfLocked2Y","outputs":[{"name":"balance","type":"uint256"}],"payable":false,"type":"function"},{"constant":true,"inputs":[],"name":"totalSupplyLocked1Y","outputs":[{"name":"","type":"uint256"}],"payable":false,"type":"function"},{"constant":false,"inputs":[],"name":"unlock2Y","outputs":[],"payable":false,"type":"function"},{"constant":true,"inputs":[{"name":"account","type":"address"}],"name":"balanceOfLocked","outputs":[{"name":"balance","type":"uint256"}],"payable":false,"type":"function"},{"constant":false,"inputs":[],"name":"addRemainingTokens","outputs":[],"payable":false,"type":"function"},{"constant":true,"inputs":[],"name":"LOCKED_1Y_DATE","outputs":[{"name":"","type":"uint256"}],"payable":false,"type":"function"},{"constant":true,"inputs":[],"name":"SYMBOL","outputs":[{"name":"","type":"string"}],"payable":false,"type":"function"},{"constant":true,"inputs":[],"name":"TOKENS_LOCKED_2Y_TOTAL","outputs":[{"name":"","type":"uint256"}],"payable":false,"type":"function"},{"inputs":[{"name":"_tokenContract","type":"address"}],"payable":false,"type":"constructor"}];

var contract = eth.contract(tokenAbi).at(tokenAddress);
var lockedTokenAddress = contract.lockedTokens();
var lockedTokenContract = eth.contract(lockedTokensAbi).at(lockedTokenAddress);
var decimals = contract.decimals();
console.log("MAIN: token.address=" + tokenAddress);
console.log("MAIN: token.lockedTokensAddress=" + lockedTokenAddress);
var currentTime = new Date();
console.log("MAIN: currentTime=" + currentTime / 1000 + " " + currentTime.toUTCString() + " / " + currentTime.toGMTString());
var startDate = contract.START_DATE();
console.log("MAIN: token.START_DATE=" + startDate + " " + new Date(startDate * 1000).toUTCString()  + " / " + new Date(startDate * 1000).toGMTString());
var endDate = contract.END_DATE();
console.log("MAIN: token.END_DATE=" + endDate + " " + new Date(endDate * 1000).toUTCString() + " / " + new Date(endDate * 1000).toGMTString());
console.log("MAIN: token.symbol=" + contract.symbol());
console.log("MAIN: token.name=" + contract.name());
console.log("MAIN: token.decimals=" + decimals);
console.log("MAIN: token.DECIMALSFACTOR=" + contract.DECIMALSFACTOR());
console.log("MAIN: token.TOKENS_SOFT_CAP=" + contract.TOKENS_SOFT_CAP().shift(-decimals));
console.log("MAIN: token.TOKENS_HARD_CAP=" + contract.TOKENS_HARD_CAP().shift(-decimals));
console.log("MAIN: token.TOKENS_TOTAL=" + contract.TOKENS_TOTAL().shift(-decimals));
console.log("MAIN: token.finalised=" + contract.finalised());
console.log("MAIN: token.tokensPerKEther=" + contract.tokensPerKEther());
console.log("MAIN: token.totalSupply=" + contract.totalSupply().shift(-decimals));
console.log("MAIN: token.totalSupplyLocked(1Y/2Y)=" + contract.totalSupplyLocked1Y().shift(-decimals) + " / " + contract.totalSupplyLocked2Y().shift(-decimals));
console.log("MAIN: token.totalSupplyLocked=" + contract.totalSupplyLocked().shift(-decimals));
console.log("MAIN: token.totalSupplyUnlocked=" + contract.totalSupplyUnlocked().shift(-decimals));
var locked1YDate = contract.LOCKED_1Y_DATE();
console.log("MAIN: token.LOCKED_1Y_DATE=" + locked1YDate + " " + new Date(locked1YDate * 1000).toUTCString() + " / " + new Date(locked1YDate * 1000).toGMTString());
var locked2YDate = contract.LOCKED_2Y_DATE();
console.log("MAIN: token.LOCKED_2Y_DATE=" + locked2YDate + " " + new Date(locked2YDate * 1000).toUTCString() + " / " + new Date(locked2YDate * 1000).toGMTString());
console.log("MAIN: lockedToken.TOKENS_LOCKED_1Y_TOTAL=" + lockedTokenContract.TOKENS_LOCKED_1Y_TOTAL().shift(-decimals));
console.log("MAIN: lockedToken.TOKENS_LOCKED_2Y_TOTAL=" + lockedTokenContract.TOKENS_LOCKED_2Y_TOTAL().shift(-decimals));
console.log("MAIN: lockedToken.totalSupplyLocked1Y=" + lockedTokenContract.totalSupplyLocked1Y().shift(-decimals));
console.log("MAIN: lockedToken.totalSupplyLocked2Y=" + lockedTokenContract.totalSupplyLocked2Y().shift(-decimals));
console.log("MAIN: lockedToken.totalSupplyLocked=" + lockedTokenContract.totalSupplyLocked().shift(-decimals));
console.log("MAIN: token.owner=" + contract.owner());
console.log("MAIN: token.newOwner=" + contract.newOwner());

var latestBlock = eth.blockNumber;
var i;

var ownershipTransferredEvent = contract.OwnershipTransferred({}, { fromBlock: tokenDeploymentBlock, toBlock: latestBlock });
i = 0;
ownershipTransferredEvent.watch(function (error, result) {
  console.log("MAIN: OwnershipTransferred Event " + i++ + ": from=" + result.args._from + " to=" + result.args._to + " " + result.blockNumber);
});

var tokensPerKEtherUpdatedEvent = contract.TokensPerKEtherUpdated({}, { fromBlock: tokenDeploymentBlock, toBlock: latestBlock });
i = 0;
tokensPerKEtherUpdatedEvent.watch(function (error, result) {
  console.log("MAIN: TokensPerKEtherUpdated Event " + i++ + ": tokensPerKEther=" + result.args.tokensPerKEther + " block=" + result.blockNumber);
});
tokensPerKEtherUpdatedEvent.stopWatching();

var walletUpdatedEvent = contract.WalletUpdated({}, { fromBlock: tokenDeploymentBlock, toBlock: latestBlock });
i = 0;
walletUpdatedEvent.watch(function (error, result) {
  console.log("MAIN: WalletUpdated Event " + i++ + ": from=" + result.args.newWallet + " block=" + result.blockNumber);
});
walletUpdatedEvent.stopWatching();

var tokensBoughtEvent = contract.TokensBought({}, { fromBlock: tokenDeploymentBlock, toBlock: latestBlock });
i = 0;
var totalEthers = new BigNumber(0);
console.log("TOKENSBOUGHT: No\tBuyer\tEthers\tEtherBalance\tTokens\tTokenBalance\tTokensPerKEther\tBlock\tTxIndex\tTxHash");
tokensBoughtEvent.watch(function (error, result) {
  totalEthers = totalEthers.add(result.args.ethers);
  console.log("TOKENSBOUGHT: " + i++ + "\t" + result.args.buyer + "\t" + web3.fromWei(result.args.ethers, "ether") + "\t" + web3.fromWei(totalEthers, "ether") + 
    "\t" + result.args.tokens.shift(-decimals) + "\t" + result.args.newTotalSupply.shift(-decimals) + "\t" + result.args.tokensPerKEther + "\t" + result.blockNumber + "\t" +
    result.transactionIndex + "\t" + result.transactionHash);
});
tokensBoughtEvent.stopWatching();

var kycVerifiedEvent = contract.KycVerified({}, { fromBlock: tokenDeploymentBlock, toBlock: latestBlock });
i = 0;
kycVerifiedEvent.watch(function (error, result) {
  console.log("MAIN: KycVerified Event " + i++ + ": participant=" + result.args.participant + " block=" + result.blockNumber);
});
kycVerifiedEvent.stopWatching();

var approvalEvent = contract.Approval({}, { fromBlock: tokenDeploymentBlock, toBlock: latestBlock });
i = 0;
approvalEvent.watch(function (error, result) {
  console.log("MAIN: Approval Event " + i++ + ": owner=" + result.args._owner + " spender=" + result.args._spender + " " +
    result.args._value.shift(-decimals) + " block=" + result.blockNumber);
});
approvalEvent.stopWatching();

var transferEvent = contract.Transfer({}, { fromBlock: tokenDeploymentBlock, toBlock: latestBlock });
i = 0;
var totalTokens = new BigNumber(0);
console.log("TRANSFER: No\tFrom\tTo\tTokens\tTokenBalance\tBlock\tTxIndex\tTxHash");
transferEvent.watch(function (error, result) {
  // console.log("TRANSFER: " + JSON.stringify(result));
  totalTokens = totalTokens.add(result.args._value);
  console.log("TRANSFER: " + i++ + "\t" + result.args._from + "\t" + result.args._to + "\t" + result.args._value.shift(-decimals) + 
    "\t" + totalTokens.shift(-decimals) + "\t" + result.blockNumber + "\t" + result.transactionIndex + "\t" + result.transactionHash);
});
transferEvent.stopWatching();

EOF

grep "MAIN: " $TEMPFILE | sed "s/MAIN: //" > $MAINFILE
grep "TOKENSBOUGHT: " $TEMPFILE | sed "s/TOKENSBOUGHT: //" > $TOKENSBOUGHTFILE
grep "TRANSFER: " $TEMPFILE | sed "s/TRANSFER: //" > $TRANSFERFILE
