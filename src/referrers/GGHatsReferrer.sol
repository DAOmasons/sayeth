// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import {IReferrer} from "../interfaces/IReferrer.sol";

import {IHats} from "lib/hats-protocol/src/Interfaces/IHats.sol";
import {Metadata} from "src/utils/Metadata.sol";

contract GGHatsReferrer is IReferrer {
    event RegisterHat(uint256 hatId, bool valid);

    IHats hats;

    uint256 public adminHatId;
    mapping(uint256 => bool) public validHatIds;

    modifier onlyAdmin() {
        require(isValidWearer(msg.sender, adminHatId), "GGReferrer: not admin");
        _;
    }

    constructor(uint256[] memory _validHatIds, address _hats, uint256 _adminHatId) {
        hats = IHats(_hats);

        adminHatId = _adminHatId;

        for (uint256 i = 0; i < _validHatIds.length; i++) {
            validHatIds[_validHatIds[i]] = true;
            emit RegisterHat(_validHatIds[i], true);
        }
    }

    function validatePost(address _sender, bytes memory _content) external view override returns (bool) {
        (,,, uint256 _hatId) = abi.decode(_content, (string, string, Metadata, uint256));

        bool hatExists = validHatIds[_hatId];

        if (!hatExists) {
            return false;
        }

        return isValidWearer(_sender, _hatId);
    }

    function registerHat(uint256 _hatId, bool _valid) external onlyAdmin {
        validHatIds[_hatId] = _valid;
        emit RegisterHat(_hatId, _valid);
    }

    function isValidWearer(address _wearer, uint256 _hatId) public view returns (bool) {
        return hats.isWearerOfHat(_wearer, _hatId) && hats.isInGoodStanding(_wearer, _hatId);
    }
}
