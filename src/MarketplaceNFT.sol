// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;
 
import "@openzeppelin/contracts/token/ERC721/IERC721Receiver.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721.sol";

/**
* @title Contrat MarketPlace NFT - Final Project
* @author Sébastien Léger
* @notice This contract enables us to generate and execute buy and sell orders for NFT , via a Marketplace.
*/
// interface IERC721 {
//     function safeTransferFrom(address from, address to, uint256 tokenId, bytes calldata data) external;
// }
contract MarketplaceNFT is IERC721Receiver {

   
    // ================================================================
  // |                            STORAGE                            |
  // ================================================================

    /**
        * @dev variables role
        * 'sellOfferIdCounter' : Counter that increments with each sales order created, providing unique identifiers.
        * 'buyOfferIdCounter' : Counter that increments with each purchase order created, providing unique identifiers.
        * 'marketplaceName' : the name of the marketplace. It will be received by parameter in the contract builder.
        * 'nftContract' : Reference standard for the ERC721 token, to use its properties.
    */
    uint256 public sellOfferIdCounter;
    uint256 public buyOfferIdCounter;
    address payable private owner;

    string private marketplaceName;


    /**
        * @dev mappings role
        * 'sellOffers' : mapping from uint256 to Offer that will store the created sell orders. A sell order is a type 
        * of order where the creator offers an NFT, and specifies an amount of ETH he wants to receive in return.
        * 'buyOffers' : mapping from uint256 to Offer that will store the created buy orders. A buy order is a type 
        * of order where the creator offers an amount of ETH, and specifies an NFT he wants to receive in return.
    */

    mapping(uint256 => Offer) public sellOffers;
    mapping(uint256 => Offer) public  buyOffers;


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
        uint256 tokenId;
        address offerer;
        uint256 price;
        uint256 deadline;
        bool isEnded;
    }

    constructor(string memory _marketplaceName)  {
        _marketplaceName = marketplaceName;
       // owner = payable(msg.sender);
        
    }

    // ================================================================
    // |                            LOGICA                            |
    // ================================================================

    error DeadlinePassed();
    error PriceNull();
    error OwnerOfNft();
    error AlwaysOnSell(); // la vente n'a pas été faite
    error TimeSpent(); // Deadline de l'offre, passée 
    error BadPrice(); // Le prix de l'offre n'ai pas le prix envoyé
    error OfferClosed(); // Offre terminée
    error DeadlineNotPassed(); // Temps limité toujours pas passée
    error NotOwner(); // msg.sender n'est pas le propriétaire
    error BelowZero(); // le prix doit être supérieur à zéro

    event SellOfferCreated(uint256 indexed sellOfferIdCounter);
    event SellOfferAccepted(uint256 indexed _sellOfferIdCounter);
    event SellOfferCancelled(uint256 indexed sellOfferIdCounter);
    event BuyOfferCreated(uint256 indexed buyOfferIdCounter);
    event BuyOfferAccepted(uint256 indexed _buyOfferIdCounter);
    event BuyOfferCancelled(uint256 indexed _buyOfferIdCounter);

    /**
        * @notice function 'onERC721Received' inherited from IERC721Receiver, 
        * @dev Retrieves (receives) information about an NFT token, and returns 
        * another function to create an offer to sell.
    */

     function onERC721Received(
        address operator, 
        address from, 
        uint256 tokenId, 
        bytes calldata data
    ) 
        external override returns(bytes4) {

            return IERC721Receiver.onERC721Received.selector;
     }

    /**
        * @notice function 'createSellOffer' , 
        * @dev Creates a sell order for an NFT by specifying the NFT contract address, 
        * the NFT token ID, the price in ETH and the deadline for accepting the order.
        * All this information is implemented in the 'sellOffers' mapping.
        * Increment 'SellOfferIdCounter'.
        * Emits a 'SellOfferCreated' event, with the offer ID as parameter.
    */

    function createSellOffer(
        address _nftAddress,
        address _offerer,
        uint256 _tokenId,
        bytes calldata data
        // uint256 _price,
        // uint256 _deadline
    ) 
        public 
    {
        (uint256 _price, uint256 _deadline) = abi.decode(data, (uint256, uint256));

        if(IERC721(_nftAddress).ownerOf(_tokenId) != msg.sender) revert OwnerOfNft();
        if(_price <= 0 ether) revert PriceNull();
        if(_deadline <= block.timestamp) revert DeadlinePassed();


        sellOffers[sellOfferIdCounter] = Offer({
            offerer : _offerer,
            nftAddress : _nftAddress,
            tokenId : _tokenId,
            price : _price,
            deadline : _deadline,
            isEnded : false
        });

        sellOfferIdCounter++;

        IERC721(_nftAddress).safeTransferFrom(msg.sender, address(this), _tokenId);

      //  IERC721Receiver.onERC721Received(msg.sender, address(this), _tokenId, data);

        emit SellOfferCreated(sellOfferIdCounter);    
        
    }

    /**
        * @notice function 'getSellOffer' , 
        * @dev Returns an offer and its components to 'sellOffers' storage
        * by entering the tokenId.
    */

    function getSellOffer(uint256 _tokenId) public view returns (Offer memory) {
        return sellOffers[_tokenId];
    }

    // ---------------------------------------------------------------------------------

    /**
        * @notice function 'acceptSellOffer' , 
        * @dev Permits the buyer to accept a sell order specifying 
        * the order ID as a parameter. 
        * Once the sell order has been accepted, the NFT must be transferred
        * to the buyer and the ETH to the seller.
        * Emits a 'SellOfferAccepted' event, with the offer ID as parameter.
    */
    function acceptSellOffer(uint256 _sellOfferIdCounter) public payable {

        uint256 priceUser = msg.value;
        Offer memory sellOffer = sellOffers[_sellOfferIdCounter];
        
        if(sellOffer.isEnded == true) revert AlwaysOnSell();
        if(sellOffer.deadline < block.timestamp) revert TimeSpent();
        if(sellOffer.price != priceUser) revert BadPrice(); 

        sellOffer.isEnded = true;
        //sellOffers[_sellOfferIdCounter].isEnded = true;
        
        IERC721 nftContract = IERC721(sellOffer.nftAddress);

        if (nftContract.ownerOf(sellOffer.tokenId) != sellOffer.offerer) revert NotOwner();

        nftContract.safeTransferFrom(address(this),msg.sender,sellOffer.tokenId);
        
    
          payable(sellOffer.offerer).transfer(priceUser);

         emit SellOfferAccepted(_sellOfferIdCounter);
    }
    // -------------------------------------------------------------------
    // A voir pour la création d'une fonction de fallback et receive et Send() 
    // -----------------------------------------------------------------------------------

    /**
        * @notice function 'cancelSellOffer' , 
        * @dev Enables creators of sell orders to cancel these orders, 
        * once the deadline imposed in the order has passed.
        * Once the order has been cancelled, the NFT is transferred
        * back to the order creator.
        * Emits a 'SellOfferCancelled' event, with the offer ID as parameter.
    */

    function cancelSellOffer(uint256 _sellOfferIdCounter) public {

         Offer memory sellOffer = sellOffers[_sellOfferIdCounter];

        if (sellOffer.isEnded) revert OfferClosed();
        if (sellOffer.deadline <= block.timestamp) revert DeadlineNotPassed();
        if (sellOffer.offerer != msg.sender) revert NotOwner();

        sellOffers[_sellOfferIdCounter].isEnded = true;

        IERC721(sellOffer.nftAddress).safeTransferFrom(address(this), sellOffer.offerer, sellOffer.tokenId);

        emit SellOfferCancelled(_sellOfferIdCounter);

    }

        /**
        * @notice function 'creatBuyOffer' , 
        * @dev Create a buy order for an NFT by specifying the NFT 
        * contract address, the NFT token ID and the deadline for accepting the order.
        * All this information is implemented in the 'buyOffers' mapping.
        * Increment 'buyOfferIdCounter'.
        * Emits a 'BuyOfferCreated' event, with the offer ID as parameter.
    */
    function createBuyOffer(
            address _nftAddress,
            uint256 _tokenId,
            uint256 _deadline
        ) public payable {
            if(_deadline < block.timestamp) revert DeadlinePassed();
            if(msg.value == 0) revert BelowZero();

            Offer memory offer = Offer({
            nftAddress : _nftAddress,
            tokenId : _tokenId,
            offerer : msg.sender,
            price : msg.value,
            deadline : _deadline,
            isEnded : false
        });

        buyOffers[buyOfferIdCounter] = offer;

        buyOfferIdCounter++;

         emit BuyOfferCreated(buyOfferIdCounter);
        
    }

    /**
        * @notice function 'getBuyOffer' , 
        * @dev Returns an offer and its components to 'buyOffers' storage
        * by entering the tokenId.
    */
      function getBuyOffer(uint256 _tokenId) public view returns (Offer memory) {
        return buyOffers[_tokenId];
    }

    /**
        * @notice function 'acceptBuyOffer' , 
        * @dev Permits the buyer to accept a buy order specifying 
        * the order ID as a parameter. 
        * Once the sell order has been accepted, the NFT must be transferred to the creator 
        * of the buy order, and the ETH to the buyer of this order.
        * Emits a 'BuyOfferAccepted' event, with the offer ID as parameter.
    */
    function acceptBuyOffer(uint256 _buyOfferIdCounter) public {
        Offer memory buyOffer = buyOffers[_buyOfferIdCounter];

        if((IERC721(buyOffer.nftAddress).ownerOf(buyOffer.tokenId) != msg.sender)) revert NotOwner();
        if(buyOffer.isEnded) revert OfferClosed();
        if(buyOffer.deadline < block.timestamp) revert DeadlinePassed();

        buyOffers[_buyOfferIdCounter].isEnded = true;

        // Transfert du NFT au créateur de l'offre
        IERC721(buyOffer.nftAddress).safeTransferFrom(msg.sender,buyOffer.offerer,buyOffer.tokenId);

        payable(msg.sender).transfer(buyOffer.price);

        emit BuyOfferAccepted(_buyOfferIdCounter);

    }

        /**
        * @notice function 'cancelBuyOffer' , 
        * @dev Enables creators of buy orders to cancel these orders, 
        * once the deadline imposed in the order has passed.
        * After cancellation of the order, the ETH is transferred back 
        * to the creator of the buy order.
        * Emits a 'BuyOfferCancelled' event, with the offer ID as parameter.
    */
    function cancelBuyOffer(uint _buyOfferIdCounter) public {

        Offer memory buyOffer = buyOffers[_buyOfferIdCounter];

        if (buyOffer.isEnded == true) revert OfferClosed(); 
        if (buyOffer.deadline >= block.timestamp) revert DeadlineNotPassed();
        if (buyOffer.offerer != msg.sender) revert NotOwner();

        buyOffers[_buyOfferIdCounter].isEnded = true;

    // Transfert de l'ETH au créateur de l'offre
        payable(msg.sender).transfer(buyOffer.price);

    // Evénement
        emit BuyOfferCancelled(_buyOfferIdCounter);

    }






    // event Transfer(address indexed from, address indexed to, uint256 indexed tokenId);
    // event Approval(address indexed owner, address indexed approved, uint256 indexed tokenId);
    // event ApprovalForAll(address indexed owner, address indexed operator, bool approved);
    // function balanceOf(address owner) external view returns (uint256 balance);
    // function ownerOf(uint256 tokenId) external view returns (address owner);
    // function safeTransferFrom(address from, address to, uint256 tokenId, bytes calldata data) external;
    // function safeTransferFrom(address from, address to, uint256 tokenId) external;
    // function transferFrom(address from, address to, uint256 tokenId) external;
    // function approve(address to, uint256 tokenId) external;
    // function setApprovalForAll(address operator, bool approved) external;
    // function getApproved(uint256 tokenId) external view returns (address operator);
    // function isApprovedForAll(address owner, address operator) external view returns (bool);

}