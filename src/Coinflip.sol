// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

// Import upgradeable contracts instead of their non-upgradeable counterparts.
import {Initializable} from "@openzeppelin-upgradeable/contracts-upgradeable/proxy/utils/Initializable.sol";
import {OwnableUpgradeable} from "@openzeppelin-upgradeable/contracts-upgradeable/access/OwnableUpgradeable.sol";
import {UUPSUpgradeable} from "@openzeppelin-upgradeable/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";

// Custom error to indicate that the new seed is too short
error SeedTooShort();

/// @title Coinflip 10 in a Row (Upgradeable)
/// @notice This contract implements a simple coin flip game where the user must correctly guess 10 coin flips in a row.
contract Coinflip is Initializable, OwnableUpgradeable, UUPSUpgradeable {
    
    // The seed string used to generate pseudo-random coin flips.
    string public seed;

    /// @custom:oz-upgrades-unsafe-allow constructor
    constructor() {
        _disableInitializers();
    }

    /// @notice Initializes the contract, setting the owner and the initial seed.
    /// @param initialOwner The address that will become the owner.
    function initialize(address initialOwner) initializer public {
        __Ownable_init(initialOwner);
        __UUPSUpgradeable_init();
        // Set the seed to a recommended initial string.
        seed = "It is a good practice to rotate seeds often in gambling";
    }

    /// @notice Required function to authorize upgrades.
    function _authorizeUpgrade(address newImplementation)
        internal
        override
        onlyOwner
    {}

    /// @notice Checks user input against contract generated coin flips.
    /// @param Guesses A fixed array of 10 elements representing the user's guesses.
    /// @return true if all guesses match, false otherwise.
    function userInput(uint8[10] calldata Guesses) external view returns (bool) {
        uint8[10] memory flips = getFlips();
        for (uint i = 0; i < 10; i++) {
            if (Guesses[i] != flips[i]) {
                return false;
            }
        }
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

    /// @notice Generates 10 pseudo-random coin flips based on the seed.
    /// @return A fixed array of 10 coin flip results.
    function getFlips() public view returns (uint8[10] memory) {
        bytes memory seedBytes = bytes(seed);
        uint seedlength = seedBytes.length;
        uint8[10] memory results;
        uint interval = seedlength / 10;
        for (uint i = 0; i < 10; i++) {
            uint randomNum = uint(keccak256(abi.encode(seedBytes[i * interval], block.timestamp)));
            results[i] = randomNum % 2 == 0 ? 1 : 0;
        }
        return results;
    }
}
