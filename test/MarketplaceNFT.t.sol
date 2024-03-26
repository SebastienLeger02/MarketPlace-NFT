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

    event SellOfferCreated(uint256 indexed sellOfferIdCounter);
    event SellOfferAccepted(uint256 indexed _sellOfferIdCounter);
    event SellOfferCancelled(uint256 indexed sellOfferIdCounter);
    event BuyOfferCreated(uint256 indexed buyOfferIdCounter);
    event BuyOfferAccepted(uint256 indexed _buyOfferIdCounter);
    event BuyOfferCancelled(uint256 indexed _buyOfferIdCounter);

    function setUp() public override {
        super.setUp();
        marketplaceNFT = new MarketplaceNFT("MyMarketPlaceNFT");
        nft = new ProjectFinalNFT();

        // 
        nft.mint(users.alice, 1);
        nft.mint(users.bob, 2);
        nft.mint(users.charlie,3);
        vm.startPrank(users.alice);

        assertEq(users.alice.balance , 1000 ether);
        assertEq(users.bob.balance , 1000 ether);
        assertEq(users.charlie.balance , 1000 ether);
        
    }


// _______________________________________
// --------   CreateSellOffer ------------
// _______________________________________
    function test_CreateSellOffer_Success() public {
        //deal(users.alice, 100 ether);
       //marketplaceNFT.createSellOffer(_addrNFT, _tokenId , _price, _deadline);
    
        uint256 _price = 1 ether;
        uint256 _deadline = block.timestamp + 1 hours;

        //Regroupe ou encode les variable _price et _deadline
        bytes memory data = abi.encode(_price, _deadline);

        // Controle si le counter de Id soit bien initiliser à zéro avant de commencer
        assertEq(marketplaceNFT.sellOfferIdCounter(), 0);

        // Le contrat qui créer les NFT est d'accord pour transfert le NFT avec ID 1 au contrat "MarketplaceNFT"
        nft.approve(address(marketplaceNFT),1);

        // Prépare et controle l'evenement SellOfferCreated à être emit
        vm.expectEmit(true,false,false,false);
        emit SellOfferCreated(1);
        
        // Appelle la fonction creatSellOffer() avec les arguments: 
        //  address _nftAddress,
        // uint256 _tokenId,
        // bytes calldata data
        marketplaceNFT.createSellOffer(address(nft), 1, data);

        // Vérifier que l'offre a été créée - Récupère struct Offer
        MarketplaceNFT.Offer memory createdOffer = marketplaceNFT.getSellOffer(0);
        
        // Récupère, le struct "Offer" afin de pouvoir vérifier ces élèments   
        assertEq(createdOffer.offerer, users.alice); // Vérifie si le propétaire de l'offre est "alice"
        assertEq(createdOffer.nftAddress, address(nft)); // Vérifie si le NFT est bien celui de l'offre 
        assertEq(createdOffer.tokenId, 1); // Vérifie l'ID du token
        assertEq(createdOffer.price, _price); // Vérifie le prix 
        assertEq(createdOffer.deadline, _deadline); // Vérifie la date butoire
        assertEq(createdOffer.isEnded, false); // Vérifie si l'offre n'est pas terminé
        // Vérifier que le NFT a été transféré au contrat
        assertEq(nft.ownerOf(1), address(marketplaceNFT));
        // Vérifie si le compteur c'est incrémenté de 1
        assertEq(marketplaceNFT.sellOfferIdCounter(), 1);
        
    }

    function test_CreateSellOffer_Failed() public {
        
        uint256 _price = 0 ether;
        uint256 _deadline = block.timestamp + 1 hours;

        //bytes memory encodedOffer = abi.encode(offer);
        bytes memory data = abi.encode(_price, _deadline);

        nft.approve(address(marketplaceNFT),1);

        // Test le revert si le prix est null
        vm.expectRevert(MarketplaceNFT.PriceNull.selector);
        marketplaceNFT.createSellOffer(address(nft), 1, data);

        _price = 1 ether;
        _deadline = block.timestamp;
        data = abi.encode(_price, _deadline);

        // Test le revert si la deadline est passé
        vm.expectRevert(MarketplaceNFT.DeadlinePassed.selector);
        marketplaceNFT.createSellOffer(address(nft), 1, data);

    }

