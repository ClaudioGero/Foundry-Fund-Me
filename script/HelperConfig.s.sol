// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;
//Deploy mocks when we are not on a local anvil chain
//keep track of cas across chains
import {Script} from "forge-std/Script.sol";

contract HelperConfig is Script {
    NetworkConfig public activeNetworkConfig;
    struct NetworkConfig {
        address priceFeed;
    }
    constructor() {
        if (block.chainid == 11155111){activeNetworkConfig = getSepoliaEthConfig();}
        else if (block.chainid == 1){activeNetworkConfig = getMainnetEthConfig();} else activeNetworkConfig = getAnvilEthConfig();}
    function getSepoliaEthConfig () public pure returns (NetworkConfig memory) {
        NetworkConfig memory Sepoliaconfig= NetworkConfig({priceFeed: 0x694AA1769357215DE4FAC081bf1f309aDC325306});
        return Sepoliaconfig;
    }
    function getMainnetEthConfig () public pure returns (NetworkConfig memory) {
        NetworkConfig memory Mainnetconfig= NetworkConfig({priceFeed: 0x5f4eC3Df9cbd43714FE2740f5E3616155c5b8419});
        return Mainnetconfig;
    }
    function getAnvilEthConfig () public pure returns (NetworkConfig memory){}
    }