# OpenANX Token

# Requirements

## Requirements From Token Sale Summary Sheet

* [x] Token Identifier
  * symbol `OAX`
  * name `openANX Token`
  * decimals `18`

* Tranche 1 30,000,000 (30%) OAX Crowdsale Dates
  * [x] START_DATE = 1498136400 Thursday, 22-Jun-17 13:00:00 UTC / 1pm GMT 22 June 2017
  * [x] END_DATE = 1500728400 Saturday, 22-Jul-17 13:00:00 UTC / 1pm GMT 22 July 2017

* Total of 100,000,000 OAX tokens
  * Tranche 1 30,000,000 (30%) OAX Crowdsale
    * [x] There is no minimum funding level in the smart contract as the precommitments already exceed the minimum funding level
    * [x] Soft cap of 13,000,000 OAX (ETH equivalence of USD 9,750,000)
    * [x] Hard cap of 30,000,000 OAX (ETH equivalence of USD 22,500,000)
    * [x] Tokens from precommitments funded via fiat and other currencies will be included in this tranche 
  * Tranche 2 30,000,000 (30%) OAX - locked for 1 year from token launch for Additional Token Sale (ATS)
    * 30,000,000 Tranche 2 token sale - Additional Token Sale (ATS). These tokens are subject to a lock-up for 1ß year from token launch
  * 20,000,000 (20%) OAX retained by the foundation, consisting of:
    * 10,000,000 (50%) OAX locked for 1 year from token launch
    * 10,000,000 (50%) OAX locked for 2 years from token launch
  * 20,000,000 allocated to founding supporters (directors, advisors and early backers) of the foundation, consisting of:
    * 14,000,000 (70%) locked for 1 year from token launch
    * 6,000,000 (30%) locked for 2 years from token launch

* OAX Token Price
  * Price per OAX
  * Equivalence of USD 0.75 ETH based on ETH/USD @ 12:00 GMT Jun 21 2017
  * This is 0.00309776 ETH as of Jun 5 2017
    * 1 OAX = 0.00309776 ETH
    * 1 ETH = 1 / 0.00309776 = 322.813904240483446 OAX
  * This will be encoded as an unsigned integer, 1,000 ETH = 322814 OAX with six significant figures 


## Requirements as discussed with Hugh May 11 2017:

* [ ] Accept commitments before deployment of the contract
* [ ] Min and max limits for contributions?
* [ ] Start and end block for contributions
* [ ] Early withdrawal if minimum funding reached
* [ ] Minimum funding amount
* [ ] Soft limit maximum funding amount
* [ ] When soft limit maximum reached, accept contributions for an additional 24 hours
* [ ] KYC and KYT
* [ ] Show tokens when funding received, but tokens are locked until KYC is satisfactory
* [ ] Consider KYC in a separate smart contract 
* [ ] KYC on redemption of tokens
* [ ] Approval of transactions based on amount, from and to
* [ ] Tokens freely tradeable without KYC, but will require KYC on issuance and redemption?
* [ ] Consider upgrade of tokens in the future
  * [ ] My preference is to publish a new token contract at a later date when the requirements are known, with a `newToken.upgrade()` function. The user has to execute `oldToken.approve(newTokenAddress, amount)`, then call `newToken.upgrade()`.
  
## Confirming KYC Requirements May 18 2017:

* [ ] Just confirming the KYC requirements:
  1. Any account can contribute to the crowdsale
  2. Crowdsale contributing accounts will **NOT** be able to move their tokens until they have been KYC-ed
  3. The KYC status in the smart contracts is just a simple KYC - Yes or No
  4. Once the tokens have been transferred from the original crowdsale contributing account, there is **NO** KYC required for transfers. The tokens can trade freely.

## Discussion with Hugh Jun 13 2017:

* [ ] Minimum crowdfunding level has been exceeded
  * [ ] Remove the need for the crowdsale participants to be able to withdraw their refunds if the minimum level is not reached
  * [ ] Remove the need for the ETH to be stored in the crowdfunding token contract
* [ ] A `finalise()` function may be required to move any unsold tokens in the tranche1 portion to the tranche2 portion
* [ ] Accounts with locked tokens can also participate in the crowdfunding



## Deployment Checklist

* Deploy contract to Mainnet
* Check START_DATE and END_DATE
* Check Solidity [release history](https://github.com/ethereum/solidity/releases) for potential bugs 
