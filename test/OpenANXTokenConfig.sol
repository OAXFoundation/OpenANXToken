pragma solidity ^0.4.11;

// ----------------------------------------------------------------------------
// OAX 'openANX Token' crowdfunding contract - Configuration
//
// Refer to http://openanx.org/ for further information.
//
// Enjoy. (c) openANX and BokkyPooBah / Bok Consulting Pty Ltd 2017. 
// The MIT Licence.
// ----------------------------------------------------------------------------

// ----------------------------------------------------------------------------
// openANX crowdsale token smart contract - configuration parameters
// ----------------------------------------------------------------------------
contract OpenANXTokenConfig {

    string public constant SYMBOL = "OAX";
    string public constant NAME = "openANX Token";
    uint8 public constant DECIMALS = 18;

    uint public constant TOKENS_SOFT_CAP = 13000000;
    uint public constant TOKENS_HARD_CAP = 30000000;
    uint public constant TOKENS_TOTAL = 100000000;

    // Thursday, 22-Jun-17 13:00:00 UTC / 1pm GMT 22 June 2017. Do not use `now`
    uint public constant START_DATE = 1497239052; // Mon 12 Jun 2017 03:44:12 UTC

    // Saturday, 22-Jul-17 13:00:00 UTC / 1pm GMT 22 July 2017. Do not use `now`
    uint public constant END_DATE = 1497239292; // Mon 12 Jun 2017 03:48:12 UTC

    // Friday, 22-Jun-18 00:00:00 UTC. Do not use `now` + x
    uint public constant DATE_1Y = START_DATE + 365 days;

    // Saturday, 22-Jun-19 00:00:00 UTC. Do not use `now` + x
    uint public constant DATE_2Y = START_DATE + 2 * 365 days;


    // Set to 0 for no minimum contribution amount
    uint public CONTRIBUTIONS_MIN = 0 ether;
    // Set to 0 for no maximum contribution amount, or e.g. `250 ether`
    uint public CONTRIBUTIONS_MAX = 0 ether;

    // Decimal factor for multiplications
    uint DECIMALSFACTOR = 10**uint(DECIMALS);
}