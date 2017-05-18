# SuperDEX Token
SuperDEX Token


# Requirements

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
