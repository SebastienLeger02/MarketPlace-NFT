# *Marketplace NFT :*

## The Project :

The project involves creating a Non-Fungible Token (NFT) marketplace smart contract using the Solidity programming language. This marketplace will allow users to interact with a variety of NFTs securely and transparently on the Ethereum blockchain.

The key features of the smart contract will include:

1. **Listing of NFTs for sale**: Users will be able to list their NFTs for sale on the marketplace. They can set the price and other terms of sale.
2. **Purchasing of NFTs**: Users will be able to browse the NFTs available for sale on the marketplace and purchase those they are interested in.
3. **Placing purchase orders**: Users will be able to place purchase orders for specific NFTs, indicating the price they are willing to pay.
4. **Order execution**: When a purchase order matches an NFT listed for sale, the order is automatically executed, transferring the NFT to the buyer and the funds to the seller.
5. **Secure transaction management**: All transactions will be securely handled by the smart contract, ensuring that the funds and the NFTs are properly transferred.
6. **Transparency**: All transactions will be recorded on the blockchain, offering total transparency on the transaction history.

The tests were conducted with **Foundry**, a tool specifically designed to test smart contracts written in **Solidity**. Foundry offers an efficient and flexible approach to ensure the robustness and reliability of your contracts. Thanks to Foundry, you can write, execute, and manage your tests with ease, which is essential for ensuring the smooth operation of your blockchain applications.

Library : 

[openzeppelin-contracts/contracts/proxy/utils/UUPSUpgradeable.sol at master · OpenZeppelin/openzeppelin-contracts](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/proxy/utils/UUPSUpgradeable.sol)


## The Components of the Project:

- **Solidity Version Directive :**
    - ***pragma*** solidity ^0.8.23;
    
- **Library :**
    - https://github.com/OpenZeppelin/openzeppelin-contracts
    
- **Storage - State Variables and Complex Types :**  **
    
```solidity
    uint256 public sellOfferIdCounter;
    uint256 public buyOfferIdCounter;

    string public marketplaceName;
```

'**sellOfferIdCounter**' : Counter that increments with each sales order created, providing unique identifiers.

'**buyOfferIdCounter**' : Counter that increments with each purchase order created, providing unique identifiers.

'**marketplaceName**' : the name of the marketplace. It will be received by parameter in the contract builder.

```solidity
mapping(uint256 => Offer) public sellOffers;
mapping(uint256 => Offer) public  buyOffers;
```
    
'**sellOffers**' : mapping from uint256 to Offer that will store the created sell orders. A sell order is a type of order where the creator offers an NFT, and specifies an amount of ETH he wants to receive in return.

'**buyOffers**' : mapping from uint256 to Offer that will store the created buy orders. A buy order is a type of order where the creator offers an amount of ETH, and specifies an NFT he wants to receive in return.

```solidity
    struct Offer {
        address nftAddress;
        uint256 tokenId;
        address offerer;
        uint256 price;
        uint256 deadline;
        bool isEnded;
    }
```

'**nftAddress**' : the address of the offering NFT contract.

'**tokenId**' : the id of the offer NFT.

'**offerer**' : the address that created the offer.

'**price**' : the price in ETH of the offer.

'**deadline**' : the maximum date by which the offer can be accepted.

'**isEnded**' : boolean that will indicate whether the offer has already been accepted, or the offer has been cancelled.
    
- **Gestion des erreurs** :

```solidity
error DeadlinePassed();
error PriceNull(); 
error NoOwnerOfNft(); 
error BadPrice(); 
error OfferClosed(); 
error DeadlineNotPassed(); 
error NotOwner(); 
error BelowZero(); 
```

'**DeadlinePassed**' : Offer deadline passed . 

'**PriceNull**' : No price.

'**NoOwnerOfNft**' : Not the owner of the NFT.

'**BadPrice**' : The offer price is not the price sent.

'**OfferClosed**' : Offre closed.

'**DeadlineNotPassed**' : Limited time still not passed.

'**NotOwner**' : msg.sender is not the owner.

'**BelowZero**' : The price must be greater than zero.

- **Events:**