// _______________________________________
// --------   getSellOffer -------------
// _______________________________________

    function test_GetSellOffer_Sucess() public {
    
        uint256 _priceAlice = 1 ether;
        uint256 _deadlineAlice = block.timestamp + 1 hours;

        //bytes memory encodedOffer = abi.encode(offer);
        bytes memory dataAlice = abi.encode(_priceAlice, _deadlineAlice);

        assertEq(marketplaceNFT.sellOfferIdCounter(), 0);

        nft.approve(address(marketplaceNFT),1);
        
        marketplaceNFT.createSellOffer(address(nft), 1, dataAlice);

        // Vérifier que l'offre a été créée - Récupère struct Offer et controler le getSellOffer id 0
        MarketplaceNFT.Offer memory createdOfferAlice = marketplaceNFT.getSellOffer(0);

        assertEq(createdOfferAlice.offerer, users.alice);
        assertEq(createdOfferAlice.nftAddress, address(nft));
        assertEq(createdOfferAlice.tokenId, 1);
        assertEq(createdOfferAlice.price, _priceAlice);
        assertEq(createdOfferAlice.deadline, _deadlineAlice);
        assertEq(createdOfferAlice.isEnded, false);
        // Vérifier que le NFT a été transféré au contrat
        assertEq(nft.ownerOf(1), address(marketplaceNFT));
        // Vérifie si le compteur c'est incrémenté de 1
        assertEq(marketplaceNFT.sellOfferIdCounter(), 1);

        //-----------------------------------------------------
        //-------------- Creationn Offer for Bob ---------

        vm.stopPrank();
        vm.startPrank(users.bob);
        
    
        uint256 _priceBob = 15 ether;
        uint256 _deadlineBob = block.timestamp + 1 hours;

        bytes memory dataBob = abi.encode(_priceBob, _deadlineBob);

        assertEq(marketplaceNFT.sellOfferIdCounter(), 1);

        nft.approve(address(marketplaceNFT),2);
        
        marketplaceNFT.createSellOffer(address(nft), 2, dataBob);

        // Vérifier que l'offre a été créée - Récupère struct Offer et controler le getSellOffer id 1
        MarketplaceNFT.Offer memory createdOfferBob = marketplaceNFT.getSellOffer(1);

        assertEq(createdOfferBob.offerer, users.bob);
        assertEq(createdOfferBob.nftAddress, address(nft));
        assertEq(createdOfferBob.tokenId, 2);
        assertEq(createdOfferBob.price, _priceBob);
        assertEq(createdOfferBob.deadline, _deadlineBob);
        assertEq(createdOfferBob.isEnded, false);
        // Vérifier que le NFT a été transféré au contrat
        assertEq(nft.ownerOf(2), address(marketplaceNFT));
        // Vérifie si le compteur c'est incrémenté de 1
        assertEq(marketplaceNFT.sellOfferIdCounter(), 2);

        //-----------------------------------------------------
        //-------------- Creationn Offer for Charlie ---------

        vm.stopPrank();
        vm.startPrank(users.charlie);
       
        uint256 _priceCharlie = 20 ether;
        uint256 _deadlineCharlie = block.timestamp + 1 hours;

        //bytes memory encodedOffer = abi.encode(offer);
        bytes memory dataCharlie = abi.encode(_priceCharlie, _deadlineCharlie);

        assertEq(marketplaceNFT.sellOfferIdCounter(), 2);

        nft.approve(address(marketplaceNFT),3);
        
        marketplaceNFT.createSellOffer(address(nft), 3, dataCharlie);

        // Vérifier que l'offre a été créée - Récupère struct Offer et controler le getSellOffer id 2
        MarketplaceNFT.Offer memory createdOfferCharlie = marketplaceNFT.getSellOffer(2);

        assertEq(createdOfferCharlie.offerer, users.charlie);
        assertEq(createdOfferCharlie.nftAddress, address(nft));
        assertEq(createdOfferCharlie.tokenId, 3);
        assertEq(createdOfferCharlie.price, _priceCharlie);
        assertEq(createdOfferCharlie.deadline, _deadlineCharlie);
        assertEq(createdOfferCharlie.isEnded, false);
        // Vérifier que le NFT a été transféré au contrat
        assertEq(nft.ownerOf(3), address(marketplaceNFT));
        // Vérifie si le compteur c'est incrémenté de 1
        assertEq(marketplaceNFT.sellOfferIdCounter(), 3);

    }

