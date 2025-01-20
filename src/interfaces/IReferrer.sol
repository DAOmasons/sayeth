// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

interface IReferrer {
    function validatePost(address sender, address origin, bytes calldata content) external returns (bool);
}
