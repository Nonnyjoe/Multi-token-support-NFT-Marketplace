// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
import "../libraries/MarketStorage.sol";
import "../../lib/openzeppelin-contracts/contracts/interfaces/IERC20.sol";
import "../../lib/openzeppelin-contracts/contracts/interfaces/IERC721.sol";
import "lib/openzeppelin-contracts/contracts/utils/Counters.sol";

// import "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";

library LibMarketPlace {
    using Counters for Counters.Counter;

    event ItemListed(
        uint ItemId,
        address seller,
        address ItemAddress,
        uint price
    );
    event ItemOffMarket(
        uint ItemId,
        address seller,
        address ItemAddress,
        uint price,
        address from
    );
    event ItemBougth(
        uint ItemId,
        address ItemAddress,
        int price,
        address seller,
        address buyer,
        string token
    );

    // constructor() {
    //     ds.Moderator = msg.sender;
    // }

    function _ListItem(
        address _NftAddress,
        uint _NftId,
        uint _price
    ) internal returns (uint) {
        MarketStorage storage ds = MarketSlot();
        uint256 ItemId = ds._tokenIdCounter.current();
        ds._tokenIdCounter.increment();
        prepareItem(ItemId, _NftAddress, _NftId, _price);
        ds.ItemsId.push(ItemId);
        ds.isCorrectId[ItemId] = true;
        emit ItemListed(ItemId, msg.sender, _NftAddress, _price);
        return ItemId;
    }

    function prepareItem(
        uint _ItemId,
        address _NftAddress,
        uint _NftId,
        uint _price
    ) internal {
        IERC721(_NftAddress).transferFrom(msg.sender, address(this), _NftId);
        MarketStorage storage ds = MarketSlot();
        ds.MarketItem[_ItemId] = marketDetails({
            isBougth: false,
            seller: msg.sender,
            price: _price,
            buyer: address(0),
            amountBougth: 0,
            paymentToken: ""
        });
        ds.mItemDetails[_ItemId] = ItemDetails({
            NftAddress: _NftAddress,
            NftId: _NftId
        });
    }

    function _TakeOffMarket(uint _ItemId) internal {
        MarketStorage storage ds = MarketSlot();
        if (ds.isCorrectId[_ItemId] == false) revert("INVALID ITEM ID");
        (
            bool isBougth,
            address seller,
            uint256 price,
            address buyer,
            uint256 amountBougth,
            address NftAddress,
            uint256 NftId
        ) = fetchItemDetails(_ItemId);
        if (seller != msg.sender) revert("NOT THE ORIGINAL SELLER");
        if (isBougth == true) revert("ITEM ALREADY SOLD");
        ds.MarketItem[_ItemId].isBougth = true;
        handleItemTransfer(
            _ItemId,
            NftAddress,
            NftId,
            seller,
            address(this),
            msg.sender,
            price,
            amountBougth,
            "ETH"
        );
        emit ItemOffMarket(_ItemId, msg.sender, NftAddress, price, buyer);
    }

    function handleItemTransfer(
        uint256 _ItemId,
        address _NftAddress,
        uint256 _NftId,
        address _currentOwner,
        address _from,
        address _to,
        uint256 _price,
        uint256 _amountBougth,
        string memory _paymentToken
    ) internal {
        MarketStorage storage ds = MarketSlot();
        IERC721(_NftAddress).transferFrom(_from, _to, _NftId);
        ds.MarketItem[_ItemId] = marketDetails({
            isBougth: true,
            seller: _currentOwner,
            price: _price,
            buyer: _to,
            amountBougth: _amountBougth,
            paymentToken: _paymentToken
        });
    }

    function fetchItemDetails(
        uint256 _ItemId
    )
        internal
        view
        returns (
            bool isBougth,
            address seller,
            uint256 price,
            address buyer,
            uint256 amountBougth,
            address NftAddress,
            uint256 NftId
        )
    {
        MarketStorage storage ds = MarketSlot();
        isBougth = ds.MarketItem[_ItemId].isBougth;
        seller = ds.MarketItem[_ItemId].seller;
        price = ds.MarketItem[_ItemId].price;
        buyer = ds.MarketItem[_ItemId].buyer;
        amountBougth = ds.MarketItem[_ItemId].amountBougth;
        NftAddress = ds.mItemDetails[_ItemId].NftAddress;
        NftId = ds.mItemDetails[_ItemId].NftId;
    }

    function setUp() internal returns (bool) {
        MarketStorage storage ds = MarketSlot();
        ds.priceFeedDai = AggregatorV3Interface(
            0xAed0c38402a5d19df6E4c03F4E2DceD6e29c1ee9
        );
        ds.priceFeedEth = AggregatorV3Interface(
            0x5f4eC3Df9cbd43714FE2740f5E3616155c5b8419
        );
        ds.priceFeedUni = AggregatorV3Interface(
            0x553303d460EE0afB37EdFf9bE42922D8FF63220e
        );
        ds.priceFeedBusd = AggregatorV3Interface(
            0x833D8Eb16D306ed1FbB5D7A2E019e106B960965A
        );
        ds.priceFeedUsdt = AggregatorV3Interface(
            0x3E7d1eAB13ad0104d2750B8863b489D65364e32D
        );
        ds.Uni = address(0x1f9840a85d5aF5bf1D1762F925BDADdC4201F984);
        ds.Dai = address(0x6B175474E89094C44Da98b954EedeAC495271d0F);
        ds.Busd = address(0x4Fabb145d64652a948d72533023f6E7A623C7C53);
        ds.Usdt = address(0xdAC17F958D2ee523a2206206994597C13D831ec7);
        return true;
    }

    function getTokenLatestPrice(
        AggregatorV3Interface _pricefeed
    ) internal view returns (int) {
        (
            ,
            /* uint80 roundID */ int price /*uint startedAt*/ /*uint timeStamp*/ /*uint80 answeredInRound*/,
            ,
            ,

        ) = _pricefeed.latestRoundData();
        return (price);
    }

    function _PurchaseViaDai(uint _ItemId) internal {
        MarketStorage storage ds = MarketSlot();
        if (ds.isCorrectId[_ItemId] == false) revert("INVALID ITEM ID");
        (
            bool isBougth,
            address seller,
            uint256 price,
            ,
            ,
            address NftAddress,
            uint256 NftId
        ) = fetchItemDetails(_ItemId);
        if (isBougth) revert("ITEM ALREADY PURCHASED");
        int priceInDai = handleTokenTransfer(
            price,
            ds.priceFeedDai,
            ds.Dai,
            seller
        );
        handleItemTransfer(
            _ItemId,
            NftAddress,
            NftId,
            seller,
            address(this),
            msg.sender,
            price,
            uint(priceInDai),
            "DAI"
        );

        emit ItemBougth(
            _ItemId,
            NftAddress,
            priceInDai,
            seller,
            msg.sender,
            "DAI"
        );
    }

    function _PurchaseViaBusd(uint _ItemId) internal {
        MarketStorage storage ds = MarketSlot();
        if (ds.isCorrectId[_ItemId] == false) revert("INVALID ITEM ID");
        (
            bool isBougth,
            address seller,
            uint256 price,
            ,
            ,
            address NftAddress,
            uint256 NftId
        ) = fetchItemDetails(_ItemId);
        if (isBougth) revert("ITEM ALREADY PURCHASED");
        int priceInBusd = handleTokenTransfer(
            price,
            ds.priceFeedBusd,
            ds.Busd,
            seller
        );
        handleItemTransfer(
            _ItemId,
            NftAddress,
            NftId,
            seller,
            address(this),
            msg.sender,
            price,
            uint(priceInBusd),
            "BUSD"
        );
        emit ItemBougth(
            _ItemId,
            NftAddress,
            priceInBusd,
            seller,
            msg.sender,
            "Busd"
        );
    }

    function _purchaseViaUsdt(uint _ItemId) internal {
        MarketStorage storage ds = MarketSlot();
        if (ds.isCorrectId[_ItemId] == false) revert("INVALID ITEM ID");
        (
            bool isBougth,
            address seller,
            uint256 price,
            ,
            ,
            address NftAddress,
            uint256 NftId
        ) = fetchItemDetails(_ItemId);
        if (isBougth) revert("ITEM ALREADY PURCHASED");
        int mPrice = handleEthTransfer(price, ds.Usdt, seller);
        handleItemTransfer(
            _ItemId,
            NftAddress,
            NftId,
            seller,
            address(this),
            msg.sender,
            price,
            uint(mPrice),
            "USDT"
        );
    }

    function handleEthTransfer(
        uint _price,
        address _token2Addr,
        address seller
    ) internal returns (int) {
        MarketStorage storage ds = MarketSlot();
        int token2Price = (1e18 / getTokenLatestPrice(ds.priceFeedUsdt));
        int mPrice = (int(_price) * token2Price);
        bool sucess = IERC20(_token2Addr).transferFrom(msg.sender, seller, 10);
        require(sucess, "TOKEN TRANSFER ERROR");
        return mPrice;
    }

    function _PurchaseViaEth(uint _ItemId) internal {
        MarketStorage storage ds = MarketSlot();
        if (ds.isCorrectId[_ItemId] == false) revert("INVALID ITEM ID");
        (
            bool isBougth,
            address seller,
            uint256 price,
            ,
            ,
            address NftAddress,
            uint256 NftId
        ) = fetchItemDetails(_ItemId);
        if (isBougth) revert("ITEM ALREADY PURCHASED");
        uint userBal = msg.sender.balance;
        require(userBal >= price, "INSUFFICIENT BALANCE");
        require(msg.value >= price, "INSUFFICIENT AMMOUNT TRASFERED");
        (bool success, ) = seller.call{value: msg.value}("");
        require(success, "TRANSFER ERROR");

        handleItemTransfer(
            _ItemId,
            NftAddress,
            NftId,
            seller,
            address(this),
            msg.sender,
            price,
            price,
            "ETH"
        );
        emit ItemBougth(
            _ItemId,
            NftAddress,
            int(price),
            seller,
            msg.sender,
            "ETH"
        );
    }

    function _PurchaseViaUni(uint _ItemId) internal {
        MarketStorage storage ds = MarketSlot();
        if (ds.isCorrectId[_ItemId] == false) revert("INVALID ITEM ID");
        (
            bool isBougth,
            address seller,
            uint256 price,
            ,
            ,
            address NftAddress,
            uint256 NftId
        ) = fetchItemDetails(_ItemId);
        if (isBougth) revert("ITEM ALREADY PURCHASED");
        int priceInUni = handleTokenTransfer(
            price,
            ds.priceFeedUni,
            ds.Uni,
            seller
        );
        handleItemTransfer(
            _ItemId,
            NftAddress,
            NftId,
            seller,
            address(this),
            msg.sender,
            price,
            uint(priceInUni),
            "UNI"
        );
        emit ItemBougth(
            _ItemId,
            NftAddress,
            priceInUni,
            seller,
            msg.sender,
            "UNI"
        );
    }

    function handleTokenTransfer(
        uint _price,
        AggregatorV3Interface _t2Aggregator,
        address _token2Addr,
        address seller
    ) internal returns (int) {
        MarketStorage storage ds = MarketSlot();
        int ethPrice = getTokenLatestPrice(ds.priceFeedEth);
        int token2Price = getTokenLatestPrice(_t2Aggregator);
        int priceInToken2 = (((int(_price) * ethPrice) / token2Price) / 1e8);
        uint UserToken2Bal = IERC20(_token2Addr).balanceOf(msg.sender);
        // require(int(UserToken2Bal) >= priceInToken2, "INSUFFICIENT BALANCE");
        bool sucess = IERC20(_token2Addr).transferFrom(
            msg.sender,
            seller,
            UserToken2Bal
        );
        require(sucess, "TRANSFER TO SELLER FAILED");
        return priceInToken2;
    }

    function _AdminWithdrawal(uint _ammount) internal {
        MarketStorage storage ds = MarketSlot();
        require(_ammount <= address(this).balance, "AMOUNT EXCEEDS BALANCE");
        (bool success, ) = ds.Moderator.call{value: _ammount}("");
        require(success, "TRANSFER ERROR");
    }

    function _DisplayPriceInDai(
        uint _ItemId
    ) internal view returns (int priceInToken2) {
        MarketStorage storage ds = MarketSlot();
        if (ds.isCorrectId[_ItemId] == false) revert("INVALID ITEM ID");
        (bool isBougth, , uint256 price, , , , ) = fetchItemDetails(_ItemId);
        if (isBougth) revert("ITEM ALREADY PURCHASED");
        int ethPrice = getTokenLatestPrice(ds.priceFeedEth);
        int token2Price = getTokenLatestPrice(ds.priceFeedDai);
        priceInToken2 = (((int(price) * ethPrice) / token2Price) / 1e8);
    }

    function _DisplayPriceInUni(
        uint _ItemId
    ) internal view returns (int priceInToken2) {
        MarketStorage storage ds = MarketSlot();
        if (ds.isCorrectId[_ItemId] == false) revert("INVALID ITEM ID");
        (bool isBougth, , uint256 price, , , , ) = fetchItemDetails(_ItemId);
        if (isBougth) revert("ITEM ALREADY PURCHASED");
        int ethPrice = getTokenLatestPrice(ds.priceFeedEth);
        int token2Price = getTokenLatestPrice(ds.priceFeedUni);
        priceInToken2 = (((int(price) * ethPrice) / token2Price) / 1e8);
    }

    function _DisplayPriceInBusd(
        uint _ItemId
    ) internal view returns (int priceInToken2) {
        MarketStorage storage ds = MarketSlot();
        if (ds.isCorrectId[_ItemId] == false) revert("INVALID ITEM ID");
        (bool isBougth, , uint256 price, , , , ) = fetchItemDetails(_ItemId);
        if (isBougth) revert("ITEM ALREADY PURCHASED");
        int ethPrice = getTokenLatestPrice(ds.priceFeedEth);
        int token2Price = getTokenLatestPrice(ds.priceFeedBusd);
        priceInToken2 = (((int(price) * ethPrice) / token2Price) / 1e8);
    }

    function _DisplayPriceInEth(uint _ItemId) internal view returns (uint) {
        MarketStorage storage ds = MarketSlot();
        if (ds.isCorrectId[_ItemId] == false) revert("INVALID ITEM ID");
        (, , uint256 price, , , , ) = fetchItemDetails(_ItemId);
        return price;
    }

    function MarketSlot() internal pure returns (MarketStorage storage ds) {
        assembly {
            ds.slot := 0
        }
    }
}