// _______________________________________
// --------   AcceptSellOffer -------------
// _______________________________________

    function test_AcceptSellOffer_Success() public {

        uint256 _price = 10 ether;
        uint256 _deadline = block.timestamp + 1 hours;

        bytes memory data = abi.encode(_price, _deadline);

        nft.approve(address(marketplaceNFT),1);
        
        marketplaceNFT.createSellOffer(address(nft), 1, data);

        // Vérification de la création de l'offre
        (address nftAddress, uint256 tokenId, address offerer, uint256 price, uint256 deadline, bool isEnded) = marketplaceNFT.sellOffers(0);
        assertEq(nftAddress, address(nft));
        assertEq(offerer, users.alice); // Vérifier le créateur de l'offre
        assertEq(tokenId, 1);
        assertEq(price, 10 ether);
        assertEq(deadline, block.timestamp + 1 hours);
        assertEq(isEnded, false); // Vérifier l'état initial "non terminée"

        // Avance rapide au-delà de la date limite
        //vm.warp(16 days); // = vm.warp(block.timestamp + 16 days);
      
        vm.stopPrank();
        vm.startPrank(users.bob);

        // Prépare et controle l'evenement SellOfferAccepted à être emit
        vm.expectEmit(true,false,false,false);
        emit SellOfferAccepted(0);
        
        // Accéptation de l'offre
        marketplaceNFT.acceptSellOffer{value: 10 ether}(0);

        // Vérification de la modification de l'état
        (nftAddress, tokenId,offerer, price, deadline, isEnded) = marketplaceNFT.sellOffers(0);
        assertEq(offerer, users.alice);
        assertEq(price, 10 ether);
        assert(deadline > block.timestamp); // La deadline ne change pas
        assertEq(isEnded, true); // Vérifier l'état final "terminée"

        // vérifie qye le nouveau owner soit Bob
        assertEq(nft.ownerOf(1), users.bob);
        // Vérifie les balance de Bob et Alice après le transfert
        assertEq(users.bob.balance, 990 ether); 
        assertEq(users.alice.balance, 1010 ether); 
    }

    function test_AcceptSellOffer_Failed() public {

        vm.stopPrank();
        vm.startPrank(users.bob);

        uint256 _price = 2 ether;
        uint256 _deadline = block.timestamp + 2 hours;

        bytes memory data = abi.encode(_price, _deadline);

        nft.approve(address(marketplaceNFT),2);
        
        marketplaceNFT.createSellOffer(address(nft), 2, data);

        // Vérification de la création de l'offre
        (address nftAddress, uint256 tokenId, address offerer, uint256 price, uint256 deadline, bool isEnded) = marketplaceNFT.sellOffers(0);
        assertEq(nftAddress, address(nft));
        assertEq(offerer, users.bob); // Vérifier le créateur de l'offre
        assertEq(tokenId, 2);
        assertEq(price, 2 ether);
        assertEq(deadline, block.timestamp + 2 hours);
        assertEq(isEnded, false); // Vérifier l'état initial "non terminée"

        // // Avance rapide au-delà de la date limite
        // //vm.warp(16 days); // = vm.warp(block.timestamp + 16 days);
      
        vm.stopPrank();
        vm.startPrank(users.alice);
        deal(users.alice, 100 ether);

        // Test le revert si le prix est null
        vm.expectRevert(MarketplaceNFT.BadPrice.selector);
        marketplaceNFT.acceptSellOffer{value: 1 ether}(0);

        // Test le revert si la deadline est dépassée
        vm.warp(3 hours);
        vm.expectRevert(MarketplaceNFT.DeadlinePassed.selector);
        marketplaceNFT.acceptSellOffer{value: 2 ether}(0);

        // Tiempo en conformidad para acceptar la offerta 
        vm.warp(1 hours);

        //Alice accepta la orden de venta
        marketplaceNFT.acceptSellOffer{value: 2 ether}(0);

        (nftAddress, tokenId,offerer, price, deadline, isEnded) = marketplaceNFT.sellOffers(0);
       
        console.log(isEnded); // = true
        // Test le revert si l'offre est terminée
        vm.expectRevert(MarketplaceNFT.OfferClosed.selector);
        marketplaceNFT.acceptSellOffer{value: 2 ether}(0);

    }

