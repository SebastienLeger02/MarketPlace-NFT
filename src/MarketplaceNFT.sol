// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;
 
/**
* @title Contrat MarketPlace NFT - Final Project
* @author Sébastien Léger
* @notice This contract enables us to generate and execute buy and sell orders for NFT , via a Marketplace.
*/
contract MarketplaceNFT {

    // ================================================================
  // |                            STORAGE                            |
  // ================================================================

  /**
     * @dev variables role
     * 'sellOfferIdCounter' : Counter that increments with each sales order created, providing unique identifiers.
     * 'buyOfferIdCounter' : Counter that increments with each purchase order created, providing unique identifiers.
     * 'marketplaceName' : the name of the marketplace. It will be received by parameter in the contract builder.
*/
uint256 public sellOfferIdCounter;
uint128 public buyOfferIdCounter;

string private marketplaceName;

/**
    * @dev mappings role
    * 'sellOffers' : mapping from uint256 to Offer that will store the created sell orders. A sell order is a type 
    * of order where the creator offers an NFT, and specifies an amount of ETH he wants to receive in return.
    * 'buyOffers' : mapping from uint256 to Offer that will store the created buy orders. A buy order is a type 
    * of order where the creator offers an amount of ETH, and specifies an NFT he wants to receive in return.
 */

mapping(uint256 => Offer) sellOffers;
mapping(uint256 => Offer) buyOffers;

/**
    * @notice 'Offer' (struct) is used for both buy and sell orders.
    * @dev struct  description
    * 'nftAddress' : the address of the offering NFT contract
    * 'tokenId' : the id of the offer NFT
    * 'offerer' : the address that created the offer
    * 'price' : the price in ETH of the offer
    * 'deadline' : the maximum date by which the offer can be accepted
    * 'isEnded' : boolean that will indicate whether the offer has already been accepted, or the offer has been cancelled
 */
struct Offer {
    address nftAddress;
    uint128 tokenId;
    address offerer;
    uint256 price;
    uint128 deadline;
    bool isEnded;
}

constructor(string memory _marketplaceName) {
    _marketplaceName = marketplaceName;
    
}

  // ================================================================
  // |                            LOGICA                            |
  // ================================================================

error DeadlinePassed();
error PriceNull();

event SellOfferCreated(uint256 sellOfferIdCounter);

function createSellOffer(
    address _nftAddresss,
    uint128 _tokenId,
    uint256 _price,
    uint128 _deadline
) 
    public 
{
    if(_price > 0 ) revert PriceNull();
    if(_deadline > block.timestamp) revert DeadlinePassed();

    sellOffers[sellOfferIdCounter] = Offer({
    offerer : msg.sender,
    nftAddress : _nftAddresss,
    tokenId : _tokenId,
    price : _price,
    deadline : _deadline,
    isEnded : true
    });

    sellOfferIdCounter++;

    emit SellOfferCreated(sellOfferIdCounter);    
    
}


}