// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

interface IReferrer {
    function validatePost(address poster, address origin, bytes calldata content) external returns (bool);
}

struct Record {
    address poster;
    address origin;
    bytes content;
    address referrer;
}

contract Sayeth {
    event Say(address referrer, address poster, address origin, bytes content);
    event Scribe(address referrer, address poster, address origin, bytes content, uint256 index);

    Record[] public records;

    function sayeth(address _referrer, bytes calldata _content, bool _store) public {
        require(IReferrer(_referrer).validatePost(msg.sender, tx.origin, _content), "Post not validated by referrer");

        if (_store) {
            records.push(Record(msg.sender, tx.origin, _content, _referrer));
            emit Scribe(_referrer, msg.sender, tx.origin, _content, records.length - 1);
        } else {
            emit Say(_referrer, msg.sender, tx.origin, _content);
        }
    }
}
