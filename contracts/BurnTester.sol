pragma solidity ^0.4.11;

// ----------------------------------------------------------------------------
// OAX 'openANX Token' crowdfunding contract - Burn function tester
//
// Refer to http://openanx.org/ for further information.
//
// Enjoy. (c) openANX and BokkyPooBah / Bok Consulting Pty Ltd 2017. 
// The MIT Licence.
// ----------------------------------------------------------------------------

contract OpenANXToken {
    function burn(address participant, uint256 _amount) returns (bool success);
}

contract BurnTester {

    event TestBurn(bool status);
    
    function testBurn(address openANXToken, address participant, uint256 amount) {
        bool status = OpenANXToken(openANXToken).burn(participant, amount);
        TestBurn(status);
    }
}
