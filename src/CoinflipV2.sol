// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

import {Initializable} from "@openzeppelin-upgradeable/contracts-upgradeable/proxy/utils/Initializable.sol";
import {OwnableUpgradeable} from "@openzeppelin-upgradeable/contracts-upgradeable/access/OwnableUpgradeable.sol";
import {UUPSUpgradeable} from "@openzeppelin-upgradeable/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";
import {Dauphine} from "./Dauphine.sol";
import "./Errors.sol";


// error SeedTooShort();

contract CoinflipV2 is Initializable, OwnableUpgradeable, UUPSUpgradeable {
    
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
        seed = "It is a good practice to rotate seeds often in gambling";
        dauphine = Dauphine(tokenAddress);
    }

    function _authorizeUpgrade(address newImplementation)
        internal
        override
        onlyOwner
    {}

    /// @notice Internal function to reward the winning user with 5 Dauphine tokens.
    /// @param winner The address of the winning user.
    function RewardUser(address winner) internal {
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

    /// @notice Updated seedRotation logic that rotates the provided seed string.
    /// @param NewSeed The new seed string.
    /// @param shift The number of characters to rotate the seed by.
    function seedRotation(string memory NewSeed, uint shift) public onlyOwner {
        bytes memory seedBytes = bytes(NewSeed);
        if (seedBytes.length < 10) {
            revert SeedTooShort();
        }
        uint len = seedBytes.length;
        // Normalize shift to ensure it is within the length.
        uint s = shift % len;
        bytes memory rotated = new bytes(len);
        // Copy the tail (from position s to end) to the beginning.
        for (uint i = 0; i < len - s; i++) {
            rotated[i] = seedBytes[i + s];
        }
        // Copy the beginning of the string to the end.
        for (uint i = 0; i < s; i++) {
            rotated[len - s + i] = seedBytes[i];
        }
        seed = string(rotated);
    }

    /// @notice Generates 10 predictable coin flips.
    /// @return A fixed array of 10 coin flip results (always winning).
    function getFlips() public pure returns (uint8[10] memory) {
        // Hardcoded for predictability: always return [1,1,...,1]
        return [uint8(1), 1, 1, 1, 1, 1, 1, 1, 1, 1];
    }
}
