// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import {Test,console} from "forge-std/Test.sol";
import {FundMe} from "../../src/FundMe.sol";
import {DeployFundMe} from "../../script/DeployFundMe.s.sol";
contract FundMeTest is Test {
    uint256 constant sendValue= 10e18;
    uint256 constant starting_balance= 10 ether;
    uint256 constant GAS_PRICE = 1;
    address USER = makeAddr("user");
    FundMe fundMe;
    function setUp() external { DeployFundMe deployFundMe = new DeployFundMe(); fundMe = deployFundMe.run(); vm.deal(USER, starting_balance); }
    function testDemo() public {
        assertEq(fundMe.MINIMUM_USD, 5e18);
        }
    function testPriceFeedVersionIsAccurate() public {
        uint256 version = fundMe.getVersion();
        assertEq(version, 4);
    }
    function failNoEth() public {
        vm.expectRevert();
        fundMe.fund();
    }
    function testFundUpdatesFundedDataStructure() public funded { 
        uint256 amountFunded = fundMe.addressToAmountFunded(address(this));
        assertEq(amountFunded, sendValue);
    }
    function testAddsFunderToArrayOfFunders() public {
        vm.prank(USER);
        fundMe.fund{value: sendValue}();
        address funder = fundMe.getFunder(0);
        assertEq(funder, USER);
    }
    modifier funded() {
        vm.prank(USER);
        fundMe.fund{value: sendValue}();
        _;
    }
    function testOnlyOwnerCanWithdraw() public funded{

        vm.expectRevert();
        vm.prank(USER);

        fundMe.withdraw();
    }
    function testWithdrawWithSingleFunder() public funded {
        //arrange
        uint256 startingOwnerBalance = fundMe.getOwner().balance;
        uint256 startingFunderBalance = address(fundMe).balance;
        //act
        vm.prank(fundMe.getOwner());
        fundMe.withdraw();
        //assert
        uint256 endingOwnerBalance = fundMe.getOwner().balance;
        uint256 endingFunderBalance = address(fundMe).balance;
        assertEq(endingFunderBalance, 0);

        assertEq(endingOwnerBalance, startingOwnerBalance + startingFunderBalance);
    }
    function testWithdrawFromMultipleFunders() public funded {
        uint160 numberOfFunders = 10;
        uint256 startingIndex = 1;
        for (uint256 i = 0; i < numberOfFunders; i++) {

            hoax(address(i), sendValue);
            fundMe.fund{value: sendValue}();
        }
        uint256 startingOwnerBalance = fundMe.getOwner().balance;
        uint256 startingFunderBalance = address(fundMe).balance;
        vm.startPrank(fundMe.getOwner());
        fundMe.withdraw();
        vm.stopPrank();
        assert(address(fundMe).balance == 0);
        assert(startingFunderBalance == fundMe.getOwner().balance);
    }
    function testWithdrawFromMultipleFundersCheaper() public funded {
        uint160 numberOfFunders = 10;
        uint256 startingIndex = 1;
        for (uint256 i = 0; i < numberOfFunders; i++) {

            hoax(address(i), sendValue);
            fundMe.fund{value: sendValue}();
        }
        uint256 startingOwnerBalance = fundMe.getOwner().balance;
        uint256 startingFunderBalance = address(fundMe).balance;
        vm.startPrank(fundMe.getOwner());
        fundMe.cheaperWithdraw();
        vm.stopPrank();
        assert(address(fundMe).balance == 0);
        assert(startingFunderBalance == fundMe.getOwner().balance);
    }
    function testOwnerIsMsgSender() public {

        assertEq(fundMe.getOwner(), msg.sender);
    }
}