// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import {IReferrer} from "./interfaces/IReferrer.sol";

struct Record {
    address sender;
    address origin;
    bytes content;
    address referrer;
}

contract Sayeth {
    event Say(address referrer, address sender, address origin, bytes content);
    event Scribe(address referrer, address sender, address origin, bytes content, uint256 index);

    Record[] public records;

    function sayeth(address _referrer, bytes calldata _content, bool _store) public {
        if (_referrer != address(0)) {
            require(
                IReferrer(_referrer).validatePost(msg.sender, tx.origin, _content), "Post not validated by referrer"
            );
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

    function getRecordAmt() public view returns (uint256) {
        return records.length;
    }
}
