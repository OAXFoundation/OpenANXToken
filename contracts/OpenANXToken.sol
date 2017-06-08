pragma solidity ^0.4.10;
// ----------------------------------------------------------------------------
// OpenANX Token with crowdfunding
//
// 
//
// Enjoy. (c) OpenANX and BokkyPooBah / Bok Consulting Pty Ltd 2017. 
// The MIT Licence.
// ----------------------------------------------------------------------------

import "./ERC20Interface.sol";
import "./Owned.sol";
import "./SafeMath.sol";
import "./LockedTokens.sol";

// ----------------------------------------------------------------------------
// KYC Interface
// ----------------------------------------------------------------------------
contract OpenANXKYC {
    function confirmTokenTransfer(address from, address to, uint256 amount) returns (bool);
    function isKyc(address customer) returns (bool);
}


// ----------------------------------------------------------------------------
// ERC20 Token, with the addition of symbol, name and decimals
// ----------------------------------------------------------------------------
contract ERC20Token is ERC20Interface, SafeMath, Owned {
    string public symbol;
    string public name;
    uint8 public decimals;

    // ------------------------------------------------------------------------
    // Balances for each account
    // ------------------------------------------------------------------------
    mapping(address => uint256) balances;

    // ------------------------------------------------------------------------
    // Owner of account approves the transfer of an amount to another account
    // ------------------------------------------------------------------------
    mapping(address => mapping (address => uint256)) allowed;

    // ------------------------------------------------------------------------
    // Constructor
    // ------------------------------------------------------------------------
    function ERC20Token(
        string _symbol, 
        string _name, 
        uint8 _decimals, 
        uint256 _totalSupply
    ) Owned() {
        symbol = _symbol;
        name = _name;
        decimals = _decimals;
        totalSupply = _totalSupply;
        balances[owner] = _totalSupply;
    }

    // ------------------------------------------------------------------------
    // Get the account balance of another account with address _owner
    // ------------------------------------------------------------------------
    function balanceOf(address _owner) constant returns (uint256 balance) {
        return balances[_owner];
    }

    // ------------------------------------------------------------------------
    // Transfer the balance from owner's account to another account
    // ------------------------------------------------------------------------
    function transfer(address _to, uint256 _amount) returns (bool success) {
        if (balances[msg.sender] >= _amount             // User has balance
            && _amount > 0                              // Non-zero transfer
            && balances[_to] + _amount > balances[_to]  // Overflow check
        ) {
            balances[msg.sender] = safeSub(balances[msg.sender], _amount);
            balances[_to] = safeAdd(balances[_to], _amount);
            Transfer(msg.sender, _to, _amount);
            return true;
        } else {
            return false;
        }
    }

    // ------------------------------------------------------------------------
    // Allow _spender to withdraw from your account, multiple times, up to the
    // _value amount. If this function is called again it overwrites the
    // current allowance with _value.
    // ------------------------------------------------------------------------
    function approve(
        address _spender,
        uint256 _amount
    ) returns (bool success) {
        allowed[msg.sender][_spender] = _amount;
        Approval(msg.sender, _spender, _amount);
        return true;
    }

    // ------------------------------------------------------------------------
    // Spender of tokens transfer an amount of tokens from the token owner's
    // balance to another account. The owner of the tokens must already
    // have approve(...)-d this transfer
    // ------------------------------------------------------------------------
    function transferFrom(
        address _from,
        address _to,
        uint256 _amount
    ) returns (bool success) {
        if (balances[_from] >= _amount                  // From a/c has balance
            && allowed[_from][msg.sender] >= _amount    // Transfer approved
            && _amount > 0                              // Non-zero transfer
            && balances[_to] + _amount > balances[_to]  // Overflow check
        ) {
            balances[_from] = safeSub(balances[_from], _amount);
            allowed[_from][msg.sender] = safeSub(allowed[_from][msg.sender], 
                _amount);
            balances[_to] = safeAdd(balances[_to], _amount);
            Transfer(_from, _to, _amount);
            return true;
        } else {
            return false;
        }
    }

    // ------------------------------------------------------------------------
    // Returns the amount of tokens approved by the owner that can be
    // transferred to the spender's account
    // ------------------------------------------------------------------------
    function allowance(
        address _owner, 
        address _spender
    ) constant returns (uint256 remaining) {
        return allowed[_owner][_spender];
    }
}


