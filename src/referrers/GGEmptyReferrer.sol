// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import {IReferrer} from "../interfaces/IReferrer.sol";
import {Metadata} from "src/utils/Metadata.sol";

contract GGEmptyReferrer is IReferrer {
    // this contract is designed to provide a segmented channel for posts that:
    // - creates a targeted channel for posts
    // - Maintain a specific model for posts data
    // - allows a structure for both onchain storage(fast retrieval) and offchain storage(large data)
    // - allows permissionless posting
    function validatePost(address, bytes memory _content) external pure override returns (bool) {
        // 1. tag is required. It provides specific instructions to the indexer
        // 2. onchainStorage is optional. It's for fast retrieval for display in UI without having to resolve offchain storage
        // 3. Metadata is required. It provides a configure storage directions for larger offchain storage

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