// _______________________________________
// --------   CancelSellOffer -------------
// _______________________________________

    function test_CancelSellOffer_Success() public {

        uint256 _price = 1 ether;
        uint256 _deadline = block.timestamp + 1 hours;

        bytes memory data = abi.encode(_price, _deadline);

        nft.approve(address(marketplaceNFT),1);
        
        marketplaceNFT.createSellOffer(address(nft), 1, data);

        // Vérification de la création de l'offre
        (address nftAddress, uint256 tokenId, address offerer, uint256 price, uint256 deadline, bool isEnded) = marketplaceNFT.sellOffers(0);
        assertEq(nftAddress, address(nft));
        assertEq(offerer, users.alice); 
        assertEq(tokenId, 1);
        assertEq(price, 1 ether);
        assertEq(deadline, block.timestamp + 1 hours);
        assertEq(isEnded, false); 
        
        vm.warp(block.timestamp + 2 hours);

        // Prépare et controle l'evenement SellOfferCancelled à être emit
        vm.expectEmit(true,false,false,false);
        emit SellOfferCancelled(0);

        // alice accepta orden venta
        marketplaceNFT.cancelSellOffer(0);

        // Vérifie si Alice est le owner du NFT
        assertEq(nft.ownerOf(tokenId), users.alice);

    }

    function test_CancelSellOffer_Failed() public {

        uint256 _price = 1 ether;
        uint256 _deadline = block.timestamp + 1 hours;

        bytes memory data = abi.encode(_price, _deadline);

        nft.approve(address(marketplaceNFT),1);
        
        marketplaceNFT.createSellOffer(address(nft), 1, data);

        // Vérification de la création de l'offre
        (address nftAddress, uint256 tokenId, address offerer, uint256 price, uint256 deadline, bool isEnded) = marketplaceNFT.sellOffers(0);
        assertEq(nftAddress, address(nft));
        assertEq(offerer, users.alice); // Vérifier le créateur de l'offre
        assertEq(tokenId, 1);
        assertEq(price, 1 ether);
        assertEq(deadline, block.timestamp + 1 hours);
        assertEq(isEnded, false); // Vérifier l'état initial "non terminée"

        // vérifie que deadline ne soit pas passée
        vm.warp(block.timestamp);
        vm.expectRevert(MarketplaceNFT.DeadlineNotPassed.selector);
        marketplaceNFT.cancelSellOffer(0);

        vm.stopPrank();
        vm.startPrank(users.bob);
        vm.warp(block.timestamp + 2 hours);
        // // vérifie que si Offerer n'est pas le msg.sender
        vm.expectRevert(MarketplaceNFT.NotOwner.selector);
        marketplaceNFT.cancelSellOffer(0);


        vm.stopPrank();
        vm.startPrank(users.alice);
        // alice accepta orden venta
        marketplaceNFT.cancelSellOffer(0);

        (,,,, deadline,) = marketplaceNFT.sellOffers(0);
        // Vérifie que l'offre n'est pas terminé
        console.log(isEnded);
        vm.expectRevert(MarketplaceNFT.OfferClosed.selector);
        marketplaceNFT.cancelSellOffer(0);
    }


