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

    // ------------------------------------------------------------------------
    // Token symbol(), name() and decimals()
    // ------------------------------------------------------------------------
    string public constant SYMBOL = "OAX";
    string public constant NAME = "openANX Token";
    uint8 public constant DECIMALS = 18;


    // ------------------------------------------------------------------------
    // Decimal factor for multiplications from OAX unit to OAX natural unit
    // ------------------------------------------------------------------------
    uint public constant DECIMALSFACTOR = 10**uint(DECIMALS);

    // ------------------------------------------------------------------------
    // Tranche 1 soft cap and hard cap, and total tokens
    // ------------------------------------------------------------------------
    uint public constant TOKENS_SOFT_CAP = 13000000 * DECIMALSFACTOR;
    uint public constant TOKENS_HARD_CAP = 30000000 * DECIMALSFACTOR;
    uint public constant TOKENS_TOTAL = 100000000 * DECIMALSFACTOR;

    // ------------------------------------------------------------------------
    // Tranche 1 crowdsale start date and end date
    // Do not use the `now` function here
    // Start - Thursday, 22-Jun-17 13:00:00 UTC / 1pm GMT 22 June 2017
    // End - Saturday, 22-Jul-17 13:00:00 UTC / 1pm GMT 22 July 2017 
    // ------------------------------------------------------------------------
    uint public constant START_DATE = 1497628323; // Fri 16 Jun 2017 15:52:03 UTC
    uint public constant END_DATE = 1497628433; // Fri 16 Jun 2017 15:53:53 UTC

    // ------------------------------------------------------------------------
    // 1 year and 2 year dates for locked tokens
    // Do not use the `now` function here 
    // ------------------------------------------------------------------------
    uint public constant LOCKED_1Y_DATE = START_DATE + 3 minutes;
    uint public constant LOCKED_2Y_DATE = START_DATE + 4 minutes;

    // ------------------------------------------------------------------------
    // Individual transaction contribution min and max amounts
    // Set to 0 to switch off, or `x ether`
    // ------------------------------------------------------------------------
    uint public CONTRIBUTIONS_MIN = 0 ether;
    uint public CONTRIBUTIONS_MAX = 0 ether;
}