// SPDX-License-Identifier: MIT
pragma solidity ^0.8.22;

import "forge-std/Script.sol";
import "../src/Dauphine.sol";

contract DeployDauphine is Script {
    function run() external {
        // Load your deployer’s private key from an environment variable.
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        
        // Begin broadcasting transactions using the deployer's key.
        vm.startBroadcast(deployerPrivateKey);
        
        // Deploy the token. Here, we pass the deployer’s address as the token owner.
        Dauphine token = new Dauphine(vm.addr(deployerPrivateKey));
        
        // End broadcasting transactions.
        vm.stopBroadcast();
        
        // Log the address of the deployed token.
        console.log("Dauphine token deployed at:", address(token));
    }
}
