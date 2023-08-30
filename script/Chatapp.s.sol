// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Script, console2} from "../lib/forge-std/src/Script.sol";

contract ChatappScript is Script {
    function setUp() public {}

    function run() public {
        vm.broadcast();
    }
}
