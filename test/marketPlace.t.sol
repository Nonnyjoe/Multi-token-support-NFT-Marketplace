// // SPDX-License-Identifier: UNLICENSED
// pragma solidity ^0.8.0;
// import "../contracts/facets/MarketplaceFacet.sol";
// import "../contracts/facets/MockNFT.sol";
// import "../lib/forge-std/src/Test.sol";
// import "../lib/openzeppelin-contracts/contracts/interfaces/IERC20.sol";
// import "../lib/chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";

// // import "./deployDiamond.t.sol";
// contract MarkrtFacetTest is Test {
//     MarketPlace marketFacet;
//     MockNFT mockNFT;
//     IERC20 Usdt;
//     address Seller = mkaddr("Seller");
//     address buyer1 = mkaddr("buyer1");
//     address BusdHolder = address(0x9F8413454C182369c0200F6cC1031903477F752E);
//     address DaiHolder = address(0x60FaAe176336dAb62e284Fe19B885B095d29fB7F);
//     address UniHolder = address(0x47173B170C64d16393a52e6C480b3Ad8c302ba1e);
//     address UsdtHolder = address(0x64b6eBE0A55244f09dFb1e46Fe59b74Ab94F8BE1);

//     function setUp() public {
//         marketFacet = new MarketPlace();
//         mockNFT = new MockNFT();
//         Usdt = IERC20(0xdAC17F958D2ee523a2206206994597C13D831ec7);
//     }

//     function testCreateAuction() public returns (uint) {
//         vm.startPrank(Seller);
//         mockNFT.mint(address(marketFacet));

//         uint ItemId = marketFacet.ListItem(address(mockNFT), 0, 2 ether);
//         vm.stopPrank();
//         return ItemId;
//     }

//     function testTakeOffMarket() public {
//         uint ItemId = testCreateAuction();
//         vm.startPrank(Seller);
//         marketFacet.TakeOffMarket(ItemId);
//         vm.stopPrank();
//     }

//     function testPurchaseViaEth() public {
//         uint ItemId = testCreateAuction();
//         vm.deal(buyer1, 10 ether);
//         vm.prank(buyer1);
//         marketFacet.PurchaseViaEth{value: 2 ether}(ItemId);
//     }

//     function testPurchaseViaDai() public {
//         uint ItemId = testCreateAuction();
//         vm.deal(DaiHolder, 10000 ether);
//         vm.startPrank(DaiHolder);
//         marketFacet.setUp();
//         IERC20(0x6B175474E89094C44Da98b954EedeAC495271d0F).approve(
//             address(marketFacet),
//             (100 * 1e26)
//         );
//         marketFacet.PurchaseViaDai(ItemId);
//         vm.stopPrank();
//     }

//     function testPurchaseViaUni() public {
//         uint ItemId = testCreateAuction();
//         vm.deal(UniHolder, 10000 ether);
//         vm.startPrank(UniHolder);
//         marketFacet.setUp();
//         IERC20(0x1f9840a85d5aF5bf1D1762F925BDADdC4201F984).approve(
//             address(marketFacet),
//             (100 * 1e26)
//         );
//         marketFacet.PurchaseViaUni(ItemId);
//         vm.stopPrank();
//     }

//     function testPurchaseViaBusd() public {
//         uint ItemId = testCreateAuction();
//         vm.deal(BusdHolder, 10000 ether);
//         vm.startPrank(BusdHolder);
//         marketFacet.setUp();
//         IERC20(0x4Fabb145d64652a948d72533023f6E7A623C7C53).approve(
//             address(marketFacet),
//             (100 * 1e26)
//         );
//         marketFacet.PurchaseViaBusd(ItemId);
//         vm.stopPrank();
//     }

//     // function testPurchaseViaUsdt() public {
//     //     uint ItemId = testCreateAuction();
//     //     vm.deal(UsdtHolder, 10000 ether);
//     //     vm.startPrank(UsdtHolder);
//     //     marketFacet.setUp();
//     //     IERC20(0xdAC17F958D2ee523a2206206994597C13D831ec7).approve(
//     //         address(marketFacet),
//     //         100000000000
//     //     );
//     //     marketFacet.PurchaseViaUsdt(ItemId);
//     //     vm.stopPrank();
//     // }

//     function mkaddr(string memory name) public returns (address) {
//         address addr = address(
//             uint160(uint256(keccak256(abi.encodePacked(name))))
//         );
//         vm.label(addr, name);
//         return addr;
//     }
// }