// ----------------------------------------------------------------------------
// ERC Token Standard #20 - https://github.com/ethereum/EIPs/issues/20
// With the addition of symbol, name and decimals
// ----------------------------------------------------------------------------
contract OpenANXToken is ERC20Token {

    uint256 public constant TOKENS_MIN = 10000000;
    uint256 public constant TOKENS_SOFT_CAP = 13000000;
    uint256 public constant TOKENS_HARD_CAP = 30000000;
    uint256 public constant SOFT_CAP_PERIOD = 24 hours;
    uint256 public totalFunding;
    bool public finalised = false;

    // Thursday, 22-Jun-17 00:00:00 UTC. Do not use `now`
    uint256 public constant START_DATE = 1498089600;
    // Friday, 21-Jul-17 00:00:00 UTC. Do not use `now`
    uint256 public constant END_DATE = 1500595200;
    uint256 public softCapEndDate = END_DATE;
    bool public softCapReached = false;

    uint256 public CONTRIBUTIONS_MIN = 0 ether;
    uint256 public CONTRIBUTIONS_MAX = 250 ether;

    // Number of tokens per ether. This can be adjusted as the ETH/USD rate
    // changes. And event is logged when this rate is updated
    uint256 public tokensPerEther = 100;

    // Locked Tokens
    LockedTokens public lockedTokens;

    uint256 public issuedTokens;

    // Decimal factor for multiplications
    uint256 decimalsFactor;


    // ------------------------------------------------------------------------
    // Constructor
    // ------------------------------------------------------------------------
    function OpenANXToken() ERC20Token("OAX", "openANX Token", 18, 0) {
        decimalsFactor = 10**uint256(decimals);
        lockedTokens = new LockedTokens(this, decimals);
    }

    // ------------------------------------------------------------------------
    // Set number of tokens per ETH. Can only be set before the start date
    // ------------------------------------------------------------------------
    function setTokensPerEther(uint256 _tokensPerEther) onlyOwner {
        if (now >= START_DATE) throw;
        if (_tokensPerEther == 0) throw;
        tokensPerEther = _tokensPerEther;
        TokensPerEtherUpdated(tokensPerEther);
    }
    event TokensPerEtherUpdated(uint256 tokensPerEther);

    // ------------------------------------------------------------------------
    // Accept ethers to buy tokens
    // ------------------------------------------------------------------------
    function () payable {
        // Refunds as minimum funding not raised
        if (now > softCapEndDate && issuedTokens < TOKENS_MIN * decimalsFactor) {
            uint256 tokensToRefund = balances[msg.sender];
            if (tokens == 0) throw;
            balances[msg.sender] = 0;
            totalSupply -= tokensToRefund;
            uint256 ethersToRefund = tokensToRefund / tokensPerEther * 10**uint256(18 - decimals);
            Transfer(msg.sender, 0x0, tokensToRefund);
            TokensRefunded(msg.sender, ethersToRefund, this.balance - ethersToRefund, tokensToRefund,
                 totalSupply, tokensPerEther);
            // Also refund any ethers sent with the transaction
            if (!msg.sender.send(ethersToRefund + msg.value)) throw;

        } else {
            if (finalised) throw;
            if (now < START_DATE) throw;
            if (now > END_DATE) throw;
            if (now > softCapEndDate) throw;
            if (msg.value < CONTRIBUTIONS_MIN) throw;
            if (msg.value > CONTRIBUTIONS_MAX) throw;

            uint tokens = msg.value * tokensPerEther / 10**uint256(18 - decimals);
            if (totalSupply + tokens > TOKENS_HARD_CAP * decimalsFactor) throw;

            balances[msg.sender] = safeAdd(balances[msg.sender], tokens);
            totalSupply = safeAdd(totalSupply, tokens);
            issuedTokens += tokens;
            Transfer(0x0, msg.sender, tokens);
            TokensBought(msg.sender, msg.value, this.balance, tokens,
                 totalSupply, tokensPerEther);

            // Check if soft cap just reached
            if (!softCapReached && totalSupply > TOKENS_SOFT_CAP * decimalsFactor) {
                softCapEndDate = now + SOFT_CAP_PERIOD;
                softCapReached = true;
            }
        }
    }
    event TokensBought(address indexed buyer, uint256 ethers, 
        uint256 newEtherBalance, uint256 tokens, uint256 newTotalSupply, 
        uint256 tokensPerEther);
    event TokensRefunded(address indexed buyer, uint256 ethers, 
        uint256 newEtherBalance, uint256 tokens, uint256 newTotalSupply, 
        uint256 tokensPerEther);

    function finalise() {
        // Can only finalise once one of the following conditions are met:
        // - The time is past the softCapEndDate (which is the END_DATE if the 
        //   soft cap is not reached)
        // - The funds raised is equal to CONTRIBUTIONS_MAX
        if (finalised) throw;
        // Allocate locked and premined tokens
        balances[this] += lockedTokens.totalSupplyLocked();
        totalSupply += lockedTokens.totalSupplyLocked();
        finalised = true;
        // TODO Move funds to wallet
    }

    // ------------------------------------------------------------------------
    // Precommitment funding can be added before the funding block
    // ------------------------------------------------------------------------
    // function addPrecommitment(address participant) payable onlyOwner beforeFundingPeriod {
    //     balances[participant] = safeAdd(balances[participant], msg.value);
    //     totalFunding = safeAdd(totalFunding, msg.value);
    // }

    // ------------------------------------------------------------------------
    // Funding can only be added during the funding period
    // ------------------------------------------------------------------------
    // function addFunding() payable duringFundingPeriod {
    //     balances[msg.sender] = safeAdd(balances[msg.sender], msg.value);
    //     totalFunding = safeAdd(totalFunding, msg.value);
    // }

    // ------------------------------------------------------------------------
    // Transfer out any accidentally sent ERC20 tokens
    // ------------------------------------------------------------------------
    function transferAnyERC20Token(
        address tokenAddress, 
        uint256 amount
    ) onlyOwner returns (bool success) {
        return ERC20Interface(tokenAddress).transfer(owner, amount);
    }
}