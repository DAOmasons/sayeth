// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import {IReferrer} from "../interfaces/IReferrer.sol";
import {Metadata} from "src/utils/Metadata.sol";

contract GGEmptyReferrer is IReferrer {
    function validatePost(address, bytes memory _content) external pure override returns (bool) {
        (string memory _tag,, Metadata memory _storage) = abi.decode(_content, (string, string, Metadata));

        // tag is required
        if (bytes(_tag).length == 0) {
            return false;
        }

        // Metadata is required
        if (_storage.protocol == 0) {
            return false;
        }

        return true;
    }
}
