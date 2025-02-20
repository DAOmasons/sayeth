// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import {Script, console2} from "forge-std/Script.sol";
import {stdJson} from "forge-std/StdJson.sol";
import {Sayeth} from "src/Sayeth.sol";
import {GGEmptyReferrer} from "src/referrers/GGEmptyReferrer.sol";
import {GGHatsReferrer} from "src/referrers/GGHatsReferrer.sol";

contract Deploy is Script {
    string _network;

    using stdJson for string;

    string root = vm.projectRoot();

    string DEPLOYMENTS_DIR = string.concat(root, "/deployments/main.json");

    mapping(string => uint256) adminIds;

    function run() external {
        uint256 pk = vm.envUint("PRIVATE_KEY");
        address deployer = vm.rememberKey(pk);

        _setEnvString();

        vm.startBroadcast(deployer);

        // _deploySayeth();
        // _deployEmptyReferrer();

        _deployHatsReferrer();

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

    function _deployHatsReferrer() internal {
        adminIds["421614"] = 2372476540837674292835228943884614417292947446235469603522015213387776;
        adminIds["42161"] = 2048956358079587954696203685355787570534049221797049916958840216092672;

        uint256[] memory hatIds = new uint256[](1);
        address hatsAddress = 0x3bc1A0Ad72417f2d411118085256fC53CBdDd137;

        uint256 networkAdminId = adminIds[_network];

        if (networkAdminId == 0) {
            console2.log("No admin id found for network: ", _network);
            return;
        }
        hatIds[0] = networkAdminId;

        GGHatsReferrer hatsRefferer = new GGHatsReferrer(hatIds, hatsAddress, networkAdminId);

        console2.log("Deployed GGHatsReferrer at address: ", address(hatsRefferer));
    }
}
// 0x3bc1A0Ad72417f2d411118085256fC53CBdDd137
