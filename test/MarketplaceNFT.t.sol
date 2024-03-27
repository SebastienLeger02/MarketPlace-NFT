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
        // Creation of new instances of "MarketplaceNFT" and ProjectFinalNFT
        marketplaceNFT = new MarketplaceNFT("MyMarketPlaceNFT");
        nft = new ProjectFinalNFT();

        // Distribution of dummy NFT to different roles
        nft.mint(users.alice, 1);
        nft.mint(users.bob, 2);
        nft.mint(users.charlie,3);
        vm.startPrank(users.alice);
        
        // Ether distribution takes place in Utilities.sol
    }


// _______________________________________
// --------   CreateSellOffer ------------
// _______________________________________
    function test_CreateSellOffer_Success() public {
    
        uint256 _price = 1 ether;
        uint256 _deadline = block.timestamp + 1 hours;

        //Groups or encodes _price and _deadline variables
        bytes memory data = abi.encode(_price, _deadline);

        // Check that the Id counter is set to zero before starting.
        assertEq(marketplaceNFT.sellOfferIdCounter(), 0);

        // The contract creating the NFT agrees to transfer the NFT with ID 1 to the "MarketplaceNFT" contract.
        nft.approve(address(marketplaceNFT),1);

        // Prepares and controls the SellOfferCreated event to be issued
        vm.expectEmit(true,false,false,false);
        emit SellOfferCreated(1);
        
        // Calls the creatSellOffer() function with the arguments: 
        // address _nftAddress,
        // uint256 _tokenId,
        // bytes calldata data
        marketplaceNFT.createSellOffer(address(nft), 1, data);

        // Check that the offer has been created - Retrieve struct Offer
        MarketplaceNFT.Offer memory createdOffer = marketplaceNFT.getSellOffer(0);
        
        // Retrieve the struct "Offer" in order to verify these elements   
        assertEq(createdOffer.offerer, users.alice); // Check if the owner of the offer is "alice".
        assertEq(createdOffer.nftAddress, address(nft)); // Checks if the NFT is the same as the one in the offer 
        assertEq(createdOffer.tokenId, 1); // Checks token ID
        assertEq(createdOffer.price, _price); // Checks price 
        assertEq(createdOffer.deadline, _deadline); // Check deadline
        assertEq(createdOffer.isEnded, false); // Check if the offer is still open
        // Check that the NFT has been transferred to the contract
        assertEq(nft.ownerOf(1), address(marketplaceNFT));
        // Checks if the counter has incremented by 1
        assertEq(marketplaceNFT.sellOfferIdCounter(), 1);
        
    }

    function test_CreateSellOffer_Failed() public {
        
        uint256 _price = 0 ether;
        uint256 _deadline = block.timestamp + 1 hours;

        //bytes memory encodedOffer = abi.encode(offer);
        bytes memory data = abi.encode(_price, _deadline);

        nft.approve(address(marketplaceNFT),1);

        // Test revert if price is null
        vm.expectRevert(MarketplaceNFT.PriceNull.selector);
        marketplaceNFT.createSellOffer(address(nft), 1, data);

        _price = 1 ether;
        _deadline = block.timestamp;
        data = abi.encode(_price, _deadline);

        // Test the revert if the deadline has passed
        vm.expectRevert(MarketplaceNFT.DeadlinePassed.selector);
        marketplaceNFT.createSellOffer(address(nft), 1, data);

    }

