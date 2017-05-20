pragma solidity ^0.4.9;
// ----------------------------------------------------------------------------
// OpenANX Token with crowdfunding
//
// 
//
// Enjoy. (c) OpenANX and BokkyPooBah / Bok Consulting Pty Ltd 2017. 
// The MIT Licence.
// ----------------------------------------------------------------------------


// ----------------------------------------------------------------------------
// KYC Interface
// ----------------------------------------------------------------------------
contract OpenANXKYC {
    function confirmTokenTransfer(address from, address to, uint256 amount) returns (bool);
    function isKyc(address customer) returns (bool);
}


// ----------------------------------------------------------------------------
// ERC Token Standard #20 Interface
// https://github.com/ethereum/EIPs/issues/20
// ----------------------------------------------------------------------------
contract ERC20Interface {
    uint256 public totalSupply;
    function balanceOf(address _owner) constant returns (uint256 balance);
    function transfer(address _to, uint256 _value) returns (bool success);
    function transferFrom(address _from, address _to, uint256 _value) 
        returns (bool success);
    function approve(address _spender, uint256 _value) returns (bool success);
    function allowance(address _owner, address _spender) constant 
        returns (uint256 remaining);
    event Transfer(address indexed _from, address indexed _to, uint256 _value);
    event Approval(address indexed _owner, address indexed _spender, 
        uint256 _value);
}


// ----------------------------------------------------------------------------
// Owned contract
// ----------------------------------------------------------------------------
contract Owned {
    address public owner;
    address public newOwner;
    event OwnershipTransferred(address indexed _from, address indexed _to);

    function Owned() {
        owner = msg.sender;
    }

    modifier onlyOwner {
        if (msg.sender != owner) throw;
        _;
    }

    function transferOwnership(address _newOwner) onlyOwner {
        newOwner = _newOwner;
    }
 
    function acceptOwnership() {
        if (msg.sender == newOwner) {
            OwnershipTransferred(owner, newOwner);
            owner = newOwner;
        }
    }
}


// ----------------------------------------------------------------------------
// Safe maths
// ----------------------------------------------------------------------------
contract SafeMath {
    function safeAdd(uint256 a, uint256 b) constant returns (uint256) {
        uint256 c = a + b;
        if (c < a || c < b) throw;
        return c;
    }

    function safeSub(uint256 a, uint256 b) constant returns (uint256) {
        uint256 c = a - b;
        if (c > a) throw;
        return c;
    }
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
    // balance to the spender's account. The owner of the tokens must already
    // have approve(...)-d this transfer
    // ------------------------------------------------------------------------
    function transferFrom(
        address _from,
        address _to,
        uint256 _amount
    ) returns (bool success) {
        if (balances[_from] >= _amount                  // User has balance
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

    uint256 public constant MINIMUM_FUNDING = 123;
    uint256 public constant MAXIMUM_SOFT_FUNDING = 345;
    uint256 public constant HARD_CAP_PERIOD = 678;
    uint256 public totalFunding;

    // Thursday, 22-Jun-17 00:00:00 UTC
    uint256 public constant START_DATE = 1495610867; // Wed 24 May 2017 07:27:47 UTC
    // Friday, 21-Jul-17 00:00:00 UTC
    uint256 public constant END_DATE = 1495611167; // Wed 24 May 2017 07:32:47 UTC

    // Number of tokens per ether. This can be adjusted as the ETH/USD rate
    // changes. And event is logged when this rate is updated
    uint256 public tokensPerEther = 100;

    // ------------------------------------------------------------------------
    // Before, During and After the funding period
    // ------------------------------------------------------------------------
    modifier beforeFundingPeriod {
        if (now >= START_DATE) throw;
        _;
    }
    modifier duringFundingPeriod {
        if (now < START_DATE || now > END_DATE) throw;
        _;
    }
    modifier afterFundingPeriod {
        if (now <= END_DATE) throw;
        _;
    }


    // ------------------------------------------------------------------------
    // Constructor
    // ------------------------------------------------------------------------
    function OpenANXToken() ERC20Token("OAX", "OpenANX Token", 18, 0) {
    }

    // ------------------------------------------------------------------------
    // Constructor
    // ------------------------------------------------------------------------
    function setTokensPerEther(uint256 _tokensPerEther) onlyOwner beforeFundingPeriod {
        if (_tokensPerEther == 0) throw;
        tokensPerEther = _tokensPerEther;
        TokensPerEtherUpdated(tokensPerEther);
    }
    event TokensPerEtherUpdated(uint256 tokensPerEther);

    // ------------------------------------------------------------------------
    // Accept ethers to buy tokens
    // ------------------------------------------------------------------------
    function () payable {
        buyTokens();
    }
    function buyTokens() payable duringFundingPeriod {
        if (msg.value > 0) {
            uint tokens = msg.value * tokensPerEther;
            balances[msg.sender] = safeAdd(balances[msg.sender], tokens);
            totalSupply = safeAdd(totalSupply, tokens);
            TokensBought(msg.sender, msg.value, this.balance, tokens,
                 totalSupply, tokensPerEther);
        }
    }
    event TokensBought(address indexed buyer, uint256 ethers, 
        uint256 newEtherBalance, uint256 tokens, uint256 newTotalSupply, 
        uint256 tokensPerEther);

    // ------------------------------------------------------------------------
    // Precommitment funding can be added before the funding block
    // ------------------------------------------------------------------------
    function addPrecommitment(address participant) payable onlyOwner beforeFundingPeriod {
        balances[participant] = safeAdd(balances[participant], msg.value);
        totalFunding = safeAdd(totalFunding, msg.value);
    }

    // ------------------------------------------------------------------------
    // Funding can only be added during the funding period
    // ------------------------------------------------------------------------
    function addFunding() payable duringFundingPeriod {
        // if (totalFunding < MAXIMUM_SOFT_FUNDING) {
        //     if (totalFunding + msg.value > MAXIMUM_SOFT_FUNDING) {
        //         endingBlock += HARD_CAP_PERIOD;
        //     }
        // }
        balances[msg.sender] = safeAdd(balances[msg.sender], msg.value);
        totalFunding = safeAdd(totalFunding, msg.value);
    }
    
    // ------------------------------------------------------------------------
    // Transfer out any accidentally sent ERC20 tokens
    // ------------------------------------------------------------------------
    function transferAnyERC20Token(address tokenAddress, uint256 amount) onlyOwner returns (bool success) {
        return ERC20Interface(tokenAddress).transfer(owner, amount);
    }
}