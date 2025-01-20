// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import {Sayeth, Record} from "../src/Sayeth.sol";

import {Test, console} from "forge-std/Test.sol";
import {MockERC20} from "./utils/MockERC20.sol";
import {StakeReferrer} from "../src/referrers/StakeReferrer.sol";

contract SayethTest is Test {
    event Say(address referrer, address sender, address origin, bytes content);
    event Scribe(address referrer, address sender, address origin, bytes content, uint256 index);

    Sayeth public _sayeth;

    MockERC20 public _token;
    StakeReferrer public _stakeReferrer;

    uint256 public _stakeAmt = 25e18;
    uint256 public ONE_WEEK = 604800;

    address public staker1 = address(45);
    address public staker2 = address(46);
    address public someGuy = address(47);

    function setUp() public {
        _sayeth = new Sayeth();

        _token = new MockERC20("Test", "TST");

        _token.mint(staker1, _stakeAmt);
        _token.mint(staker2, _stakeAmt);

        _stakeReferrer = new StakeReferrer(address(_token), _stakeAmt, ONE_WEEK, address(this));

        _stake(staker1);
        _stake(staker2);
    }

    function testSay_publicChannel() public {
        _say(address(0), address(1));
    }

    function testScribe_publicChannel() public {
        _scribe(address(0), address(1));

        Record memory record = _sayeth.getRecord(0);

        assertEq(record.sender, address(1));
        assertEq(record.origin, address(1));
        assertEq(record.content, abi.encode("hello world computer"));
        assertEq(record.referrer, address(0));
        assertEq(_sayeth.getRecordAmt(), 1);
    }

    function testSay_isStaked() public {
        _say(address(_stakeReferrer), staker1);
    }

    function testScribe_isStaked() public {
        _scribe(address(_stakeReferrer), staker1);

        Record memory record = _sayeth.getRecord(0);

        assertEq(record.sender, staker1);
        assertEq(record.origin, staker1);
        assertEq(record.content, abi.encode("hello world computer"));
        assertEq(record.referrer, address(_stakeReferrer));
        assertEq(_sayeth.getRecordAmt(), 1);
    }

    function testRevert_say_notStaked() public {
        vm.expectRevert("Post not validated by referrer");

        _sayeth.sayeth(address(_stakeReferrer), abi.encode("hello world computer"), false);
    }

    function testRevert_scribe_notStaked() public {
        vm.expectRevert("Post not validated by referrer");

        _sayeth.sayeth(address(_stakeReferrer), abi.encode("hello world computer"), true);
    }

    function _stake(address _staker) public {
        vm.startPrank(_staker);
        _token.approve(address(_stakeReferrer), _stakeAmt);
        _stakeReferrer.stake(_stakeAmt);
        vm.stopPrank();
    }

    function _say(address _referrer, address _poster) public {
        vm.expectEmit(true, false, false, true);

        emit Say(_referrer, _poster, _poster, abi.encode("hello world computer"));

        vm.prank(_poster, _poster);
        _sayeth.sayeth(_referrer, abi.encode("hello world computer"), false);
    }

    function _scribe(address _referrer, address _poster) public {
        vm.expectEmit(true, false, false, true);

        emit Scribe(_referrer, _poster, _poster, abi.encode("hello world computer"), 0);

        vm.prank(_poster, _poster);
        _sayeth.sayeth(_referrer, abi.encode("hello world computer"), true);
    }
}
