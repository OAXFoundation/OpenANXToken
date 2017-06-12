# OpenANX Token - Testing

<br />

<hr />

# Table of contents

* [Requirements](#requirements)
* [Executing The Tests](#executing-the-tests)
* [The Tests](#the-tests)
* [Notes](#notes)

<br />

<hr />

# Requirements

* The tests works on OS/X. Should work in Linux. May work in Windows with Cygwin
* Geth/v1.6.0-stable-facc47cb/darwin-amd64/go1.8.1
* Solc 0.4.9+commit.364da425.Darwin.appleclang

<br />

<hr />

# Executing The Tests

* Run `geth` in dev mode

      ./00_runGeth.sh

* Run the test in [01_test1.sh](01_test1.sh)

      ./01_test1.sh

* See  [test1results.txt](test1results.txt) for the results and [test1output.txt](test1output.txt) for the full output.

<br />

<hr />

# The Tests

* Test 1 Before The Crowdsale
  * Test 1.1 Deploy Token Contract
  * Test 1.2 Add Precommitments, Change The tokensPerKEther Rate From 343,734 To 1,000,000 And Change Wallet
* Test 2 During The Crowdsale
  * Test 2.1 Buy tokens
* Test 3 Finalising

<br />

<hr />

# Notes

I prefer to test the Ethereum smart contracts against the Mainnet clients, using a Dev blockchain. This is to reduce the effects of different behaviours when testing agains truffle or one of the other testing frameworks.