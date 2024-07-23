// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import {Test,console} from "forge-std/Test.sol";

import {FundMe} from "../../src/FundMe.sol";

import {DeployFundMe} from "../../script/DeployFundMe.s.sol";

contract FundMeTest is Test {

    FundMe fundMe;
    address USER = makeAddr("user");
    uint256 constant SEND_VALUE = 0.0027 ether;
    uint256 constant START_BALANCE = 10 ether;
    uint256 constant GAS_PRICE = 1;

    function setUp() external{
        DeployFundMe deployFundMe = new DeployFundMe();
        fundMe = deployFundMe.run();
        vm.deal(USER,START_BALANCE);
    }
    function testMinimumDollarIsFived() public view{
        assertEq(fundMe.MINIMUM_USD(),5e18);
    }
    
    function testOwnerIsMsgSender() public view{
        assertEq(fundMe.getOwner(),msg.sender);
    }
    function testPriceFeedVersionIsAccurate() public view{
        uint256 version = fundMe.getVersion();
        assertEq(version,4);
    }
    function testFundFailsWithoutEnoughETH() public {
        vm.expectRevert();
        emit log("Attempting to fund with insufficient ETH...");
        fundMe.fund();
    }
    function testFundUpdatesFundedDataStructure() public {
        vm.prank(USER);
        fundMe.fund{value:SEND_VALUE}();
        uint256 amountFunded = fundMe.getAddressToAmountFunded(USER);
        assertEq(amountFunded, SEND_VALUE);
    }
    function testAddsFundersToArrayOfFunders()  public funded{
        vm.prank(USER);
        fundMe.fund{value:SEND_VALUE}();
        address funder = fundMe.getFunder(0);
        assertEq(funder, USER);
    }
    function testOnlyOwnerCanWithdraw() public funded {
        // address OWNER = address(fundMe.getOwner());
        // emit log_address(OWNER);

        vm.expectRevert();
        vm.prank(USER);
        fundMe.withdraw();

    }
    function testWithDrawWithSingleFunder() public funded {
        // arrange
        uint256 startingOwnerBalance = fundMe.getOwner().balance;
        uint256 startingFundMeBalance = address(fundMe).balance;

        // act
        // uint256 gasStart = gasleft();
        // vm.txGasPrice(GAS_PRICE);
        vm.prank(fundMe.getOwner());
        fundMe.withdraw();

        // uint256 gasEnd = gasleft();

        // uint256 gasUsed = (gasStart-gasEnd) * tx.gasprice;
        // console.log(gasUsed);

        // assert
        uint256 endingOwnerBalance = fundMe.getOwner().balance;
        // uint256 endingFundMeBalance = address(fundMe).balance;
        assertEq(startingFundMeBalance+startingOwnerBalance,endingOwnerBalance);

    }

    function testWithDrawFromMultipleFunders() public funded {
        uint160 numberOfFunders = 10;
        uint160 startingFunderIndex = 1;
        for (uint160 i = 0; i < numberOfFunders; i++){
            hoax(address(startingFunderIndex),SEND_VALUE);
            // will prank and update balance of user
            fundMe.fund{value:SEND_VALUE}();
        }
        uint256 startingOwnerBalance = fundMe.getOwner().balance;
        uint256 startingFundMeBalance = address(fundMe).balance;
        vm.startPrank(fundMe.getOwner());
        fundMe.withdraw();
        vm.stopPrank();

        assert(address(fundMe).balance == 0);
        assert(startingFundMeBalance+startingOwnerBalance == fundMe.getOwner().balance);
        // emit  log_uint(fundMe.getOwner().balance);

    }

    function testWithDrawFromMultipleFundersCheaper() public funded {
        uint160 numberOfFunders = 10;
        uint160 startingFunderIndex = 1;
        for (uint160 i = 0; i < numberOfFunders; i++){
            hoax(address(startingFunderIndex),SEND_VALUE);
            // will prank and update balance of user
            fundMe.fund{value:SEND_VALUE}();
        }
        uint256 startingOwnerBalance = fundMe.getOwner().balance;
        uint256 startingFundMeBalance = address(fundMe).balance;
        vm.startPrank(fundMe.getOwner());
        fundMe.cheaperWithdraw();
        vm.stopPrank();

        assert(address(fundMe).balance == 0);
        assert(startingFundMeBalance+startingOwnerBalance == fundMe.getOwner().balance);
        // emit  log_uint(fundMe.getOwner().balance);

    }

    modifier funded (){
        vm.prank(USER);
        fundMe.fund{value:SEND_VALUE}();
        _;
    }




}