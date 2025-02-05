// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import {IReferrer} from "./interfaces/IReferrer.sol";

struct Record {
    address sender; // The address of the sender (contract or EOA)
    address origin; // The address of the origin (original sender)
    bytes content; // The bytes content of the message
    address referrer; // The address of the referrer contract (if any)
}

contract Sayeth {
    event Say(address referrer, address sender, address origin, bytes content);
    event Scribe(address referrer, address sender, address origin, bytes content, uint256 index);

    Record[] public records;

    function sayeth(address _referrer, bytes memory _content, bool _store) public {
        if (_referrer != address(0)) {
            require(IReferrer(_referrer).validatePost(msg.sender, _content), "Post not validated by referrer");
        }

        if (_store) {
            records.push(Record(msg.sender, tx.origin, _content, _referrer));
            emit Scribe(_referrer, msg.sender, tx.origin, _content, records.length - 1);
        } else {
            emit Say(_referrer, msg.sender, tx.origin, _content);
        }
    }

    function getRecord(uint256 _index) public view returns (Record memory) {
        return records[_index];
    }

    function getRecordLength() public view returns (uint256) {
        return records.length;
    }
}