// _______________________________________
// --------   CreatBuyOffer -------------
// _______________________________________

    function test_CreateBuyOffer_Success() public {

        vm.stopPrank();
        vm.startPrank(users.bob);

        uint256 tokenID = 1;
        
        // Vérification de l'initialisation du compteur à 0
        assertEq(marketplaceNFT.buyOfferIdCounter(), 0);

        // Prépare et controle l'evenement BuyOfferCreated à être emit
        vm.expectEmit(true,false,false,false);
        emit BuyOfferCreated(1);

        // Création d'une offre d'achat
        marketplaceNFT.createBuyOffer{value: 1 ether}(
            address(nft),
            tokenID,
            block.timestamp + 1 days
        );

        MarketplaceNFT.Offer memory createdOffer = marketplaceNFT.getBuyOffer(0);

        assertEq(createdOffer.nftAddress, address(nft));
        assertEq(createdOffer.tokenId, 1);
        assertEq(createdOffer.offerer, users.bob);
        assertEq(createdOffer.price, 1 ether);
        assertEq(createdOffer.deadline, block.timestamp + 1 days);
        assertEq(createdOffer.isEnded, false);

        assertEq(marketplaceNFT.buyOfferIdCounter(), 1);

    }

    function test_CreateBuyOffer_Failed() public {

        uint256 deadline = block.timestamp;

        //Vérifie que la deadline ne soitpas dépassé DeadlinePassed()
        vm.warp(1 days);
        vm.expectRevert(MarketplaceNFT.DeadlinePassed.selector);
        marketplaceNFT.createBuyOffer{value: 1 ether}(
            address(nft),
            1,
            deadline 
        );

        // Vérifie que l'envoie d'ether ne soit pas zero BelowZero()
        vm.expectRevert(MarketplaceNFT.BelowZero.selector);
        marketplaceNFT.createBuyOffer{value: 0 ether}(
            address(nft),
            1,
            block.timestamp
        );
    }
    
// _______________________________________
// --------   getBuyOffer -------------
// _______________________________________

    function test_GetBuyOffer_Success() public {

        vm.stopPrank();
        vm.startPrank(users.bob);

        uint256 tokenID = 1;
        
        // Vérification de l'initialisation du compteur à 0
        assertEq(marketplaceNFT.buyOfferIdCounter(), 0);

        // Création d'une offre d'achat
        marketplaceNFT.createBuyOffer{value: 1 ether}(
            address(nft),
            tokenID,
            block.timestamp + 1 days
        );

        MarketplaceNFT.Offer memory createdOffer = marketplaceNFT.getBuyOffer(0);

        assertEq(createdOffer.nftAddress, address(nft));
        assertEq(createdOffer.tokenId, 1);
        assertEq(createdOffer.offerer, users.bob);
        assertEq(createdOffer.price, 1 ether);
        assertEq(createdOffer.deadline, block.timestamp + 1 days);
        assertEq(createdOffer.isEnded, false);

        assertEq(marketplaceNFT.buyOfferIdCounter(), 1);

        //--------------------------------------------------
        // -------- Creation BuyOffer with Charlie --------

        vm.stopPrank();
        vm.startPrank(users.charlie);
    
        uint256 tokenIDCharlie = 2;

        // Vérification de l'initialisation du compteur à 0
        assertEq(marketplaceNFT.buyOfferIdCounter(), 1);

        // Création d'une offre d'achat
        marketplaceNFT.createBuyOffer{value: 2 ether}(
            address(nft),
            tokenIDCharlie,
            block.timestamp + 1 days
        );

        MarketplaceNFT.Offer memory createdOfferCharlie = marketplaceNFT.getBuyOffer(1);

        assertEq(createdOfferCharlie.nftAddress, address(nft));
        assertEq(createdOfferCharlie.tokenId, 2);
        assertEq(createdOfferCharlie.offerer, users.charlie);
        assertEq(createdOfferCharlie.price, 2 ether);
        assertEq(createdOfferCharlie.deadline, block.timestamp + 1 days);
        assertEq(createdOfferCharlie.isEnded, false);

        assertEq(marketplaceNFT.buyOfferIdCounter(), 2);
    }

    // function test_GetBuyOffer_Failed() public {
    //     uint256 tokenID = 1;
        
    //     // Vérification de l'initialisation du compteur à 0
    //     assertEq(marketplaceNFT.buyOfferIdCounter(), 0);

    //     // Création d'une offre d'achat
    //     marketplaceNFT.createBuyOffer{value: 1 ether}(
    //         address(nft),
    //         tokenID,
    //         block.timestamp + 1 days
    //     );

    //     // Vérification de l'initialisation du compteur à 1
    //     assertEq(marketplaceNFT.buyOfferIdCounter(), 1);

    //     vm.stopPrank();
    //     vm.startPrank(users.charlie);
    
    //     uint256 tokenIDCharlie = 2;

    //     // Création d'une offre d'achat
    //     marketplaceNFT.createBuyOffer{value: 2 ether}(
    //         address(nft),
    //         tokenIDCharlie,
    //         block.timestamp + 1 days
    //     );
    //     // Vérification de l'initialisation du compteur à 2
    //     assertEq(marketplaceNFT.buyOfferIdCounter(), 2);

    //     vm.expectRevert();
    //     marketplaceNFT.getBuyOffer(5);

    // }

