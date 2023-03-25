// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;
import "../../lib/chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";
import "lib/openzeppelin-contracts/contracts/utils/Counters.sol";

// import "../../lib/openzeppelin-contracts/contracts/interfaces/IERC20.sol";

// library LibAuctionStorage {

struct marketDetails {
    bool isBougth;
    address seller;
    uint256 price;
    address buyer;
    uint256 amountBougth;
    string paymentToken;
}

struct ItemDetails {
    address NftAddress;
    uint NftId;
}

struct MarketStorage {
    address Moderator;
    uint256[] ItemsId;
    mapping(uint256 => bool) isCorrectId;
    mapping(uint256 => marketDetails) MarketItem;
    mapping(uint256 => ItemDetails) mItemDetails;
    AggregatorV3Interface priceFeedDai;
    AggregatorV3Interface priceFeedEth;
    AggregatorV3Interface priceFeedLink;
    AggregatorV3Interface priceFeedUSDC;
    AggregatorV3Interface priceFeedBTC;
    address USDC;
    address Link;
    address BTC;
    address Dai;
    Counters.Counter _tokenIdCounter;
}
// }
