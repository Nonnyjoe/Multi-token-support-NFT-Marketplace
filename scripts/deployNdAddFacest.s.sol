// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import "../contracts/facets/MarketplaceFacet.sol";
import "../contracts/interfaces/IDiamondCut.sol";
import "../contracts/facets/DiamondCutFacet.sol";
import "../contracts/facets/DiamondLoupeFacet.sol";
import "../contracts/facets/OwnershipFacet.sol";
import "../lib/forge-std/src/Script.sol";
import "../contracts/Diamond.sol";

contract DiamondDeployer is Script, IDiamondCut {
    function run() public {
        // bool v = true;

        //    if (v) {
        //         DiamondCutFacet dcf = new DiamondCutFacet();
        //         if (v) console.log("Deploying DiamondCutFacet:  ", address(dcf));
        //         if (_verify) verifyContract("DiamondCutFacet",address(dcf));
        //     }

        address diamondAddr = address(
            0x158a895F317F304fEE044705B35d55E18943f0D9
        );
        address newMarketPlace = address(
            0x12Aa78E05788c366b3BBBeB3B9D5CE1c508F34BB
        );
        address MockNFT = address(0x7Edb383cbeF340c71693c602Fea8EeDBD8120615);
        // address diamondCutAddr = address(
        //     0xb9e916833acbB55ee9b0714C67Cebe9Bb267FbC2
        // );
        address dLoupeAddr = address(
            0x5CFF28ceD6627eF6E3f648af74307A77fA0A8941
        );
        address ownerFAddr = address(
            0x921035b20696a660D8B1781c0Ed5D373A0B346EB
        );
        address marketPlaceAddr = address(
            0xB0a37245a19251063C590c5e8A7642A74BEaF36D
        );
        FacetCut[] memory cut = new FacetCut[](3);
        cut[0] = (
            FacetCut({
                facetAddress: address(dLoupeAddr),
                action: FacetCutAction.Add,
                functionSelectors: generateSelectors("DiamondLoupeFacet")
            })
        );

        cut[1] = (
            FacetCut({
                facetAddress: address(ownerFAddr),
                action: FacetCutAction.Add,
                functionSelectors: generateSelectors("OwnershipFacet")
            })
        );
        cut[2] = (
            FacetCut({
                facetAddress: address(marketPlaceAddr),
                action: FacetCutAction.Add,
                functionSelectors: generateSelectors("MarketplaceFacet")
            })
        );

        // cut[2] = (
        //     FacetCut({
        //         facetAddress: address(
        //             0xB0a37245a19251063C590c5e8A7642A74BEaF36D
        //         ),
        //         action: FacetCutAction.Add,
        //         functionSelectors: generateSelectors("MarketplaceFacet")
        //     })
        // );
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        vm.startBroadcast(deployerPrivateKey); //upgrade diamond

        IDiamondCut(diamondAddr).diamondCut(cut, address(0x0), "");

        //call a function
        DiamondLoupeFacet(diamondAddr).facetAddresses();
        vm.stopBroadcast();
    }

    //     function verifyContract(string memory _facetName, address _addr) internal  {
    //     console.log("Verify:",_facetName,_addr);
    //     string [] memory cmd = new string[](7);
    //     cmd[0] = "forge";
    //     cmd[1] = "verify-contract";
    //     cmd[2] = Strings.toHexString(uint160(_addr), 20);
    //     cmd[3] = _facetName;
    //     cmd[4] = vm.envString("BSCSCANAPIKEY");
    //     cmd[5] = "--verifier-url";
    //     cmd[6] = "https://api.bscscan.com/api";

    //     for(uint i=0;i<cmd.length;i++)
    //         console.log(i,cmd[i]);

    //     bytes memory res = vm.ffi(cmd);
    //     console.log(string(res));
    // }

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
