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

// ----------------------------------------------------------------------------
// OpenANX Interface
// ----------------------------------------------------------------------------
contract OpenANXInterface is ERC20Interface {
    function decimals() constant returns (uint8);
    // function TOKENS_TOTAL() constant returns (uint);
    uint public constant TOKENS_TOTAL = 100000000;
}

contract LockedTokens {

    // Thursday, 22-Jun-17 00:00:00 UTC. Do not use `now` + x
    uint public constant START_DATE = 1498089600;

    // Friday, 22-Jun-18 00:00:00 UTC. Do not use `now` + x
    uint public constant DATE_1Y = 1529625600;

    // Saturday, 22-Jun-19 00:00:00 UTC. Do not use `now` + x
    uint public constant DATE_2Y = 1561161600;

    // Locked totals
    uint constant LOCKED_TOTAL_1Y = 14000000;
    uint constant LOCKED_TOTAL_2Y = 26000000;

    uint public totalSupplyLocked1Y;
    uint public totalSupplyLocked2Y;

    // Locked tokens mapping
    mapping (address => uint) public balancesLocked1Y;
    mapping (address => uint) public balancesLocked2Y;

    OpenANXInterface public tokenContract;

    function LockedTokens(address _tokenContract) {
        tokenContract = OpenANXInterface(_tokenContract);
        uint decimalsFactor = 10**uint(tokenContract.decimals());

        // --- 1 Year ---
        // Advisors
        add1Y(0xA88A05d2b88283ce84C8325760B72a64591279a2, 2000000 * decimalsFactor);
        // Directors
        add1Y(0xa99A0Ae3354c06B1459fd441a32a3F71005D7Da0, 2000000 * decimalsFactor);
        // Early backers
        add1Y(0xAAAA9De1E6C564446EBCA0fd102D8Bd92093c756, 2000000 * decimalsFactor);
        // Developers
        add1Y(0xaBBa43E7594E3B76afB157989e93c6621497FD4b, 8000000 * decimalsFactor);
        // Confirm 1Y totals
        assert(totalSupplyLocked1Y == LOCKED_TOTAL_1Y * decimalsFactor);

        // --- 2 Years ---
        // Foundation
        add2Y(0xa77A2b9D4B1c010A22A7c565Dc418cef683DbceC, 20000000 * decimalsFactor);
        // Advisors
        add2Y(0xA88A05d2b88283ce84C8325760B72a64591279a2, 2000000 * decimalsFactor);
        // Directors
        add2Y(0xa99A0Ae3354c06B1459fd441a32a3F71005D7Da0, 2000000 * decimalsFactor);
        // Early backers
        add2Y(0xAAAA9De1E6C564446EBCA0fd102D8Bd92093c756, 2000000 * decimalsFactor);
        // Confirm 2Y totals
        assert(totalSupplyLocked2Y == LOCKED_TOTAL_2Y * decimalsFactor);

        uint remainingTokens = tokenContract.TOKENS_TOTAL() * decimalsFactor
            - tokenContract.totalSupply()
            - totalSupplyLocked1Y
            - totalSupplyLocked2Y;
        add1Y(_tokenContract, remainingTokens);
    }

    function add1Y(address account, uint value) private {
        balancesLocked1Y[account] += value;
        totalSupplyLocked1Y += value;
    }

    function add2Y(address account, uint value) private {
        balancesLocked2Y[account] += value;
        totalSupplyLocked2Y += value;
    }

    function balanceOfLocked1Y(address account) constant returns (uint balance) {
        return balancesLocked1Y[account];
    }

    function balanceOfLocked2Y(address account) constant returns (uint balance) {
        return balancesLocked2Y[account];
    }

    function totalSupplyLocked() constant returns (uint) {
        return totalSupplyLocked1Y + totalSupplyLocked2Y;
    }

    function unlock1Y() {
        if (now < DATE_1Y) throw;
        uint amount = balancesLocked1Y[msg.sender];
        if (amount == 0) throw;
        balancesLocked1Y[msg.sender] = 0;
        if (!tokenContract.transfer(msg.sender, amount)) throw;
    }

    function unlock2Y() {
        if (now < DATE_2Y) throw;
        uint amount = balancesLocked2Y[msg.sender];
        if (amount == 0) throw;
        balancesLocked2Y[msg.sender] = 0;
        if (!tokenContract.transfer(msg.sender, amount)) throw;
    }
}