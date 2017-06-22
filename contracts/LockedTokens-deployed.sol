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
    address public TRANCHE2_ACCOUNT = 0x813703Eb676f3B6C76dA75cBa0cbC49DdbCA7B37;

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

        // Confirm 1Y totals        
        add1Y(0x4beE088efDBCC610EEEa101ded7204150AF1C8b9,1000000 * DECIMALSFACTOR);
        add1Y(0x839551201f866907Eb5017bE79cEB48aDa58650c,925000 * DECIMALSFACTOR);
        add1Y(0xa92d4Cd3412862386c234Be572Fe4A8FA4BB09c6,925000 * DECIMALSFACTOR);
        add1Y(0xECf2B5fce33007E5669D63de39a4c663e56958dD,925000 * DECIMALSFACTOR);
        add1Y(0xD6B7695bc74E2C950eb953316359Eab283C5Bda8,925000 * DECIMALSFACTOR);
        add1Y(0xBE3463Eae26398D55a7118683079264BcF3ab24B,150000 * DECIMALSFACTOR);
        add1Y(0xf47428Fb9A61c9f3312cB035AEE049FBa76ba62a,150000 * DECIMALSFACTOR);
        add1Y(0xfCcc77165D822Ef9004714d829bDC267C743658a,50000 * DECIMALSFACTOR);
        add1Y(0xaf8df2aCAec3d5d92dE42a6c19d7706A4F3E8D8b,50000 * DECIMALSFACTOR);
        add1Y(0x22a6f9693856374BF2922cd837d07F6670E7FA4d,250000 * DECIMALSFACTOR);
        add1Y(0x3F720Ca8FfF598F00a51DE32A8Cb58Ca73f22aDe,50000 * DECIMALSFACTOR);
        add1Y(0xBd0D1954B301E414F0b5D0827A69EC5dD559e50B,50000 * DECIMALSFACTOR);
        add1Y(0x2ad6B011FEcDE830c9cc4dc0d0b77F055D6b5990,50000 * DECIMALSFACTOR);
        add1Y(0x0c5cD0E971cA18a0F0E0d581f4B93FaD31D608B0,2000085 * DECIMALSFACTOR);
        add1Y(0xFaaDC4d80Eaf430Ab604337CB67d77eC763D3e23,200248 * DECIMALSFACTOR);
        add1Y(0xDAef46f89c264182Cd87Ce93B620B63c7AfB14f7,1616920 * DECIMALSFACTOR);
        add1Y(0x19cc59C30cE54706633dC29EdEbAE1efF1757b25,224980 * DECIMALSFACTOR);
        add1Y(0xa130fE5D399104CA5AF168fbbBBe19F95d739741,745918 * DECIMALSFACTOR);
        add1Y(0xC0cD1bf6F2939095a56B0DFa085Ba2886b84E7d1,745918 * DECIMALSFACTOR);
        add1Y(0xf2C26e79eD264B0E3e5A5DFb1Dd91EA61f512C6e,745918 * DECIMALSFACTOR);
        add1Y(0x5F876a8A5F1B66fbf3D0D119075b62aF4386e319,745918 * DECIMALSFACTOR);
        add1Y(0xb8E046570800Dd76720aF6d42d3cCae451F54f15,745920 * DECIMALSFACTOR);
        add1Y(0xA524fa65Aac4647fa7bA2c20D22F64450c351bBd,714286 * DECIMALSFACTOR);
        add1Y(0x27209b276C15a936BCE08D7D70f0c97aeb3CE8c3,13889 * DECIMALSFACTOR);

        assert(totalSupplyLocked1Y == TOKENS_LOCKED_1Y_TOTAL);

        // --- 2y locked tokens ---
        add2Y(0x4beE088efDBCC610EEEa101ded7204150AF1C8b9,1000000 * DECIMALSFACTOR);
        add2Y(0x839551201f866907Eb5017bE79cEB48aDa58650c,925000 * DECIMALSFACTOR);
        add2Y(0xa92d4Cd3412862386c234Be572Fe4A8FA4BB09c6,925000 * DECIMALSFACTOR);
        add2Y(0xECf2B5fce33007E5669D63de39a4c663e56958dD,925000 * DECIMALSFACTOR);
        add2Y(0xD6B7695bc74E2C950eb953316359Eab283C5Bda8,925000 * DECIMALSFACTOR);
        add2Y(0xBE3463Eae26398D55a7118683079264BcF3ab24B,150000 * DECIMALSFACTOR);
        add2Y(0xf47428Fb9A61c9f3312cB035AEE049FBa76ba62a,150000 * DECIMALSFACTOR);
        add2Y(0xfCcc77165D822Ef9004714d829bDC267C743658a,50000 * DECIMALSFACTOR);
        add2Y(0xDAef46f89c264182Cd87Ce93B620B63c7AfB14f7,500000 * DECIMALSFACTOR);
        add2Y(0xaf8df2aCAec3d5d92dE42a6c19d7706A4F3E8D8b,50000 * DECIMALSFACTOR);
        add2Y(0x22a6f9693856374BF2922cd837d07F6670E7FA4d,250000 * DECIMALSFACTOR);
        add2Y(0x3F720Ca8FfF598F00a51DE32A8Cb58Ca73f22aDe,50000 * DECIMALSFACTOR);
        add2Y(0xBd0D1954B301E414F0b5D0827A69EC5dD559e50B,50000 * DECIMALSFACTOR);
        add2Y(0x2ad6B011FEcDE830c9cc4dc0d0b77F055D6b5990,50000 * DECIMALSFACTOR);

        //treasury
        add2Y(0x990a2D172398007fcbd5078D84696BdD8cCDf7b2,20000000 * DECIMALSFACTOR);

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