// _______________________________________
// --------   AcceptBuyOffer -------------
// _______________________________________
    function test_AcceptBuyOffer_Success() public {
        
        vm.stopPrank();
        vm.startPrank(users.bob);

        uint256 tokenID = 1;

        //nft.approve(address(marketplaceNFT),tokenID);
        // Création d'une offre d'achat
        marketplaceNFT.createBuyOffer{value: 20 ether}(
            address(nft),
            tokenID,
            block.timestamp + 1 days
        );

        MarketplaceNFT.Offer memory createdOffer = marketplaceNFT.getBuyOffer(0);

        assertEq(createdOffer.nftAddress, address(nft));
        assertEq(createdOffer.tokenId, 1);
        assertEq(createdOffer.offerer, users.bob);
        assertEq(createdOffer.price, 20 ether);
        assertEq(createdOffer.deadline, block.timestamp + 1 days);
        assertEq(createdOffer.isEnded, false);

        assertEq(marketplaceNFT.buyOfferIdCounter(), 1);

        vm.stopPrank();
        vm.startPrank(users.alice);

        nft.approve(address(marketplaceNFT),1);

        // Prépare et controle l'evenement BuyOfferAccepted à être emit
        vm.expectEmit(true,false,false,false);
        emit BuyOfferAccepted(0);

        marketplaceNFT.acceptBuyOffer(0);
        
        // Controle si le NFT à bien été envoyer à Bob
        assertEq(nft.ownerOf(1), users.bob);

        assertEq(users.bob.balance, 980 ether); 
        assertEq(users.alice.balance, 1020 ether); 
        
    }

    function test_AcceptBuyOffer_Failed() public {

        marketplaceNFT.createBuyOffer{value: 20 ether}(
            address(nft),
            2,
            block.timestamp + 1 days
        );

        MarketplaceNFT.Offer memory createdOffer = marketplaceNFT.getBuyOffer(0);

        assertEq(createdOffer.nftAddress, address(nft));
        assertEq(createdOffer.tokenId, 2);
        assertEq(createdOffer.offerer, users.alice);
        assertEq(createdOffer.price, 20 ether);
        assertEq(createdOffer.deadline, block.timestamp + 1 days);
        assertEq(createdOffer.isEnded, false);

        // Test le revert si alice n'est pas le owner du nft
        vm.expectRevert(MarketplaceNFT.NoOwnerOfNft.selector);
        marketplaceNFT.acceptBuyOffer(0);

        vm.stopPrank();
        vm.startPrank(users.bob);

        // Test le revert si le prix est null
        vm.expectRevert(MarketplaceNFT.NoOwnerOfNft.selector);
        marketplaceNFT.acceptSellOffer{value: 20 ether}(0);

        // Test le revert si la deadline est dépassée
        vm.warp(3 hours);
        vm.expectRevert(MarketplaceNFT.DeadlinePassed.selector);
        marketplaceNFT.acceptSellOffer{value: 2 ether}(0);

        // // Tiempo en conformidad para acceptar la offerta 
        // vm.warp(1 hours);

        // //Alice accepta la orden de venta
        // marketplaceNFT.acceptSellOffer{value: 2 ether}(0);

        // (nftAddress, tokenId,offerer, price, deadline, isEnded) = marketplaceNFT.sellOffers(0);
       
        // console.log(isEnded); // = true
        // // Test le revert si l'offre est terminée
        // vm.expectRevert(MarketplaceNFT.OfferClosed.selector);
        // marketplaceNFT.acceptSellOffer{value: 2 ether}(0);

        

        // uint256 _deadline = block.timestamp;
        // vm.warp(2 days);
        // // Test le revert si la deadline est passé
        // vm.expectRevert(MarketplaceNFT.DeadlinePassed.selector);
        // marketplaceNFT.createBuyOffer{value: 20 ether}(
        //     address(nft),
        //     1,
        //    _deadline
        // );

    }


