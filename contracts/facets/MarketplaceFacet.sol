// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "../libraries/LibMarketPlace.sol";
import {LibDiamond} from "../libraries/LibDiamond.sol";

contract MarketplaceFacet {
    function ListItem(
        address _NftAddress,
        uint _NftId,
        uint _price
    ) external returns (uint ItemId_) {
        ItemId_ = LibMarketPlace._ListItem(_NftAddress, _NftId, _price);
    }

    function TakeOffMarket(uint _ItemId) external {
        LibMarketPlace._TakeOffMarket(_ItemId);
    }

    function setUp() external returns (bool status) {
        status = LibMarketPlace.setUp();
    }

    function PurchaseViaDai(uint _ItemId) external {
        LibMarketPlace._PurchaseViaDai(_ItemId);
    }

    function PurchaseViaBTC(uint _ItemId) external {
        LibMarketPlace._purchaseViaBTC(_ItemId);
    }

    function PurchaseViaUSDC(uint _ItemId) external {
        LibMarketPlace._PurchaseViaUSDC(_ItemId);
    }

    function PurchaseViaEth(uint _ItemId) external payable {
        LibMarketPlace._PurchaseViaEth(_ItemId);
    }

    function PurchaseViaLink(uint _ItemId) external payable {
        LibMarketPlace._PurchaseViaLink(_ItemId);
    }

    function DisplayPriceInDai(uint _ItemId) external view returns (int price) {
        price = LibMarketPlace._DisplayPriceInDai(_ItemId);
    }

    function DisplayPriceInLink(
        uint _ItemId
    ) external view returns (int price) {
        price = LibMarketPlace._DisplayPriceInLink(_ItemId);
    }

    function DisplayPriceInUSDC(
        uint _ItemId
    ) external view returns (int price) {
        price = LibMarketPlace._DisplayPriceInUSDC(_ItemId);
    }

    function DisplayPriceInEth(
        uint _ItemId
    ) external view returns (uint price) {
        price = LibMarketPlace._DisplayPriceInEth(_ItemId);
    }

    function AdminWithdrawal(uint _ammount) external payable {
        LibMarketPlace._AdminWithdrawal(_ammount);
    }
}
