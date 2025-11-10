// SPDX-License-Identifier: MIT
pragma solidity ^0.8.25;

/* ─────────────────────────────────────────────────────────────────────────────
 *  UNYKORN MULTI-TLD SUITE  v1.0.0
 *  ---------------------------------------------------------------------------
 *  ▸ Soul-bound root TLD token (ERC-721, tokenId=0) – non-transferable         
 *  ▸ Unlimited sub-domain NFTs (ERC-721) – transferable OR soul-bound          
 *  ▸ ERC-6551 vault view for every token                                       
 *  ▸ Optional on-chain / IPFS metadata                                         
 *  ▸ Plug-in yield + derivative layer hooks (see IVaultYield & IDerivative)    
 *  ▸ Factory contract deploys new TLDs in one TX                               
 *                                                                              
 *  Designed for Remix or Hardhat deployments – no external libs except OZ.     
 *  ------------------------------------------------------------------------ */

// ──────────────────────────────────────────────────────────── OpenZeppelin ───
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/v5.0.1/contracts/token/ERC721/ERC721.sol";
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/v5.0.1/contracts/access/Ownable.sol";
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/v5.0.1/contracts/security/ReentrancyGuard.sol";
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/v5.0.1/contracts/utils/Strings.sol";

// ──────────────────────────────────────────────────────────────── Interfaces ─
/// @dev Minimal ERC-6551 registry interface (standard reference @ 0x02101dfB77FDE026414827Fdc604ddAF224F0921 on Polygon)
interface IERC6551Registry {
    function account(address implementation, uint256 chainId, address tokenContract, uint256 tokenId, uint256 salt)
        external
        view
        returns (address);
}

/// @dev Optional yield engine interface – implement off-chain or in new contract
interface IVaultYield {
    function accrue(address nft, uint256 tokenId) external;
}

/// @dev Optional derivative token interface – e.g., ERC-20 wrapper per subdomain
interface IDerivative {
    function mint(address to, uint256 amount) external;
}

// ───────────────────────────────────────────────────────────── Utils / Meta ──
contract MetadataResolver {
    using Strings for uint256;

    string public baseCID; // If blank → fully on-chain metadata
    string internal svgTemplate;

    constructor(string memory _cid) {
        baseCID = _cid;
        svgTemplate =
            '<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 600 400"><rect width="600" height="400" fill="black"/><text x="50%" y="50%" dominant-baseline="middle" text-anchor="middle" font-size="48" fill="white">';
    }

    function tokenURI(uint256 tokenId, string memory fullDomain) external view returns (string memory) {
        if (bytes(baseCID).length > 0) {
            return string.concat("ipfs://", baseCID, "/", tokenId.toString(), ".json");
        }
        // On-chain JSON + SVG fallback
        string memory svg = string.concat(svgTemplate, fullDomain, '</text></svg>');
        string memory json = string.concat(
            '{"name":"',
            fullDomain,
            '","description":"Soul-bound / sub-domain NFT for ',
            fullDomain,
            '","image":"data:image/svg+xml;base64,',
            _base64(bytes(svg)),
            '"}'
        );
        return string.concat("data:application/json;base64,", _base64(bytes(json)));
    }

    /*───────────────────────────────────────────────────────────── Internal */
    function _base64(bytes memory data) internal pure returns (string memory) {
        string memory table = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/";
        uint256 len = data.length;
        if (len == 0) return "";
        string memory result = new string(4 * ((len + 2) / 3));
        bytes memory tableBytes = bytes(table);
        bytes memory resultBytes = bytes(result);
        uint256 i = 0;
        uint256 j = 0;
        for (; i + 3 <= len; i += 3) {
            (resultBytes[j], resultBytes[j + 1], resultBytes[j + 2], resultBytes[j + 3]) = _encode3(
                uint8(data[i]),
                uint8(data[i + 1]),
                uint8(data[i + 2]),
                tableBytes
            );
            j += 4;
        }
        if ((len - i) == 1) {
            (resultBytes[j], resultBytes[j + 1], resultBytes[j + 2], resultBytes[j + 3]) = _encode1(uint8(data[i]), tableBytes);
        } else if ((len - i) == 2) {
            (resultBytes[j], resultBytes[j + 1], resultBytes[j + 2], resultBytes[j + 3]) =
                _encode2(uint8(data[i]), uint8(data[i + 1]), tableBytes);
        }
        return string(resultBytes);
    }

    function _encode3(uint8 a0, uint8 a1, uint8 a2, bytes memory table)
        internal
        pure
        returns (bytes1, bytes1, bytes1, bytes1)
    {
        uint24 input = (uint24(a0) << 16) | (uint24(a1) << 8) | uint24(a2);
        return (
            table[(input >> 18) & 63],
            table[(input >> 12) & 63],
            table[(input >> 6) & 63],
            table[input & 63]
        );
    }

    function _encode2(uint8 a0, uint8 a1, bytes memory table)
        internal
        pure
        returns (bytes1, bytes1, bytes1, bytes1)
    {
        uint24 input = (uint24(a0) << 10) | (uint24(a1) << 2);
        return (table[(input >> 12) & 63], table[(input >> 6) & 63], table[input & 63], '=');
    }

    function _encode1(uint8 a0, bytes memory table) internal pure returns (bytes1, bytes1, bytes1, bytes1) {
        uint24 input = uint24(a0) << 4;
        return (table[(input >> 6) & 63], table[input & 63], '=', '=');
    }
}

