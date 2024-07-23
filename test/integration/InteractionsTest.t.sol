// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import {Test,console} from "forge-std/Test.sol";

import {FundMe} from "../../src/FundMe.sol";

import {DeployFundMe} from "../../script/DeployFundMe.s.sol";

import {DevOpsTools} from "foundry-devops/src/DevOpsTools.sol";

import {FundFundMe} from "../../script/Insteractions.s.sol";
import {WithdrawFundMe} from "../../script/Insteractions.s.sol";

contract InteractionsTest is Test {

        FundMe fundMe;
        address USER = makeAddr("user");
        uint256 constant SEND_VALUE = 1 ether;
        uint256 constant START_BALANCE = 10 ether;
        uint256 constant GAS_PRICE = 1;
        
        function setUp() external{
                DeployFundMe deployFundMe = new DeployFundMe();
                fundMe = deployFundMe.run();
                vm.deal(USER,START_BALANCE);
                
        }

        function testUserCanFundInteractions() public {
                
                vm.prank(USER);
                FundFundMe fundFundMe = new FundFundMe();
                console.log("value of user before trans ---> %s",USER.balance);
                address mostRecentlyDeployed = DevOpsTools.DeploymentAddressFetcher('FundMe',block.chainid);  
                fundFundMe.fundFundMe(mostRecentlyDeployed);
                console.log("value of user after trans ---> %s",USER.balance);
                console.log("balance of FundMe contract %s",mostRecentlyDeployed.balance);
                // address funder = fundMe.getFunder(0);
                // assertEq(funder, USER);

                // WithdrawFundMe withdrawFundMe = new WithdrawFundMe();
                // withdrawFundMe.withdrawFundMe(mostRecentlyDeployed);

                // assert(address(fundMe).balance ==0);

        }

        function testGetOwnerBalance() public view{
                // address mostRecentlyDeployed = DevOpsTools.get_most_recent_deployment('FundMe',block.chainid);  
                address mostRecentlyDeployed = 0x1dD6946b0D9264CAf80d9335BdFb7bb375e1841E;
                console.log("balance of FundMe contract %s",mostRecentlyDeployed.balance);
        }

}