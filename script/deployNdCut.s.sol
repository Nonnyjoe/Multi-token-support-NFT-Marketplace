// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
import "../contracts/Diamond.sol";
import "../contracts/facets/DiamondCutFacet.sol";
import "../contracts/facets/DiamondLoupeFacet.sol";
import "../contracts/facets/OwnershipFacet.sol";
import "../contracts/interfaces/IDiamondCut.sol";
import "../contracts/facets/MarketplaceFacet.sol";

import "../lib/forge-std/src/Script.sol";

contract DiamondScript is Script, IDiamondCut {
    function run() external {
        Diamond diamond;
        DiamondCutFacet dCutFacet;
        DiamondLoupeFacet dLoupe;
        OwnershipFacet ownerF;
        MarketplaceFacet marketPlace;
        address deployer = 0xA771E1625DD4FAa2Ff0a41FA119Eb9644c9A46C8;
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        vm.startBroadcast(deployerPrivateKey);

        dCutFacet = new DiamondCutFacet();
        diamond = new Diamond(deployer, address(dCutFacet));
        dLoupe = new DiamondLoupeFacet();
        ownerF = new OwnershipFacet();
        marketPlace = new MarketplaceFacet();

        FacetCut[] memory cut = new FacetCut[](3);

        cut[0] = (
            FacetCut({
                facetAddress: address(dLoupe),
                action: FacetCutAction.Add,
                functionSelectors: generateSelectors("DiamondLoupeFacet")
            })
        );
        cut[1] = (
            FacetCut({
                facetAddress: address(ownerF),
                action: FacetCutAction.Add,
                functionSelectors: generateSelectors("OwnershipFacet")
            })
        );
        cut[2] = (
            FacetCut({
                facetAddress: address(marketPlace),
                action: FacetCutAction.Add,
                functionSelectors: generateSelectors("MarketplaceFacet")
            })
        );

        IDiamondCut(address(diamond)).diamondCut(cut, address(0x0), "");

        // call a function
        DiamondLoupeFacet(address(diamond)).facetAddresses();
        vm.stopBroadcast();
    }

    // Diamond CA:0x3cBFFB0520D908d8947b6036Aeb5Ac0D08e0D8Df
    function generateSelectors(
        string memory _facetName
    ) internal returns (bytes4[] memory selectors) {
        string[] memory cmd = new string[](3);
        cmd[0] = "node";
        cmd[1] = "scripts/genSelectors.js";
        cmd[2] = _facetName;
        bytes memory res = vm.ffi(cmd);
        selectors = abi.decode(res, (bytes4[]));
    }

    function diamondCut(
        FacetCut[] calldata _diamondCut,
        address _init,
        bytes calldata _calldata
    ) external override {}
}

// address dCut =  0x901e435843efd1029ab9b914c267fb8dcbf1d033;
// address diamond =  0x8c0d3c6e521d13c1a58cf8907396cd0241161a3f;
// address dLoupe =  0xc554c0c655af5b724ae1701767f1d1fb71e0c096;
// address ownerF =   0x089e079b3c16f389efe1798bdaacea8470e1d9d7;
// address marketPlace =  0xdf5b58ef2fff94f4f261ccf8f40a8263231a23f0;
