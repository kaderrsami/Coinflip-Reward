// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

// Import Foundry's Script utilities
import "forge-std/Script.sol";

// Import your token and game contracts (adjust paths as needed)
import "../src/Dauphine.sol";    // The ERC20 token contract
import "../src/Coinflip.sol";     // V1 contract
import "../src/CoinflipV2.sol";   // V2 contract
import "../src/Proxy.sol";        // UUPSProxy contract

contract SimulateGame is Script {
    function run() external {
        // Read the deployer's private key from the environment.
        uint256 deployerKey = vm.envUint("PRIVATE_KEY");
        // Compute the owner address from the deployer key.
        address owner = vm.addr(deployerKey);
        // Define two simulated user addresses:
        // 'user' will play the game, and 'friend' will receive a token transfer later.
        address user = vm.addr(100);
        address friendAddr = vm.addr(101);
        
        vm.startBroadcast(deployerKey);
        
        // ───────────────────────────────────────────────
        // 1. Deploy the Dauphine token contract.
        // For simplicity, we pass the computed owner as the initial owner.
        Dauphine token = new Dauphine(owner);
        console.log("Dauphine token deployed at:", address(token));
        
        // ───────────────────────────────────────────────
        // 2. Deploy the Coinflip V1 implementation and proxy.
        Coinflip v1Implementation = new Coinflip();
        // Prepare initialization data for V1 (which takes (address initialOwner, address tokenAddress)).
        bytes memory initData = abi.encodeWithSignature(
            "initialize(address,address)",
            owner,           // Use the computed owner address
            address(token)   // token address
        );
        // Deploy the UUPS proxy with the V1 implementation.
        UUPSProxy proxy = new UUPSProxy(address(v1Implementation), initData);
        console.log("Coinflip V1 proxy deployed at:", address(proxy));
        
        // Wrap the proxy address as a Coinflip contract instance (V1).
        Coinflip wrappedV1 = Coinflip(address(proxy));
        
        // ───────────────────────────────────────────────
        // 3. Simulate a winning play on V1.
        // Hardcode the winning guess array.
        uint8[10] memory winningGuess = [uint8(1), 1, 1, 1, 1, 1, 1, 1, 1, 1];
        // Call userInput with the winning guess; this should trigger RewardUser and mint 5 tokens to 'user'.
        bool winV1 = wrappedV1.userInput(winningGuess, user);
        console.log("V1 game won:", winV1);
        
        // Check the user's token balance after V1 win.
        uint256 balanceAfterV1 = token.balanceOf(user);
        console.log("User balance after V1 win (should be 5 tokens, scaled by decimals):", balanceAfterV1);
        
        // ───────────────────────────────────────────────
        // 4. Upgrade the game to V2.
        CoinflipV2 v2Implementation = new CoinflipV2();
        // Make sure the owner calls the upgrade function.
        vm.prank(owner);
        wrappedV1.upgradeToAndCall(address(v2Implementation), "");
        console.log("Upgraded proxy to Coinflip V2.");
        
        // Now wrap the same proxy as a V2 contract.
        CoinflipV2 wrappedV2 = CoinflipV2(address(proxy));
        
        // ───────────────────────────────────────────────
        // 5. Simulate a winning play on V2.
        // Call userInput on the V2 contract with the winning guess.
        bool winV2 = wrappedV2.userInput(winningGuess, user);
        console.log("V2 game won:", winV2);
        
        // After the win on V2, the user should receive an additional 5 tokens (total 10).
        uint256 balanceAfterV2 = token.balanceOf(user);
        console.log("User balance after V2 win (should be 10 tokens, scaled by decimals):", balanceAfterV2);
        
        // ───────────────────────────────────────────────
        // 6. Simulate token transfer: the user sends some Dauphine tokens to their friend.
        // Impersonate the user to perform the transfer.
        vm.startPrank(user);
        // For example, transfer 3 tokens (adjust for decimals: 3 * 10^18 if using 18 decimals).
        uint256 transferAmount = 3 * 10 ** 18;
        token.transfer(friendAddr, transferAmount);
        vm.stopPrank();
        
        // Check final balances of both accounts (log them directly to reduce stack usage).
        console.log("User final balance after transfer:", token.balanceOf(user));
        console.log("Friend balance after receiving tokens:", token.balanceOf(friendAddr));
        
        vm.stopBroadcast();
    }
}
