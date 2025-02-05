// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import {Sayeth, Record} from "../src/Sayeth.sol";

import {Test, console} from "forge-std/Test.sol";
import {MockERC20} from "./utils/MockERC20.sol";
import {StakeReferrer} from "../src/referrers/StakeReferrer.sol";
import {GGEmptyReferrer} from "../src/referrers/GGEmptyReferrer.sol";
import {Metadata} from "../src/utils/Metadata.sol";

contract SayethTest is Test {
    event Say(address referrer, address sender, address origin, bytes content);
    event Scribe(address referrer, address sender, address origin, bytes content, uint256 index);

    Sayeth public _sayeth;

    MockERC20 public _token;
    StakeReferrer public _stakeReferrer;
    GGEmptyReferrer public _emptyReferrer;

    Metadata public _testMd = Metadata(1, "Qm...");

    uint256 public STAKE_AMT = 25e18;
    uint256 public ONE_WEEK = 604800;

    address public staker1 = address(45);
    address public staker2 = address(46);
    address public someGuy = address(47);

    function setUp() public {
        _sayeth = new Sayeth();

        _token = new MockERC20("Test", "TST");

        _token.mint(staker1, STAKE_AMT);
        _token.mint(staker2, STAKE_AMT);

        _stakeReferrer = new StakeReferrer(address(_token), STAKE_AMT, ONE_WEEK, address(this));
        _emptyReferrer = new GGEmptyReferrer();

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
        assertEq(_sayeth.getRecordLength(), 1);
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
        assertEq(_sayeth.getRecordLength(), 1);
    }

    function testSay_emptyReferrer() public {
        bytes memory _data = abi.encode("This is the tag", "This is an optional field for onchain JSON", _testMd);
        _sayeth.sayeth(address(_emptyReferrer), _data, false);
    }

    function testSay_emptyReferrer_many() public {
        bytes memory _data = abi.encode("This is the tag", "This is an optional field for onchain JSON", _testMd);
        _sayeth.sayeth(address(_emptyReferrer), _data, false);

        vm.prank(someGuy, someGuy);

        _sayeth.sayeth(address(_emptyReferrer), _data, false);

        vm.prank(staker1, staker1);

        _sayeth.sayeth(address(_emptyReferrer), _data, false);
    }

    function testRevert_say_emptyReferrer_incorrectModel() public {
        bytes memory _data = abi.encode("");

        vm.expectRevert();

        vm.prank(someGuy, someGuy);
        _sayeth.sayeth(address(_emptyReferrer), _data, false);
    }

    function testRevert_say_emptyReferrer_incorrectMetadata() public {
        bytes memory _data =
            abi.encode("This is the tag", "This is an optional field for onchain JSON", Metadata(0, "Qm..."));

        vm.expectRevert("Post not validated by referrer");

        vm.prank(someGuy, someGuy);
        _sayeth.sayeth(address(_emptyReferrer), _data, false);
    }

    function testRevert_say_emptyReferrer_incorrectTag() public {
        bytes memory _data = abi.encode("", "This is an optional field for onchain JSON", Metadata(1, "Qm..."));

        vm.expectRevert("Post not validated by referrer");

        vm.prank(someGuy, someGuy);
        _sayeth.sayeth(address(_emptyReferrer), _data, false);
    }

    function testRevert_say_notStaked() public {
        vm.expectRevert("Post not validated by referrer");

        _sayeth.sayeth(address(_stakeReferrer), abi.encode("hello world computer"), false);
    }

    function testRevert_scribe_notStaked() public {
        vm.expectRevert("Post not validated by referrer");

        _sayeth.sayeth(address(_stakeReferrer), abi.encode("hello world computer"), true);
    }

    function testRevert_say_withdrawn() public {
        vm.warp(block.timestamp + ONE_WEEK + 1);

        vm.startPrank(staker1, staker1);
        _stakeReferrer.withdraw();

        vm.expectRevert("Post not validated by referrer");
        _sayeth.sayeth(address(_stakeReferrer), abi.encode("hello world computer"), false);
        vm.stopPrank();
    }

    function _stake(address _staker) public {
        vm.startPrank(_staker);
        _token.approve(address(_stakeReferrer), STAKE_AMT);
        _stakeReferrer.stake(STAKE_AMT);
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
