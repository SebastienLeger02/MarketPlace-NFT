// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

import "forge-std/Test.sol";
import "./BaseTest.t.sol";
import "../src/MarketplaceNFT.sol";

contract TestMarketplaceNFT is BaseTest {
    MarketplaceNFT public marketplaceNFT;

    function setUp() public override {
        super.setUp();
        marketplaceNFT = new MarketplaceNFT("MyMarketPlaceNFT");
        
    }

}
