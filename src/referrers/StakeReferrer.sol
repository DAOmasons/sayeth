// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import {IReferrer} from "../interfaces/IReferrer.sol";
import {IERC20} from "lib/forge-std/src/interfaces/IERC20.sol";

struct Stake {
    uint256 amount;
    uint256 timestamp;
    bool isStaked;
}

contract StakeReferrer is IReferrer {
    event Staked(address user, uint256 amount);
    event Withdrawn(address user, uint256 amount);
    event StakePermitted(address user, bool permitted);

    IERC20 public stakingToken;

    // Staking settings
    uint256 public stakeAmt;
    uint256 public stakingPeriod;

    mapping(address => Stake) public stakes;

    constructor(address _stakingToken, uint256 _stakeAmt, uint256 _stakingPeriod) {
        stakingToken = IERC20(_stakingToken);
        stakeAmt = _stakeAmt;
        stakingPeriod = _stakingPeriod;
    }

    function stake(address _referrer) public payable {}

    function validatePost(address _sender, address _origin, bytes calldata _content) external override returns (bool) {
        return true;
    }
}
