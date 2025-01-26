// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

interface IReferrer {
    function validatePost(address sender, bytes calldata content) external returns (bool);
}
