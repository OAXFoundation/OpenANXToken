pragma solidity ^0.4.10;
// ----------------------------------------------------------------------------
// OpenANX Token with crowdfunding
//
// 
//
// Enjoy. (c) OpenANX and BokkyPooBah / Bok Consulting Pty Ltd 2017. 
// The MIT Licence.
// ----------------------------------------------------------------------------

// ----------------------------------------------------------------------------
// Safe maths
// ----------------------------------------------------------------------------
contract SafeMath {
    function safeAdd(uint256 a, uint256 b) internal returns (uint256) {
        uint256 c = a + b;
        if (c < a || c < b) throw;
        return c;
    }

    function safeSub(uint256 a, uint256 b) internal returns (uint256) {
        uint256 c = a - b;
        if (c > a) throw;
        return c;
    }
}