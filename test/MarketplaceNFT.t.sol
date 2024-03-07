// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

import {Test,console} from "forge-std/Test.sol";
import "./BaseTest.t.sol";
import "../src/MarketplaceNFT.sol";
import "../src/MyNFT.sol";
import "../src/ProjectFinalNFT.sol";

contract TestMarketplaceNFT is BaseTest {

    MarketplaceNFT public marketplaceNFT;
    ProjectFinalNFT public nft;

    function setUp() public override {
        super.setUp();
        marketplaceNFT = new MarketplaceNFT("MyMarketPlaceNFT");
        nft = new ProjectFinalNFT();

        nft.mint(users.alice, 1);
        nft.mint(users.bob, 2);
        vm.startPrank(users.alice);
        deal(users.alice, 100 ether);

        assertEq(users.alice.balance , 100 ether);
        
        //marketplaceNFT.createSellOffer(address(nft), 1 , 2 ether, 1739094596);
    }

// _______________________________________
// --------   CreateSellOffer ------------
// _______________________________________
    function test_CreateSellOffer_Success() public {
            
       //marketplaceNFT.createSellOffer(_addrNFT, _tokenId , _price, _deadline);
    
        uint256 _price = 1 ether;
        uint256 _deadline = block.timestamp + 1 hours;

        //bytes memory encodedOffer = abi.encode(offer);
        bytes memory data = abi.encode(_price, _deadline);
        
        marketplaceNFT.createSellOffer(address(nft), users.alice, 1, data);

        // Vérifier que l'offre a été créée - Récupère struct Offer
        MarketplaceNFT.Offer memory createdOffer = marketplaceNFT.getSellOffer(0);

        assertEq(createdOffer.offerer, users.alice);
        assertEq(createdOffer.nftAddress, address(nft));
        assertEq(createdOffer.tokenId, 1);
        assertEq(createdOffer.price, _price);
        assertEq(createdOffer.deadline, _deadline);
        assertEq(createdOffer.isEnded, false);
    // // Vérifier que le NFT a été transféré au contrat
    //     assertEq(nft.ownerOf(1), address(marketplaceNFT));
        
    }

    function test_CreateSellOffer_Failed() public {
        uint256 _price = 1 ether;
        uint256 _deadline = block.timestamp + 1 hours;
         bytes memory data = abi.encode(_price, _deadline);

        vm.stopPrank();
        vm.startPrank(users.bob);
        vm.expectRevert();
        marketplaceNFT.createSellOffer(address(nft), users.alice, 1, data);
    }

// _______________________________________
// --------   AcceptSellOffer -------------
// _______________________________________

    function test_AcceptSellOffer_Success() public {
        vm.stopPrank();
        vm.startPrank(users.alice);
        deal(users.alice, 100 ether);

        uint256 _price = 1 ether;
        uint256 _deadline = block.timestamp + 1 hours;

        bytes memory data = abi.encode(_price, _deadline);

        nft.approve(address(marketplaceNFT),1);
        
        marketplaceNFT.createSellOffer(address(nft), users.alice, 1, data);

        // Vérification de la création de l'offre
        (address nftAddress, uint256 tokenId, address offerer, uint256 price, uint256 deadline, bool isEnded) = marketplaceNFT.sellOffers(0);
        assertEq(nftAddress, address(nft));
        assertEq(offerer, users.alice); // Vérifier le créateur de l'offre
        assertEq(tokenId, 1);
        assertEq(price, 1 ether);
        assertEq(deadline, block.timestamp + 1 hours);
        assertEq(isEnded, false); // Vérifier l'état initial "non terminée"

        // Avance rapide au-delà de la date limite
        //vm.warp(16 days); // = vm.warp(block.timestamp + 16 days);
      

        // vm.stopPrank();
        // vm.startPrank(users.bob);
        //deal(users.bob, 100 ether);
        
        // Annulation de l'offre
        marketplaceNFT.acceptSellOffer{value: 1 ether}(0);

        // Vérification de la modification de l'état
    //     (nftAddress, tokenId,offerer, price, deadline, isEnded) = marketplaceNFT.sellOffers(0);
    //     assertEq(offerer, users.alice);
    //     assertEq(price, 1 ether);
    //     assert(deadline > block.timestamp); // La deadline ne change pas
    //     assertEq(isEnded, false); // Vérifier l'état final "terminée"
    // 
}

// _______________________________________
// --------   CreatBuyOffer -------------
// _______________________________________

    function test_CreatBuyOffer_Succes() public {
        vm.stopPrank();
        vm.startPrank(users.bob);
        deal(users.bob, 100 ether);
        
        uint256 tokenID = 1;
    // Vérification de l'initialisation du compteur à 0
        assertEq(marketplaceNFT.buyOfferIdCounter(), 0);

    // Création d'une offre d'achat
        marketplaceNFT.createBuyOffer{value: 1 ether}(
            address(nft),
            tokenID,
            block.timestamp + 7 days
        );

        MarketplaceNFT.Offer memory createdOffer = marketplaceNFT.getBuyOffer(0);

        assertEq(createdOffer.nftAddress, address(nft));
        assertEq(createdOffer.tokenId, 1);
        assertEq(createdOffer.offerer, users.bob);
        assertEq(createdOffer.price, 1 ether);
        assertEq(createdOffer.deadline, block.timestamp + 7 days);
        assertEq(createdOffer.isEnded, false);

        assertEq(marketplaceNFT.buyOfferIdCounter(), 1);

    }

    function test_CreatBuyOffer_Failed() public {

        vm.stopPrank();
        vm.startPrank(users.bob);

        // Renvoie l'erreur DeadlinePassed()
        uint256 deadline = block.timestamp;
        vm.warp(1 days);
        vm.expectRevert();
        marketplaceNFT.createBuyOffer{value: 1 ether}(
            address(nft),
            1,
            deadline 
        );

        // Renvoie l'erreur BelowZero()
        vm.expectRevert();
        marketplaceNFT.createBuyOffer(
            address(nft),
            1,
            block.timestamp
        );
    }
    

//__________________________________________

     function test_CancelBuyOffer_Success() public {
        vm.stopPrank();
        vm.startPrank(users.alice);
        deal(users.alice, 100 ether);
        console.log(users.alice.balance);
        
        uint256 tokenID = 1;
    // Création d'une offre d'achat
    marketplaceNFT.createBuyOffer{value: 1 ether}(
        address(nft),
        tokenID,
        block.timestamp + 15 days
    );

    // Vérification de la création de l'offre
    (, , address offerer, uint256 price, uint256 deadline, bool isEnded) = marketplaceNFT.buyOffers(0);
    assertEq(offerer, users.alice); // Vérifier le créateur de l'offre
    assertEq(price, 1 ether);
    assertEq(deadline, block.timestamp + 15 days);
    assertEq(isEnded, false); // Vérifier l'état initial "non terminée"

    // Avance rapide au-delà de la date limite
    vm.warp(16 days); // = vm.warp(block.timestamp + 16 days);
    // Annulation de l'offre
    marketplaceNFT.cancelBuyOffer(0);

    // Vérification de la modification de l'état
    (,,offerer, price, deadline, isEnded) = marketplaceNFT.buyOffers(0);
    assertEq(offerer, users.alice);
    assertEq(price, 1 ether);
    assert(deadline < block.timestamp); // La deadline ne change pas
    assertEq(isEnded, true); // Vérifier l'état final "terminée"
}




     ////////////////// NFT IMAGE

    function testURI() public {
        nft.setBaseURI("https://gray-rainy-lemur-842.mypinata.cloud/ipfs/QmZHMMnGhED5ctPuUzpvLQxt4sDnqC1Z4XFngQ5CzZzNbE/");
        console.logString(nft.tokenURI(1));
    }

}
