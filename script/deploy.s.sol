// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import {Script, console2} from "forge-std/Script.sol";
import {stdJson} from "forge-std/StdJson.sol";
import {Sayeth} from "src/Sayeth.sol";
import {GGEmptyReferrer} from "src/referrers/GGEmptyReferrer.sol";

contract Deploy is Script {
    string _network;

    using stdJson for string;

    string root = vm.projectRoot();

    string DEPLOYMENTS_DIR = string.concat(root, "/deployments/main.json");

    function run() external {
        uint256 pk = vm.envUint("PRIVATE_KEY");
        address deployer = vm.rememberKey(pk);

        _setEnvString();

        vm.startBroadcast(deployer);

        _deploySayeth();
        _deployEmptyReferrer();

        vm.stopBroadcast();
    }

    function _setEnvString() internal {
        uint256 key;

        assembly {
            key := chainid()
        }

        _network = vm.toString(key);
    }

    function _deploySayeth() internal {
        Sayeth _sayeth = new Sayeth();

        vm.writeJson(vm.toString(address(_sayeth)), DEPLOYMENTS_DIR, string.concat(".", _network));

        console2.log("Deployed Sayeth at address: ", address(_sayeth));
    }

    function _deployEmptyReferrer() internal {
        GGEmptyReferrer _emptyReferrer = new GGEmptyReferrer();

        console2.log("Deployed Sayeth at address: ", address(_emptyReferrer));
    }
}

// 0x0000000000000000000000000000000000004A75