// _______________________________________
// --------   CancelBuyOffer -------------
// _______________________________________

    function test_CancelBuyOffer_Success() public {
        
        uint256 tokenID = 1;
        uint256 balanceAlice = users.alice.balance;

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

        // Controle si le balance d'Alice changer après la création de l'offre
        assertEq(balanceAlice - price, users.alice.balance);
        uint256 newBalanceAlice = users.alice.balance;

        // Prépare et controle l'evenement BuyOfferCancelled à être emit
        vm.expectEmit(true,false,false,false);
        emit BuyOfferCancelled(0);
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

        assertEq(newBalanceAlice + price, users.alice.balance);

    }

    function test_CancelBuyOffer_Failed() public {

        vm.stopPrank();
        vm.startPrank(users.bob);

        uint256 tokenID = 2;
        uint256 balanceBob = users.bob.balance;

        assertEq(marketplaceNFT.buyOfferIdCounter(), 0);

        // Création d'une offre d'achat
        marketplaceNFT.createBuyOffer{value: 1 ether}(
            address(nft),
            tokenID,
            block.timestamp + 15 days
        );

        // Vérification de la création de l'offre
        (, , address offerer, uint256 price, uint256 deadline, bool isEnded) = marketplaceNFT.buyOffers(0);
        assertEq(offerer, users.bob); // Vérifier le créateur de l'offre
        assertEq(price, 1 ether);
        assertEq(deadline, block.timestamp + 15 days);
        assertEq(isEnded, false); // Vérifier l'état initial "non terminée"

        assertEq(balanceBob - price, users.bob.balance);
        uint256 newBalanceBob = users.bob.balance;

        assertEq(marketplaceNFT.buyOfferIdCounter(), 1);

        // Vérifie si deadline n'est pas dépassé DeadlineNotPassed() 
        vm.warp(1 days);
        vm.expectRevert(MarketplaceNFT.DeadlineNotPassed.selector);
        marketplaceNFT.cancelBuyOffer(0);

        vm.warp(16 days);

        //Vérifie l'owner de l'offre, renvoit erreur si no, NotOwner() 
        vm.stopPrank();
        vm.startPrank(users.alice);
        vm.expectRevert(MarketplaceNFT.NotOwner.selector);
        marketplaceNFT.cancelBuyOffer(0);

        // Vérifie si l'offre est terminée OfferClosed() 
        vm.stopPrank();
        vm.startPrank(users.bob);
        marketplaceNFT.cancelBuyOffer(0);

        vm.expectRevert(MarketplaceNFT.OfferClosed.selector);
        marketplaceNFT.cancelBuyOffer(0);

    }


     ////////////////// NFT IMAGE
    function testURI() public {
        nft.setBaseURI("https://gray-rainy-lemur-842.mypinata.cloud/ipfs/QmZHMMnGhED5ctPuUzpvLQxt4sDnqC1Z4XFngQ5CzZzNbE/");
        console.logString(nft.tokenURI(1));
    }

}
