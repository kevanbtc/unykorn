// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

/// @title SensorNFT
/// @notice NFT representing physical sensors sold by CTRL Systems
contract SensorNFT is ERC721URIStorage, Ownable {
    uint256 private _nextId = 1;

    struct SensorData {
        string deviceType; // UL101 or HHC
        string serialNumber;
        string calibration;
        string maintenanceLog;
    }

    mapping(uint256 => SensorData) private _sensors;

    constructor() ERC721("CTRL Sensor", "SENS") {}

    function mint(address to, SensorData memory data, string memory tokenURI) external onlyOwner returns (uint256) {
        uint256 id = _nextId++;
        _safeMint(to, id);
        _setTokenURI(id, tokenURI);
        _sensors[id] = data;
        return id;
    }

    function getSensor(uint256 id) external view returns (SensorData memory) {
        return _sensors[id];
    }
}
