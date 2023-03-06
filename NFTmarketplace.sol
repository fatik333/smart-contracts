// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.18;

import "./nft.sol";
import "./token.sol";

contract NFTMarketplace {
// Variables
address public owner;
uint256 public price;
ERC721Token public nft;
ASHToken public token;

// Events
event Buy(address indexed buyer, uint256 indexed tokenId, uint256 price);

// Constructor
constructor(address _nftAddress, address payable _tokenAddress, uint256 _price) payable{
    owner = msg.sender;
    nft = ERC721Token(_nftAddress);
    token = ASHToken(_tokenAddress);
    price = _price;
}

// Methods
function buy(uint256 _tokenId) public {
    address tokenOwner = nft.getOwner(_tokenId);
    require(tokenOwner != address(0), "Invalid token ID.");
    require(token.balanceOf(msg.sender) >= price, "Insufficient balance.");
    require(token.allowance(msg.sender, address(this)) >= price, "Allowance insufficient.");

    token.transferFrom(msg.sender, owner, price);
    nft.transferFrom(tokenOwner, msg.sender, _tokenId);

    emit Buy(msg.sender, _tokenId, price);
}

function setPrice(uint256 _price) public {
    require(msg.sender == owner, "You are not the owner of this contract.");
    price = _price;
}

function withdraw() public {
    require(msg.sender == owner, "You are not the owner of this contract.");
    uint256 balance = address(this).balance;
    payable(owner).transfer(balance);
}

fallback() external payable {}

receive() external payable {}
}