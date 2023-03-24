// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import "../contracts/interfaces/IDiamondCut.sol";
import "../contracts/facets/DiamondCutFacet.sol";
import "../contracts/facets/DiamondLoupeFacet.sol";
import "../contracts/facets/OwnershipFacet.sol";
import "../lib/forge-std/src/Test.sol";
import "../contracts/Diamond.sol";
import "../contracts/facets/MarketplaceFacet.sol";


contract DiamondDeployer is Test, IDiamondCut {
