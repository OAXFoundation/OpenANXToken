#!/bin/sh
# ----------------------------------------------------------------------------------------------
# Extract Token Balances for openANX
#
# Based on https://github.com/BitySA/whetcwithdraw/tree/master/daobalance
#
# Enjoy. (c) BokkyPooBah / Bok Consulting Pty Ltd 2017. The MIT Licence.
# ----------------------------------------------------------------------------------------------

# geth attach rpc:http://192.168.4.120:8545 << EOF
# geth attach << EOF
geth attach << EOF > tokenBalances.txt

var tokenAddress = "0x701C244b988a513c945973dEFA05de933b23Fe1D";
var tokenABI = [{"constant":false,"inputs":[{"name":"_spender","type":"address"},{"name":"_value","type":"uint256"}],"name":"approve","outputs":[{"name":"success","type":"bool"}],"payable":false,"type":"function"},{"constant":true,"inputs":[],"name":"totalSupply","outputs":[{"name":"totalSupply","type":"uint256"}],"payable":false,"type":"function"},{"constant":false,"inputs":[{"name":"_from","type":"address"},{"name":"_to","type":"address"},{"name":"_value","type":"uint256"}],"name":"transferFrom","outputs":[{"name":"success","type":"bool"}],"payable":false,"type":"function"},{"constant":true,"inputs":[{"name":"_owner","type":"address"}],"name":"balanceOf","outputs":[{"name":"balance","type":"uint256"}],"payable":false,"type":"function"},{"constant":false,"inputs":[{"name":"_to","type":"address"},{"name":"_value","type":"uint256"}],"name":"transfer","outputs":[{"name":"success","type":"bool"}],"payable":false,"type":"function"},{"constant":true,"inputs":[{"name":"_owner","type":"address"},{"name":"_spender","type":"address"}],"name":"allowance","outputs":[{"name":"remaining","type":"uint256"}],"payable":false,"type":"function"},{"anonymous":false,"inputs":[{"indexed":true,"name":"_from","type":"address"},{"indexed":true,"name":"_to","type":"address"},{"indexed":false,"name":"_value","type":"uint256"}],"name":"Transfer","type":"event"},{"anonymous":false,"inputs":[{"indexed":true,"name":"_owner","type":"address"},{"indexed":true,"name":"_spender","type":"address"},{"indexed":false,"name":"_value","type":"uint256"}],"name":"Approval","type":"event"}];
var token = web3.eth.contract(tokenABI).at(tokenAddress);
var fromBlock = 3908947;
var toBlock = 3971324; // Finalised in https://etherscan.io/tx/0xf7ba25c71bedc47d5237fd0e92cba266e627f32ca0de2946254359fa1dcedd0e
// var toBlock = parseInt(fromBlock) + 10000;
var block = eth.getBlock(toBlock);
console.log("STATS: snapshot at block=" + block.number + " time=" + block.timestamp + " " + new Date(block.timestamp * 1000).toUTCString());

function getAccounts() {
  var accounts = {};
  // Add accounts in precommitments
  accounts["0x3866259bc60e5b69d5c438db238d3b4c9db37bcb"] = 1;
  var transferEventsFilter = token.Transfer({}, {fromBlock: fromBlock, toBlock: toBlock});
  var transferEvents = transferEventsFilter.get();
  for (var i = 0; i < transferEvents.length; i++) {
    var transferEvent = transferEvents[i];
    console.log(JSON.stringify(transferEvent));
    accounts[transferEvent.args._from] = 1;
    accounts[transferEvent.args._to] = 1;
  }
  return Object.keys(accounts);
}

function getBalances(accounts) {
    var balances = [];
    var totalBalance = new BigNumber(0);
    for (var i = 0; i < accounts.length; i++) {
        var addressNum = new BigNumber(accounts[i].substring(2), 16);
        var amount = token.balanceOf(accounts[i], toBlock);
        if (amount.greaterThan(0)) {
            totalBalance = totalBalance.add(amount);
            // if (i%100 === 0) console.log("Processed: " + i);
            console.log("BALANCE: " + i + "\t" + accounts[i] + "\t" + amount.shift(-18) + "\t" + totalBalance.shift(-18));
        }
    }
    console.log("STATS: Total balance=" + totalBalance.toString(10));
    console.log("STATS: totalSupply=" + token.totalSupply().toString(10));
    return balances;
}

var accounts = getAccounts();
// console.log(JSON.stringify(accounts));
console.log("STATS: number of accounts, some may have a zero balances=" + accounts.length);
var balances = getBalances(accounts);
console.log("STATS: number of accounts+balances, only with non-zero balances=" + balances.length);
// console.log(JSON.stringify(balances, null, 2));
// console.log(JSON.stringify(balances));

EOF

grep "BALANCE: " tokenBalances.txt | sed "s/BALANCE: //" > tokenBalancesByAccounts.tsv
grep "STATS: " tokenBalances.txt | sed "s/STATS: //" > tokenStats.txt
