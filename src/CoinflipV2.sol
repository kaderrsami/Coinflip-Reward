// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

import {Initializable} from "@openzeppelin-upgradeable/contracts-upgradeable/proxy/utils/Initializable.sol";
import {OwnableUpgradeable} from "@openzeppelin-upgradeable/contracts-upgradeable/access/OwnableUpgradeable.sol";
import {UUPSUpgradeable} from "@openzeppelin-upgradeable/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";

error SeedTooShort();

contract CoinflipV2 is Initializable, OwnableUpgradeable, UUPSUpgradeable {
    
    string public seed;

    /// @custom:oz-upgrades-unsafe-allow constructor
    constructor() {
        _disableInitializers();
    }

    function initialize(address initialOwner) initializer public {
        __Ownable_init(initialOwner);
        __UUPSUpgradeable_init();
        seed = "It is a good practice to rotate seeds often in gambling";
    }

    function _authorizeUpgrade(address newImplementation)
        internal
        override
        onlyOwner
    {}

    function userInput(uint8[10] calldata Guesses) external view returns (bool) {
        uint8[10] memory flips = getFlips();
        for (uint i = 0; i < 10; i++) {
            if (Guesses[i] != flips[i]) {
                return false;
            }
        }
        return true;
    }

    /// @notice Updated seedRotation logic (modify as needed).
    function seedRotation(string memory NewSeed) public onlyOwner {
        // For example, you might want to perform a rotation on the string:
        bytes memory newSeedBytes = bytes(NewSeed);
        if (newSeedBytes.length < 10) {
            revert SeedTooShort();
        }
        // Implement your new rotation logic here.
        // This is just a placeholder example that assigns the new seed directly.
        seed = NewSeed;
    }

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
