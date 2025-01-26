// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import {IReferrer} from "../interfaces/IReferrer.sol";
import {IERC20} from "lib/openzeppelin-contracts/contracts/token/ERC20/IERC20.sol";
import {ReentrancyGuard} from "lib/openzeppelin-contracts/contracts/utils/ReentrancyGuard.sol";
import {Ownable} from "lib/openzeppelin-contracts/contracts/access/Ownable.sol";

struct Stake {
    uint256 amount;
    uint256 timestamp;
    bool isStaked;
}

contract StakeReferrer is ReentrancyGuard, Ownable, IReferrer {
    event Staked(address user, uint256 amount);
    event Withdrawn(address user, uint256 amount);
    event StakePermitted(address user, bool permitted);

    IERC20 public stakingToken;

    // Staking settings
    uint256 public stakeAmt;
    uint256 public stakingPeriod;

    mapping(address => Stake) public stakes;

    constructor(address _stakingToken, uint256 _stakeAmt, uint256 _stakingPeriod, address initialOwner)
        Ownable(initialOwner)
    {
        stakingToken = IERC20(_stakingToken);
        stakeAmt = _stakeAmt;
        stakingPeriod = _stakingPeriod;
    }

    function stake(uint256 _amount) external nonReentrant {
        require(_amount == stakeAmt, "Invalid stake amount");
        require(stakes[msg.sender].isStaked == false, "Already staked");

        require(stakingToken.transferFrom(msg.sender, address(this), _amount), "Transfer failed");

        stakes[msg.sender] = Stake(_amount, block.timestamp, true);

        emit Staked(msg.sender, _amount);
    }

    function withdraw() external nonReentrant {
        Stake storage userStake = stakes[msg.sender];
        require(userStake.isStaked, "Not staked");
        require(block.timestamp >= userStake.timestamp + stakingPeriod, "Staking period not over");

        uint256 amount = userStake.amount;

        delete stakes[msg.sender];

        require(stakingToken.transfer(msg.sender, amount), "Transfer failed");

        emit Withdrawn(msg.sender, amount);
    }

    function updateMinimumStake(uint256 _newAmt) external onlyOwner {
        stakeAmt = _newAmt;
    }

    function updateStakingPeriod(uint256 _newPeriod) external onlyOwner {
        stakingPeriod = _newPeriod;
    }

    function validatePost(address _sender, bytes calldata) public view returns (bool) {
        return stakes[_sender].isStaked;
    }
}