// ───────────────────────────────────────────────────────────── Sub-Registry ──
contract SubdomainRegistry is Ownable {
    mapping(bytes32 => address) public owners; // labelHash ➝ owner
    event SubdomainRegistered(string label, address indexed owner);

    function register(bytes32 labelHash, address subOwner) external onlyOwner {
        owners[labelHash] = subOwner;
        emit SubdomainRegistered(string(abi.encodePacked(labelHash)), subOwner);
    }

    function ownerOfLabel(string calldata label) external view returns (address) {
        return owners[keccak256(bytes(label))];
    }
}

// ──────────────────────────────────────────────────────────────── SBT TLD ────
contract SoulboundTLD is ERC721, Ownable, ReentrancyGuard {
    using Strings for uint256;

    /* ---------- CONSTANTS ---------- */
    string public constant VERSION = "1.0.0";
    uint256 internal constant ROOT_ID = 0;
    IERC6551Registry internal immutable TBA_REG;

    /* ---------- STORAGE ---------- */
    string public immutable tld; // e.g., ".gold"
    MetadataResolver public resolver;
    SubdomainRegistry public registry;

    mapping(uint256 => bool) public isSoulbound; // tokenId ➝ SBT flag (subdomains)

    /* ---------- EVENTS ---------- */
    event SubdomainMinted(string indexed label, address indexed to, uint256 tokenId, bool soulbound);

    /* ---------- CONSTRUCTOR ---------- */
    constructor(string memory _tld, string memory name_, string memory symbol_, string memory ipfsCID, address _tbaReg)
        ERC721(name_, symbol_)
    {
        require(bytes(_tld).length > 1 && bytes(_tld)[0] == bytes1('.'), "tld format");
        tld = _tld;
        resolver = new MetadataResolver(ipfsCID);
        registry = new SubdomainRegistry();
        _transferOwnership(msg.sender);
        _safeMint(msg.sender, ROOT_ID); // root SBT
        isSoulbound[ROOT_ID] = true;
        TBA_REG = IERC6551Registry(_tbaReg);
    }

    /* ---------- SOUL-BIND OVERRIDES ---------- */
    function _beforeTokenTransfer(address from, address to, uint256 tokenId, uint256)
        internal
        view
        override
    {
        if (isSoulbound[tokenId]) {
            require(from == address(0) || to == address(0), "SBT locked");
        }
    }

    function approve(address, uint256) public pure override { revert("SBT"); }
    function setApprovalForAll(address, bool) public pure override { revert("SBT"); }

    /* ---------- SUBDOMAIN MINTING ---------- */
    function mintSubdomain(address to, string calldata label, bool soulbound) external onlyOwner nonReentrant returns (uint256) {
        require(bytes(label).length > 0, "label");
        bytes32 labelHash = keccak256(bytes(_toLower(label)));
        require(registry.owners(labelHash) == address(0), "taken");
        uint256 tokenId = uint256(labelHash);
        _safeMint(to, tokenId);
        if (soulbound) isSoulbound[tokenId] = true;

        registry.register(labelHash, to);
        emit SubdomainMinted(label, to, tokenId, soulbound);
        return tokenId;
    }

    /* ---------- METADATA ---------- */
    function tokenURI(uint256 tokenId) public view override returns (string memory) {
        string memory fullDomain;
        if (tokenId == ROOT_ID) {
            fullDomain = tld;
        } else {
            fullDomain = string.concat("<label>", tld); // Off-chain indexer should map correctly
        }
        return resolver.tokenURI(tokenId, fullDomain);
    }

    /* ---------- ERC-6551 VIEW ---------- */
    function vaultOf(uint256 tokenId) public view returns (address) {
        return TBA_REG.account(address(0), block.chainid, address(this), tokenId, 0);
    }

    /* ---------- INTERNAL UTILS ---------- */
    function _toLower(string memory str) internal pure returns (string memory) {
        bytes memory bStr = bytes(str);
        bytes memory bLower = new bytes(bStr.length);
        for (uint256 i = 0; i < bStr.length; i++) {
            // Uppercase characters are 65-90
            if (uint8(bStr[i]) >= 65 && uint8(bStr[i]) <= 90) {
                bLower[i] = bytes1(uint8(bStr[i]) + 32);
            } else {
                bLower[i] = bStr[i];
            }
        }
        return string(bLower);
    }
}

// ──────────────────────────────────────────────────────────────── FACTORY ────
contract TLDFactory is Ownable {
    event TLDDeployed(address indexed tldAddress, string tld);

    IERC6551Registry public immutable TBA_REG;

    constructor(address _tbaReg) {
        TBA_REG = IERC6551Registry(_tbaReg);
    }

    function deployTLD(
        string calldata _tld,
        string calldata _name,
        string calldata _symbol,
        string calldata _ipfsCID
    ) external onlyOwner returns (address) {
        SoulboundTLD tldContract = new SoulboundTLD(_tld, _name, _symbol, _ipfsCID, address(TBA_REG));
        tldContract.transferOwnership(msg.sender); // hand over control
        emit TLDDeployed(address(tldContract), _tld);
        return address(tldContract);
    }
}

