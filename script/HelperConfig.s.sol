// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import {Script} from "forge-std/Script.sol";
import {MockV3Aggregator} from "../test/mocks/MockV3Aggregator.sol";

contract HelperConfig  is Script{

        struct NetworkConfig {
                address priceFeed;
        }

        uint8 public constant DECIMALS = 8;
        int256 public constant INITIAL_PRICE = 2000e8;
        NetworkConfig public activeNetworkConfig;
        
        constructor () {
                if (block.chainid == 11155111){
                        activeNetworkConfig = getSapoliaEthConfig();
                }else{
                        activeNetworkConfig = getAnvilEthConfig();
                }
        }
        function getSapoliaEthConfig() public pure returns(NetworkConfig memory) {
                NetworkConfig memory SapoliaConfig = NetworkConfig({
                        priceFeed : 0x694AA1769357215DE4FAC081bf1f309aDC325306
                });
                return SapoliaConfig;
                
        }
        function getAnvilEthConfig() public returns(NetworkConfig memory) {
                if (activeNetworkConfig.priceFeed != address(0)){
                        return activeNetworkConfig;
                }
                vm.startBroadcast();
                MockV3Aggregator mockV3Aggregator = new MockV3Aggregator(DECIMALS,INITIAL_PRICE);
                vm.stopBroadcast();
                NetworkConfig memory ANvilConfig = NetworkConfig ({priceFeed : address(mockV3Aggregator)});
                return ANvilConfig;
        }

}