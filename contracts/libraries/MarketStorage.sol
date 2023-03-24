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
    AggregatorV3Interface priceFeedUni;
    AggregatorV3Interface priceFeedBusd;
    AggregatorV3Interface priceFeedUsdt;
    address Usdt;
    address Uni;
    address Dai;
    address Busd;
    Counters.Counter _tokenIdCounter;
}
// }