// _______________________________________
// --------   getSellOffer -------------
// _______________________________________

    function test_GetSellOffer_Sucess() public {
    
        uint256 _priceAlice = 1 ether;
        uint256 _deadlineAlice = block.timestamp + 1 hours;

        bytes memory dataAlice = abi.encode(_priceAlice, _deadlineAlice);

        assertEq(marketplaceNFT.sellOfferIdCounter(), 0);

        nft.approve(address(marketplaceNFT),1);
        
        marketplaceNFT.createSellOffer(address(nft), 1, dataAlice);

        // Check that the offer has been created - Retrieve struct Offer and check getSellOffer id 0
        MarketplaceNFT.Offer memory createdOfferAlice = marketplaceNFT.getSellOffer(0);

        assertEq(createdOfferAlice.offerer, users.alice);
        assertEq(createdOfferAlice.nftAddress, address(nft));
        assertEq(createdOfferAlice.tokenId, 1);
        assertEq(createdOfferAlice.price, _priceAlice);
        assertEq(createdOfferAlice.deadline, _deadlineAlice);
        assertEq(createdOfferAlice.isEnded, false);
        // Check that the NFT has been transferred to the contract
        assertEq(nft.ownerOf(1), address(marketplaceNFT));
        // Checks if the counter has incremented by 1
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

        // Check that the offer has been created - Retrieve struct Offer and check getSellOffer id 1
        MarketplaceNFT.Offer memory createdOfferBob = marketplaceNFT.getSellOffer(1);

        assertEq(createdOfferBob.offerer, users.bob);
        assertEq(createdOfferBob.nftAddress, address(nft));
        assertEq(createdOfferBob.tokenId, 2);
        assertEq(createdOfferBob.price, _priceBob);
        assertEq(createdOfferBob.deadline, _deadlineBob);
        assertEq(createdOfferBob.isEnded, false);
        // Check that the NFT has been transferred to the contract
        assertEq(nft.ownerOf(2), address(marketplaceNFT));
        // Checks if the counter has incremented by 1
        assertEq(marketplaceNFT.sellOfferIdCounter(), 2);

        //-----------------------------------------------------
        //-------------- Creationn Offer for Charlie ---------

        vm.stopPrank();
        vm.startPrank(users.charlie);
       
        uint256 _priceCharlie = 20 ether;
        uint256 _deadlineCharlie = block.timestamp + 1 hours;

        bytes memory dataCharlie = abi.encode(_priceCharlie, _deadlineCharlie);

        assertEq(marketplaceNFT.sellOfferIdCounter(), 2);

        nft.approve(address(marketplaceNFT),3);
        
        marketplaceNFT.createSellOffer(address(nft), 3, dataCharlie);

        // Check that the offer has been created - Retrieve struct Offer and check getSellOffer id 2
        MarketplaceNFT.Offer memory createdOfferCharlie = marketplaceNFT.getSellOffer(2);

        assertEq(createdOfferCharlie.offerer, users.charlie);
        assertEq(createdOfferCharlie.nftAddress, address(nft));
        assertEq(createdOfferCharlie.tokenId, 3);
        assertEq(createdOfferCharlie.price, _priceCharlie);
        assertEq(createdOfferCharlie.deadline, _deadlineCharlie);
        assertEq(createdOfferCharlie.isEnded, false);
        // Check that the NFT has been transferred to the contract
        assertEq(nft.ownerOf(3), address(marketplaceNFT));
        // Checks if the counter has incremented by 1
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

        // Checking offer creation (Another way to call up the struct in the main contract.)
        (address nftAddress, uint256 tokenId, address offerer, uint256 price, uint256 deadline, bool isEnded) = marketplaceNFT.sellOffers(0);
        
        assertEq(nftAddress, address(nft));
        assertEq(offerer, users.alice); 
        assertEq(tokenId, 1);
        assertEq(price, 10 ether);
        assertEq(deadline, block.timestamp + 1 hours);
        assertEq(isEnded, false); 

        // Fast advance beyond deadline
        //vm.warp(16 days); // = vm.warp(block.timestamp + 16 days);
      
        vm.stopPrank();
        vm.startPrank(users.bob);

        // Prepares and controls the SellOfferAccepted event to be issued
        vm.expectEmit(true,false,false,false);
        emit SellOfferAccepted(0);
        
        // Accéptation de l'offre
        marketplaceNFT.acceptSellOffer{value: 10 ether}(0);

        // Check for status change
        (nftAddress, tokenId,offerer, price, deadline, isEnded) = marketplaceNFT.sellOffers(0);
        assertEq(offerer, users.alice);
        assertEq(price, 10 ether);
        assert(deadline > block.timestamp); // The deadline remains unchanged
        assertEq(isEnded, true); // Check "finished" final status

        // Check that the new owner is Bob
        assertEq(nft.ownerOf(1), users.bob);
        // Checks Bob and Alice's balance after transfer
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

        // Checking offer creation
        (address nftAddress, uint256 tokenId, address offerer, uint256 price, uint256 deadline, bool isEnded) = marketplaceNFT.sellOffers(0);
        
        assertEq(nftAddress, address(nft));
        assertEq(offerer, users.bob); 
        assertEq(tokenId, 2);
        assertEq(price, 2 ether);
        assertEq(deadline, block.timestamp + 2 hours);
        assertEq(isEnded, false); 

        // Fast advance beyond deadline
        // vm.warp(16 days); // = vm.warp(block.timestamp + 16 days);
      
        vm.stopPrank();
        vm.startPrank(users.alice);
        deal(users.alice, 100 ether);

        // Test revert if price is null
        vm.expectRevert(MarketplaceNFT.BadPrice.selector);
        marketplaceNFT.acceptSellOffer{value: 1 ether}(0);

        // Test the revert if the deadline has passed
        vm.warp(3 hours);
        vm.expectRevert(MarketplaceNFT.DeadlinePassed.selector);
        marketplaceNFT.acceptSellOffer{value: 2 ether}(0);

        // Time in compliance to accept the offer 
        vm.warp(1 hours);

        // Alice accepts the sales order
        marketplaceNFT.acceptSellOffer{value: 2 ether}(0);

        (nftAddress, tokenId,offerer, price, deadline, isEnded) = marketplaceNFT.sellOffers(0);
       
        console.log(isEnded); // = true
        // Test the revert if the offer has ended
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

        // Checking offer creation
        (address nftAddress, uint256 tokenId, address offerer, uint256 price, uint256 deadline, bool isEnded) = marketplaceNFT.sellOffers(0);
        
        assertEq(nftAddress, address(nft));
        assertEq(offerer, users.alice); 
        assertEq(tokenId, 1);
        assertEq(price, 1 ether);
        assertEq(deadline, block.timestamp + 1 hours);
        assertEq(isEnded, false); 
        
        vm.warp(block.timestamp + 2 hours);

        // Prepares and controls the SellOfferCancelled event to be issued
        vm.expectEmit(true,false,false,false);
        emit SellOfferCancelled(0);

        // Alice accepta orden venta
        marketplaceNFT.cancelSellOffer(0);

        // Checks if Alice is the owner of the NFT
        assertEq(nft.ownerOf(tokenId), users.alice);

    }

    function test_CancelSellOffer_Failed() public {

        uint256 _price = 1 ether;
        uint256 _deadline = block.timestamp + 1 hours;

        bytes memory data = abi.encode(_price, _deadline);

        nft.approve(address(marketplaceNFT),1);
        
        marketplaceNFT.createSellOffer(address(nft), 1, data);

        // Checking offer creation
        (address nftAddress, uint256 tokenId, address offerer, uint256 price, uint256 deadline, bool isEnded) = marketplaceNFT.sellOffers(0);
      
        assertEq(nftAddress, address(nft));
        assertEq(offerer, users.alice); 
        assertEq(tokenId, 1);
        assertEq(price, 1 ether);
        assertEq(deadline, block.timestamp + 1 hours);
        assertEq(isEnded, false); 

        // Check that deadline has not passed
        vm.warp(block.timestamp);
        vm.expectRevert(MarketplaceNFT.DeadlineNotPassed.selector);
        marketplaceNFT.cancelSellOffer(0);

        vm.stopPrank();
        vm.startPrank(users.bob);
        vm.warp(block.timestamp + 2 hours);
        // Checks that if Offerer is not the msg.sender
        vm.expectRevert(MarketplaceNFT.NotOwner.selector);
        marketplaceNFT.cancelSellOffer(0);


        vm.stopPrank();
        vm.startPrank(users.alice);
        // Alice accepts sales order
        marketplaceNFT.cancelSellOffer(0);

        (,,,, deadline,) = marketplaceNFT.sellOffers(0);
        // Check that the offer is not closed
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
        
        // Check counter initialization to 0
        assertEq(marketplaceNFT.buyOfferIdCounter(), 0);

        // Prepares and controls the BuyOfferCreated event to be issued
        vm.expectEmit(true,false,false,false);
        emit BuyOfferCreated(1);

        // Creating a purchase offer
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
         // Checks counter after function execution
        assertEq(marketplaceNFT.buyOfferIdCounter(), 1);

    }

    function test_CreateBuyOffer_Failed() public {

        uint256 deadline = block.timestamp;

        // Checks that the deadline has not been exceeded DeadlinePassed()
        vm.warp(1 days);
        vm.expectRevert(MarketplaceNFT.DeadlinePassed.selector);
        marketplaceNFT.createBuyOffer{value: 1 ether}(
            address(nft),
            1,
            deadline 
        );

        // Checks that the ether sent is not zero BelowZero()
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
        
        assertEq(marketplaceNFT.buyOfferIdCounter(), 0);

        // Creating a purchase offer
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

        assertEq(marketplaceNFT.buyOfferIdCounter(), 1);

        // Creating a purchase offer
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

// _______________________________________
// --------   AcceptBuyOffer -------------
// _______________________________________
    function test_AcceptBuyOffer_Success() public {
        
        vm.stopPrank();
        vm.startPrank(users.bob);

        uint256 tokenID = 1;

        // Creating a purchase offer
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

        // Prepares and controls the BuyOfferAccepted event to be issued
        vm.expectEmit(true,false,false,false);
        emit BuyOfferAccepted(0);

        marketplaceNFT.acceptBuyOffer(0);
        
        // Check that the NFT has been sent to Bob
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

        // Test revert if price is null
        vm.expectRevert(MarketplaceNFT.NoOwnerOfNft.selector);
        marketplaceNFT.acceptSellOffer{value: 20 ether}(0);

        // Test the revert if the deadline has passed
        vm.warp(3 hours);
        vm.expectRevert(MarketplaceNFT.DeadlinePassed.selector);
        marketplaceNFT.acceptSellOffer{value: 2 ether}(0);

    }


// _______________________________________
// --------   CancelBuyOffer -------------
// _______________________________________

    function test_CancelBuyOffer_Success() public {
        
        uint256 tokenID = 1;
        uint256 balanceAlice = users.alice.balance;

        // Creating a purchase offer
        marketplaceNFT.createBuyOffer{value: 1 ether}(
            address(nft),
            tokenID,
            block.timestamp + 15 days
        );

        // Checking offer creation
        (, , address offerer, uint256 price, uint256 deadline, bool isEnded) = marketplaceNFT.buyOffers(0);
       
        assertEq(offerer, users.alice); 
        assertEq(price, 1 ether);
        assertEq(deadline, block.timestamp + 15 days);
        assertEq(isEnded, false); 

        // Check if Alice's balance changes after the offer is created
        assertEq(balanceAlice - price, users.alice.balance);
        uint256 oldBalanceAlice = users.alice.balance;

        // Prepares and controls the BuyOfferCancelled event to be issued
        vm.expectEmit(true,false,false,false);
        emit BuyOfferCancelled(0);
        // Fast advance beyond deadline
        vm.warp(16 days); // = vm.warp(block.timestamp + 16 days);
        // Offer cancellation
        marketplaceNFT.cancelBuyOffer(0);

        // Check for status change
        (,,offerer, price, deadline, isEnded) = marketplaceNFT.buyOffers(0);
        assertEq(offerer, users.alice);
        assertEq(price, 1 ether);
        assert(deadline < block.timestamp);
        assertEq(isEnded, true); // Check "completed" final status
        // Checks if the old balance of Alice and the price is equal to the current balance.
        assertEq(oldBalanceAlice + price, users.alice.balance);

    }

    function test_CancelBuyOffer_Failed() public {

        vm.stopPrank();
        vm.startPrank(users.bob);

        uint256 tokenID = 2;
        uint256 balanceBob = users.bob.balance;

        assertEq(marketplaceNFT.buyOfferIdCounter(), 0);

        // Creating a purchase offer
        marketplaceNFT.createBuyOffer{value: 1 ether}(
            address(nft),
            tokenID,
            block.timestamp + 15 days
        );

        // Checking offer creation
        (, , address offerer, uint256 price, uint256 deadline, bool isEnded) = marketplaceNFT.buyOffers(0);
        
        assertEq(offerer, users.bob); 
        assertEq(price, 1 ether);
        assertEq(deadline, block.timestamp + 15 days);
        assertEq(isEnded, false); 
        // Checks Bob's balance after executing the function
        assertEq(balanceBob - price, users.bob.balance);
        uint256 newBalanceBob = users.bob.balance;

        assertEq(marketplaceNFT.buyOfferIdCounter(), 1);

        // Checks if deadline has not passed DeadlineNotPassed() 
        vm.warp(1 days);
        vm.expectRevert(MarketplaceNFT.DeadlineNotPassed.selector);
        marketplaceNFT.cancelBuyOffer(0);

        vm.warp(16 days);

        // Checks offer owner, returns error if no, NotOwner() 
        vm.stopPrank();
        vm.startPrank(users.alice);
        vm.expectRevert(MarketplaceNFT.NotOwner.selector);
        marketplaceNFT.cancelBuyOffer(0);

        // Checks if the offer is completed OfferClosed() 
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
