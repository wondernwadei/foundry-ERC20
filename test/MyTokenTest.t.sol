// SPDX-License-Identifier: MIT

pragma solidity ^0.8.18;

import {Test} from "forge-std/Test.sol";
import {MyToken} from "../src/MyToken.sol";
import {DeployMyToken} from "../script/DeployMyToken.s.sol";

contract MyTokenTest is Test {
    MyToken public myToken;
    DeployMyToken public deployer;

    address bob = makeAddr("bob");
    address alice = makeAddr("alice");

    uint256 public constant STARTING_BALANCE = 100 ether;

    function setUp() public {
        deployer = new DeployMyToken();
        myToken = deployer.run();

        vm.prank(msg.sender);
        myToken.transfer(bob, STARTING_BALANCE);
    }

    function testBobBalance() public {
        assertEq(STARTING_BALANCE, myToken.balanceOf(bob));
    }

    function testAllowancesWork() public {
        uint256 initialAllowance = 1000;

        // Alice approves Bob to spend tokens on her behalf
        vm.prank(bob);
        myToken.approve(alice, initialAllowance);

        uint256 transferAmount = 500;

        vm.prank(alice);
        myToken.transferFrom(bob, alice, transferAmount);

        assertEq(myToken.balanceOf(alice), transferAmount);
        assertEq(myToken.balanceOf(bob), STARTING_BALANCE - transferAmount);
    }

    function testTransfer() public {
        uint256 amount = 1000;
        address receiver = address(0x1);
        vm.prank(msg.sender);
        myToken.transfer(receiver, amount);
        assertEq(myToken.balanceOf(receiver),amount);
    }

    function testBalanceAfterTransfer() public {
        uint256 amount = 1000;
        address receiver = address(0x1);
        uint256 initialBalance = myToken.balanceOf(msg.sender);
        vm.prank(msg.sender);
        myToken.transfer(receiver, amount);
        assertEq(myToken.balanceOf(msg.sender), initialBalance - amount);
    }

    function testTransferFrom() public {
        uint256 amount = 1000;
        address receiver = address(0x1);
        vm.prank(msg.sender);
        myToken.approve(address(this), amount);
        myToken.transferFrom(msg.sender, receiver, amount);
        assertEq(myToken.balanceOf(receiver), amount);
    }
}