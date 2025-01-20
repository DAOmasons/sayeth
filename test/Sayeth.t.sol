// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import {Sayeth, Record} from "../../src/Sayeth.sol";

import {Test, console} from "forge-std/Test.sol";

contract SayethTest is Test {
    event Say(address referrer, address sender, address origin, bytes content);
    event Scribe(address referrer, address sender, address origin, bytes content, uint256 index);

    Sayeth public _sayeth;

    function setUp() public {
        _sayeth = new Sayeth();
    }

    function testSay_publicChannel() public {
        _say();
    }

    function testScribe_publicChannel() public {
        _scribe();

        Record memory record = _sayeth.getRecord(0);

        assertEq(record.sender, address(1));
        assertEq(record.origin, address(1));
        assertEq(record.content, abi.encode("hello world computer"));
        assertEq(record.referrer, address(0));
        assertEq(_sayeth.getRecordAmt(), 1);
    }

    function _say() public {
        vm.expectEmit(true, false, false, true);

        emit Say(address(0), address(1), address(1), abi.encode("hello world computer"));

        vm.prank(address(1), address(1));
        _sayeth.sayeth(address(0), abi.encode("hello world computer"), false);
    }

    function _scribe() public {
        vm.expectEmit(true, false, false, true);

        emit Scribe(address(0), address(1), address(1), abi.encode("hello world computer"), 0);

        vm.prank(address(1), address(1));
        _sayeth.sayeth(address(0), abi.encode("hello world computer"), true);
    }
}