```solidity
event EtherReceived(address indexed sender, uint256 indexed amount);
event SellOfferCreated(uint256 indexed sellOfferIdCounter);
event SellOfferAccepted(uint256 indexed _sellOfferIdCounter);
event SellOfferCancelled(uint256 indexed sellOfferIdCounter);
event BuyOfferCreated(uint256 indexed buyOfferIdCounter);
event BuyOfferAccepted(uint256 indexed _buyOfferIdCounter);
event BuyOfferCancelled(uint256 indexed _buyOfferIdCounter);
```

- **Modifier :**

```solidity
 *modifier* NFTOwner(address nftAddress, uint256 tokenId) {...};
```

**‘nftAddress’**, address of the NFT.

**'tokenId'**, ID of the NFT.

Is called before the execution of a function to modify it, 
Checks that the NFT is that of the msg.sender.

- **Functions :**

```solidity
*function* initialize(string memory _marketplaceName) external initializer() {…}
```

**'marketplaceName'** name of the Market place.

When using a proxy, this function replaces the contructor, and is deployed when the proxy is launched.
It defines the contract owner and the NFT marketplace name.

```solidity
*function* _authorizeUpgrade(address newImplementation) internal override view {…}
```

**'newImplementation'**, address for new implementation.

Function that should revert when `msg.sender` is not authorized to upgrade the contract.

```solidity
*function* onERC721Received(address,address,uint256,bytes calldata) external pure returns(bytes4) {…}
```

Retrieves (receives) information about an NFT token, and returns another function to create an offer to sell.

```solidity
function createSellOffer(address _nftAddress,uint64 _tokenId,byte memory data) public NFTOwner(_nftAddress, _tokenId){...}
```

**'_nftAddress'** , address of NFT.

**'_tokenId'** , ID of NFT.

**'data'** ,_'price  NFT price. _deadline', deadline for accepting the order.

Creates a sell order for an NFT by specifying the NFT contract address, the NFT token ID, the price in ETH and the deadline for accepting the order.

```solidity
*function* getSellOffer(uint256 _tokenId) public view returns (Offer memory) {…}
```

**'_tokenId’** , Id of NFT.

Returns an offer and its components to 'sellOffers' storage by entering the tokenId.

```solidity
*function* acceptSellOffer(uint256 _sellOfferIdCounter) public payable {…}
```

**‘_sellOfferIdCounter’**, ID of sell offer.

Permits the buyer to accept a sell order specifying the order ID as a parameter.

```solidity
 *function* cancelSellOffer(uint256 _sellOfferIdCounter) public {…}
```

**‘_sellOfferIdCounter’**, Id of sell offer.

Enables creators of sell orders to cancel these orders, once the deadline imposed in the order has passed.

```solidity
 function createBuyOffer(address _nftAddress, uint64 _tokenId,uint128 _deadline) public payable {...}
```

**‘_nftAddress’**, address of  NFT.

**'_tokenId’**, ID of NFT.

**'_deadline’**, deadline for buying confirmation.

Create a purchase order, which allows a person to propose an offer to buy a person's NFT. 

```solidity
*function* getBuyOffer(uint256 _tokenId) public view returns (Offer memory) {…}
```

**‘_tokenId’** , Id of NFT.

Returns an offer and its components to 'buyOffers' storage by entering the tokenId.

```solidity
 *function* acceptBuyOffer(uint256 _buyOfferIdCounter) public {…}
```

**‘_buyOfferIdCounter’**, ID of counter buy offer.

Permits the buyer to accept a buy order specifying the order ID as a parameter. 

```solidity
    function cancelBuyOffer(uint _buyOfferIdCounter) public {...}
```

**'_buyOfferIdCounter'**, ID of counter buy offer

Enables creators of buy orders to cancel these orders, once the deadline imposed in the order has passed.

## Conclusion:

Setting up an **NFT marketplace** is a complex project that requires a deep understanding of **Solidity** and related tools.

**1. Smart Contracts**

- **Solidity** is the programming language used to write our smart contracts. These contracts define the operating rules of the marketplace.
- We have chosen to use **proxies** to manage updates to our contracts. Proxies allow the separation of the implementation logic from the update management logic.

**2. Testing with Foundry**

- Here is how **Foundry** was used to ensure the quality and robustness of our implementation. It allows us to:
    - Write tests directly in Solidity.
    - Execute these tests with the **`forge test`** command.
    - Verify that our contracts work correctly on the blockchain of our choice.

In summary, creating an NFT marketplace is a technical process that requires a combination of development skills, understanding of smart contracts, and use of tools such as Foundry. 🚀
