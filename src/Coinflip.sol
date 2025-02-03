// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

import {Initializable} from "@openzeppelin-upgradeable/contracts-upgradeable/proxy/utils/Initializable.sol";
import {OwnableUpgradeable} from "@openzeppelin-upgradeable/contracts-upgradeable/access/OwnableUpgradeable.sol";
import {UUPSUpgradeable} from "@openzeppelin-upgradeable/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";
import {Dauphine} from "./Dauphine.sol";
import "./Errors.sol";


// error SeedTooShort();


/// @title Coinflip 10 in a Row (Upgradeable)
/// @notice This contract implements a simple coin flip game where the user must correctly guess 10 coin flips in a row.
contract Coinflip is Initializable, OwnableUpgradeable, UUPSUpgradeable {
    
    // The seed string used to generate pseudo-random coin flips.
    string public seed;
    // Instance of the separately deployed Dauphine token.
    Dauphine public dauphine;

    /// @custom:oz-upgrades-unsafe-allow constructor
    constructor() {
        _disableInitializers();
    }

    /// @notice Initializes the contract, setting the owner, the initial seed, and the token address.
    /// @param initialOwner The address that will become the owner.
    /// @param tokenAddress The address of the deployed Dauphine token.
    function initialize(address initialOwner, address tokenAddress) initializer public {
        __Ownable_init(initialOwner);
        __UUPSUpgradeable_init();
        // Set the seed to a recommended initial string.
        seed = "It is a good practice to rotate seeds often in gambling";
        // Initialize the token instance.
        dauphine = Dauphine(tokenAddress);
    }

    /// @notice Required function to authorize upgrades.
    function _authorizeUpgrade(address newImplementation)
        internal
        override
        onlyOwner
    {}

    /// @notice Internal function to reward the winning user with 5 Dauphine tokens.
    /// @param winner The address of the winning user.
    function RewardUser(address winner) internal {
        // Mint 5 tokens (assuming 18 decimals)
        dauphine.mint(winner, 5 * 10 ** 18);
    }

    /// @notice Checks user input against contract-generated coin flips and rewards the user if correct.
    /// @param Guesses A fixed array of 10 elements representing the user's guesses.
    /// @param winner The address of the user to reward if the guess is correct.
    /// @return true if all guesses match, false otherwise.
    function userInput(uint8[10] calldata Guesses, address winner) external returns (bool) {
        uint8[10] memory flips = getFlips();
        for (uint i = 0; i < 10; i++) {
            if (Guesses[i] != flips[i]) {
                return false;
            }
        }
        RewardUser(winner);
        return true;
    }

    /// @notice Allows the owner to update the seed.
    /// @param NewSeed The new seed string.
    function seedRotation(string memory NewSeed) public onlyOwner {
        bytes memory newSeedBytes = bytes(NewSeed);
        if (newSeedBytes.length < 10) {
            revert SeedTooShort();
        }
        seed = NewSeed;
    }

    /// @notice Generates 10 predictable coin flips.
    /// @return A fixed array of 10 coin flip results (always winning).
    function getFlips() public pure returns (uint8[10] memory) {
        // Hardcoded for predictability: all ones (i.e. a winning outcome when user guesses [1,1,...,1])
        return [uint8(1), 1, 1, 1, 1, 1, 1, 1, 1, 1];
    }
}
