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
    function confirmTokenTransfer(address from, address to, uint256 amount) onlyOwner returns (bool);
}


// ERC Token Standard #20 Interface - https://github.com/ethereum/EIPs/issues/20
contract ERC20Interface {
    function totalSupply() constant returns (uint256 totalSupply);
    function balanceOf(address _owner) constant returns (uint256 balance);
    function transfer(address _to, uint256 _value) returns (bool success);
    function transferFrom(address _from, address _to, uint256 _value) returns (bool success);
    function approve(address _spender, uint256 _value) returns (bool success);
    function allowance(address _owner, address _spender) constant returns (uint256 remaining);
    event Transfer(address indexed _from, address indexed _to, uint256 _value);
    event Approval(address indexed _owner, address indexed _spender, uint256 _value);
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
// ERC Token Standard #20 - https://github.com/ethereum/EIPs/issues/20
// With the addition of symbol, name and decimals
// ----------------------------------------------------------------------------
contract ERC20Token is ERC20Interface {
    string public symbol;
    string public name;
    uint8 public decimals;

    // ------------------------------------------------------------------------
    // Total token supply
    // ------------------------------------------------------------------------
    uint256 public totalSupply;
    
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
    ) {
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
        if (balances[msg.sender] >= _amount
            && _amount > 0
            && balances[_to] + _amount > balances[_to]) {
            balances[msg.sender] -= _amount;
            balances[_to] += _amount;
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
        if (balances[_from] >= _amount
            && allowed[_from][msg.sender] >= _amount
            && _amount > 0
            && balances[_to] + _amount > balances[_to]) {
            balances[_from] -= _amount;
            allowed[_from][msg.sender] -= _amount;
            balances[_to] += _amount;
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

    // ------------------------------------------------------------------------
    // Don't accept ethers
    // ------------------------------------------------------------------------
    function () {
        throw;
    }

    event Transfer(address indexed _from, address indexed _to, uint256 _value);
    event Approval(address indexed _owner, address indexed _spender, uint256 _value);
}


// ----------------------------------------------------------------------------
// ERC Token Standard #20 - https://github.com/ethereum/EIPs/issues/20
// With the addition of symbol, name and decimals
// ----------------------------------------------------------------------------
contract OpenANXToken {

    uint256 public constant MINIMUM_FUNDING = 123;
    uint256 public constant MAXIMUM_SOFT_FUNDING = 345;
    uint256 public totalFunding;

    uint256 public startingBlock;
    uint256 public endingBlock;


    // ------------------------------------------------------------------------
    // Only before the funding period
    // ------------------------------------------------------------------------
    modified beforeFundingPeriod() {
        if (blockNumber >= startingBlock) throw;
        _;
    }

    // ------------------------------------------------------------------------
    // Only during the funding period
    // ------------------------------------------------------------------------
    modified duringFundingPeriod() {
        if (blockNumber < startingBlock || blockNumber > endingBlock) throw;
        _;
    }


    // ------------------------------------------------------------------------
    // Constructor
    // ------------------------------------------------------------------------
    function SuperDEXICOToken(uint256 _startingBlock, uint256 _endingBlock) {
        startingBlock = _startingBlock;
        endingBlock = _endingBlock;
    }

    // ------------------------------------------------------------------------
    // Precommitment funding can be added before the funding block
    // ------------------------------------------------------------------------
    function addPrecommitment(address participant) onlyOwner beforeFundingPeriod {
        balances[participant] += msg.value;
        totalFunding += msg.value;
    }

    // ------------------------------------------------------------------------
    // Funding can only be added during the funding period
    // ------------------------------------------------------------------------
    function addFunding() duringFundingPeriod {
        if (totalFunding < MAXIMUM_SOFT_FUNDING) {
            if (totalFunding + msg.value > MAXIMUM_SOFT_FUNDING) {
                endingBlock += HARD_CAP_PERIOD;
            }
        }
        balances[participant] += msg.value;
        totalFunding += msg.value;
    }


}