pragma solidity ^0.4.10;
// ----------------------------------------------------------------------------
// OpenANX Token with crowdfunding
//
// 
//
// Enjoy. (c) OpenANX and BokkyPooBah / Bok Consulting Pty Ltd 2017. 
// The MIT Licence.
// ----------------------------------------------------------------------------

import "./OpenANXToken.sol";

contract LockedTokens {

    // Locked totals
    uint256 constant LOCKED_TOTAL_1Y = 14000000;
    uint256 constant LOCKED_TOTAL_2Y = 26000000;

    // Thursday, 22-Jun-17 00:00:00 UTC. Do not use `now` + x
    uint256 public constant START_DATE = 1498089600;

    // Friday, 22-Jun-18 00:00:00 UTC. Do not use `now` + x
    uint256 public constant DATE_1Y = 1529625600;

    // Saturday, 22-Jun-19 00:00:00 UTC. Do not use `now` + x
    uint256 public constant DATE_2Y = 1561161600;

    // Locked tokens mapping
    mapping (address => uint256) locked1Y;
    mapping (address => uint256) locked2Y;

    OpenANXToken tokenContract;

    function LockedTokens(address _tokenContract) {
        tokenContract = OpenANXToken(_tokenContract);

        // --- 1 Year ---
        // Advisors
        locked1Y[0xA88A05d2b88283ce84C8325760B72a64591279a2] = 2000000;
        // Directors
        locked1Y[0xa99A0Ae3354c06B1459fd441a32a3F71005D7Da0] = 2000000;
        // Early backers
        locked1Y[0xAAAA9De1E6C564446EBCA0fd102D8Bd92093c756] = 2000000;
        // Developers
        locked1Y[0xaBBa43E7594E3B76afB157989e93c6621497FD4b] = 8000000;

        // --- 2 Years ---
        // Foundation
        locked2Y[0xa77A2b9D4B1c010A22A7c565Dc418cef683DbceC] = 20000000;
        // Advisors
        locked2Y[0xA88A05d2b88283ce84C8325760B72a64591279a2] = 2000000;
        // Directors
        locked2Y[0xa99A0Ae3354c06B1459fd441a32a3F71005D7Da0] = 2000000;
        // Early backers
        locked2Y[0xAAAA9De1E6C564446EBCA0fd102D8Bd92093c756] = 2000000;
    }

    function unlock1Y() {
        if (now < DATE_1Y) throw;
        uint256 amount = locked1Y[msg.sender];
        if (amount == 0) throw;
        uint256 decimals = uint256(tokenContract.decimals());
        uint256 factor = 10**decimals;
        locked1Y[msg.sender] = 0;
        if (!tokenContract.transfer(msg.sender, amount * factor)) throw;
    }

    function unlock2Y() {
        if (now < DATE_2Y) throw;
        uint256 amount = locked2Y[msg.sender];
        if (amount == 0) throw;
        uint256 decimals = uint256(tokenContract.decimals());
        uint256 factor = 10**decimals;
        locked2Y[msg.sender] = 0;
        if (!tokenContract.transfer(msg.sender, amount * factor)) throw;
    }
}