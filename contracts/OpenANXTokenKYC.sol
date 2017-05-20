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


contract OpenANXTokenKYC is Owned {
    mapping(address => uint256) customerStatus;

    event KYCed(address indexed customer, uint256 status);

    function OpenANXTokenKYC() {
    }

    function kyc(address customer, uint256 status) onlyOwner {
        customerStatus[customer] = status;
        KYCed(customer, status);
    }

    function confirmTokenTransfer(address from, address to, uint256 amount) returns (bool) {
        if (customerStatus[from] == 1 && customerStatus[to] == 1) {
            return true;
        }
        return false;
    }

    function isKyc(address customer) returns (bool) {
        if (customerStatus[customer] == 1) {
            return true;
        }
        return false;
    } 
}