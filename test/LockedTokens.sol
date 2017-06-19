pragma solidity ^0.4.11;

// ----------------------------------------------------------------------------
// OAX 'openANX Token' crowdfunding contract - locked tokens
//
// Refer to http://openanx.org/ for further information.
//
// Enjoy. (c) openANX and BokkyPooBah / Bok Consulting Pty Ltd 2017. 
// The MIT Licence.
// ----------------------------------------------------------------------------

import "./ERC20Interface.sol";
import "./SafeMath.sol";
import "./OpenANXTokenConfig.sol";


// ----------------------------------------------------------------------------
// Contract that holds the 1Y and 2Y locked token information
// ----------------------------------------------------------------------------
contract LockedTokens is OpenANXTokenConfig {
    using SafeMath for uint;

    // ------------------------------------------------------------------------
    // 1y and 2y locked totals, not including unsold tranche1 and all tranche2
    // tokens
    // ------------------------------------------------------------------------
    uint public constant TOKENS_LOCKED_1Y_TOTAL = 14000000 * DECIMALSFACTOR;
    uint public constant TOKENS_LOCKED_2Y_TOTAL = 26000000 * DECIMALSFACTOR;
    
    // ------------------------------------------------------------------------
    // Tokens locked for 1 year for sale 2 in the following account
    // ------------------------------------------------------------------------
    address public TRANCHE2_ACCOUNT = 0xBbBB34FA53A801b5F298744490a1596438bbBe50;

    // ------------------------------------------------------------------------
    // Current totalSupply of 1y and 2y locked tokens
    // ------------------------------------------------------------------------
    uint public totalSupplyLocked1Y;
    uint public totalSupplyLocked2Y;

    // ------------------------------------------------------------------------
    // Locked tokens mapping
    // ------------------------------------------------------------------------
    mapping (address => uint) public balancesLocked1Y;
    mapping (address => uint) public balancesLocked2Y;

    // ------------------------------------------------------------------------
    // Address of openANX crowdsale token contract
    // ------------------------------------------------------------------------
    ERC20Interface public tokenContract;


    // ------------------------------------------------------------------------
    // Constructor - called by crowdsale token contract
    // ------------------------------------------------------------------------
    function LockedTokens(address _tokenContract) {
        tokenContract = ERC20Interface(_tokenContract);

        // --- 1y locked tokens ---
        // Advisors
        add1Y(0xaBBa43E7594E3B76afB157989e93c6621497FD4b, 2000000 * DECIMALSFACTOR);
        // Directors
        add1Y(0xacCa534c9f62Ab495bd986e002DdF0f054caAE4f, 2000000 * DECIMALSFACTOR);
        // Early backers
        add1Y(0xAddA9B762A00FF12711113bfDc36958B73d7F915, 2000000 * DECIMALSFACTOR);
        // Developers
        add1Y(0xaeEa63B5479B50F79583ec49DACdcf86DDEff392, 8000000 * DECIMALSFACTOR);
        // Confirm 1Y totals
        assert(totalSupplyLocked1Y == TOKENS_LOCKED_1Y_TOTAL);

        // --- 2y locked tokens ---
        // Foundation
        add2Y(0xAAAA9De1E6C564446EBCA0fd102D8Bd92093c756, 20000000 * DECIMALSFACTOR);
        // Advisors
        add2Y(0xaBBa43E7594E3B76afB157989e93c6621497FD4b, 2000000 * DECIMALSFACTOR);
        // Directors
        add2Y(0xacCa534c9f62Ab495bd986e002DdF0f054caAE4f, 2000000 * DECIMALSFACTOR);
        // Early backers
        add2Y(0xAddA9B762A00FF12711113bfDc36958B73d7F915, 2000000 * DECIMALSFACTOR);
        // Confirm 2Y totals
        assert(totalSupplyLocked2Y == TOKENS_LOCKED_2Y_TOTAL);
    }


    // ------------------------------------------------------------------------
    // Add remaining tokens to locked 1y balances
    // ------------------------------------------------------------------------
    function addRemainingTokens() {
        // Only the crowdsale contract can call this function
        require(msg.sender == address(tokenContract));
        // Total tokens to be created
        uint remainingTokens = TOKENS_TOTAL;
        // Minus precommitments and public crowdsale tokens
        remainingTokens = remainingTokens.sub(tokenContract.totalSupply());
        // Minus 1y locked tokens
        remainingTokens = remainingTokens.sub(totalSupplyLocked1Y);
        // Minus 2y locked tokens
        remainingTokens = remainingTokens.sub(totalSupplyLocked2Y);
        // Unsold tranche1 and tranche2 tokens to be locked for 1y 
        add1Y(TRANCHE2_ACCOUNT, remainingTokens);
    }


    // ------------------------------------------------------------------------
    // Add to 1y locked balances and totalSupply
    // ------------------------------------------------------------------------
    function add1Y(address account, uint value) private {
        balancesLocked1Y[account] = balancesLocked1Y[account].add(value);
        totalSupplyLocked1Y = totalSupplyLocked1Y.add(value);
    }


    // ------------------------------------------------------------------------
    // Add to 2y locked balances and totalSupply
    // ------------------------------------------------------------------------
    function add2Y(address account, uint value) private {
        balancesLocked2Y[account] = balancesLocked2Y[account].add(value);
        totalSupplyLocked2Y = totalSupplyLocked2Y.add(value);
    }


    // ------------------------------------------------------------------------
    // 1y locked balances for an account
    // ------------------------------------------------------------------------
    function balanceOfLocked1Y(address account) constant returns (uint balance) {
        return balancesLocked1Y[account];
    }


    // ------------------------------------------------------------------------
    // 2y locked balances for an account
    // ------------------------------------------------------------------------
    function balanceOfLocked2Y(address account) constant returns (uint balance) {
        return balancesLocked2Y[account];
    }


    // ------------------------------------------------------------------------
    // 1y and 2y locked balances for an account
    // ------------------------------------------------------------------------
    function balanceOfLocked(address account) constant returns (uint balance) {
        return balancesLocked1Y[account].add(balancesLocked2Y[account]);
    }


    // ------------------------------------------------------------------------
    // 1y and 2y locked total supply
    // ------------------------------------------------------------------------
    function totalSupplyLocked() constant returns (uint) {
        return totalSupplyLocked1Y + totalSupplyLocked2Y;
    }


    // ------------------------------------------------------------------------
    // An account can unlock their 1y locked tokens 1y after token launch date
    // ------------------------------------------------------------------------
    function unlock1Y() {
        require(now >= LOCKED_1Y_DATE);
        uint amount = balancesLocked1Y[msg.sender];
        require(amount > 0);
        balancesLocked1Y[msg.sender] = 0;
        totalSupplyLocked1Y = totalSupplyLocked1Y.sub(amount);
        if (!tokenContract.transfer(msg.sender, amount)) throw;
    }


    // ------------------------------------------------------------------------
    // An account can unlock their 2y locked tokens 2y after token launch date
    // ------------------------------------------------------------------------
    function unlock2Y() {
        require(now >= LOCKED_2Y_DATE);
        uint amount = balancesLocked2Y[msg.sender];
        require(amount > 0);
        balancesLocked2Y[msg.sender] = 0;
        totalSupplyLocked2Y = totalSupplyLocked2Y.sub(amount);
        if (!tokenContract.transfer(msg.sender, amount)) throw;
    }
}