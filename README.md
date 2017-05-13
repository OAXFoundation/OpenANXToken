# SuperDEX Token
SuperDEX Token


# Requirements

Requirements as discussed with Hugh May 11 2017:

* [ ] Accept commitments before deployment of the contract
* [ ] Min and max limits for contributions
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