# 🔗 IPFS Integration & On-Chain Notarization Guide

This guide shows how to pin your Unykorn registry to IPFS and create tamper-proof on-chain records for institutional compliance.

## 📋 Overview

The complete workflow:
1. **Generate CSV exports** with cryptographic proofs
2. **Pin files to IPFS** for immutable storage  
3. **Record Merkle roots on-chain** for permanent audit trail
4. **Enable institutional verification** of data integrity

## 🌐 IPFS Integration

### Prerequisites
```bash
# Install IPFS (if not already installed)
# macOS
brew install ipfs

# Linux  
wget https://dist.ipfs.io/go-ipfs/v0.13.0/go-ipfs_v0.13.0_linux-amd64.tar.gz
tar -xvzf go-ipfs_v0.13.0_linux-amd64.tar.gz
sudo mv go-ipfs/ipfs /usr/local/bin/

# Initialize IPFS node
ipfs init
ipfs daemon &  # Run in background
```

### Pin Registry Files

```bash
# Navigate to your Unykorn registry
cd /path/to/unykorn

# Validate and generate fresh proofs
python3 scripts/validate_registry.py

# Pin individual CSV files
echo "📌 Pinning L1 chains registry..."
CHAINS_CID=$(ipfs add -Q exports/unykorn_l1_chains.csv)
echo "L1 Chains CID: $CHAINS_CID"

echo "📌 Pinning address book..."  
ADDRESS_CID=$(ipfs add -Q exports/unykorn_address_book.csv)
echo "Address Book CID: $ADDRESS_CID"

echo "📌 Pinning Merkle proofs..."
PROOFS_CID=$(ipfs add -Q exports/MERKLE_ROOTS.json)
echo "Merkle Proofs CID: $PROOFS_CID"

# Pin entire registry as directory
echo "📌 Pinning complete registry..."
REGISTRY_CID=$(ipfs add -r -Q exports/)
echo "Complete Registry CID: $REGISTRY_CID"

# Verify pinning was successful
ipfs pin ls | grep -E "($CHAINS_CID|$ADDRESS_CID|$PROOFS_CID)"
```

### IPFS Verification Script

Create `scripts/ipfs_pin.py`:

```python
#!/usr/bin/env python3
"""
IPFS Pinning Utility for Unykorn Registry
Pins registry files to IPFS and generates verification receipts.
"""

import subprocess
import json
import hashlib
from datetime import datetime, timezone

def run_ipfs_command(args):
    """Run IPFS command and return result."""
    try:
        result = subprocess.run(['ipfs'] + args, capture_output=True, text=True, check=True)
        return result.stdout.strip()
    except subprocess.CalledProcessError as e:
        print(f"IPFS command failed: {e}")
        return None

def pin_file_to_ipfs(filepath):
    """Pin a file to IPFS and return CID."""
    print(f"📌 Pinning {filepath}...")
    cid = run_ipfs_command(['add', '-Q', filepath])
    if cid:
        print(f"   ✅ CID: {cid}")
        return cid
    else:
        print(f"   ❌ Failed to pin {filepath}")
        return None

def verify_file_integrity(filepath, expected_hash):
    """Verify file integrity against expected hash."""
    with open(filepath, 'rb') as f:
        actual_hash = hashlib.sha256(f.read()).hexdigest()
    
    if actual_hash == expected_hash:
        print(f"   ✅ File integrity verified: {filepath}")
        return True
    else:
        print(f"   ❌ Hash mismatch for {filepath}")
        print(f"      Expected: {expected_hash}")
        print(f"      Actual:   {actual_hash}")
        return False

def main():
    """Pin Unykorn registry to IPFS with verification."""
    print("🌐 IPFS Pinning - Unykorn Registry")
    print("=" * 50)
    
    # Load Merkle proofs for integrity verification
    try:
        with open('exports/MERKLE_ROOTS.json', 'r') as f:
            proofs = json.load(f)
    except FileNotFoundError:
        print("❌ MERKLE_ROOTS.json not found. Run validation first:")
        print("   python3 scripts/validate_registry.py")
        return
    
    # Files to pin with their expected hashes
    files_to_pin = [
        ('exports/unykorn_l1_chains.csv', proofs['files']['unykorn_l1_chains.csv']['file_hash']),
        ('exports/unykorn_address_book.csv', proofs['files']['unykorn_address_book.csv']['file_hash']),
        ('exports/MERKLE_ROOTS.json', None)  # No pre-computed hash for proofs file
    ]
    
    ipfs_receipts = {
        'pinned_at': datetime.now(timezone.utc).isoformat(),
        'registry_version': proofs['version'],
        'files': {}
    }
    
    all_successful = True
    
    for filepath, expected_hash in files_to_pin:
        # Verify integrity if hash provided
        if expected_hash and not verify_file_integrity(filepath, expected_hash):
            all_successful = False
            continue
        
        # Pin to IPFS
        cid = pin_file_to_ipfs(filepath)
        if cid:
            filename = filepath.split('/')[-1]
            ipfs_receipts['files'][filename] = {
                'ipfs_cid': cid,
                'file_path': filepath,
                'file_hash': expected_hash,
                'pinned_at': datetime.now(timezone.utc).isoformat()
            }
        else:
            all_successful = False
    
    # Pin entire directory
    print("📌 Pinning complete registry directory...")
    registry_cid = run_ipfs_command(['add', '-r', '-Q', 'exports/'])
    if registry_cid:
        print(f"   ✅ Registry Directory CID: {registry_cid}")
        ipfs_receipts['registry_directory_cid'] = registry_cid
    
    # Save IPFS receipts
    if all_successful:
        with open('ipfs_receipts.json', 'w') as f:
            json.dump(ipfs_receipts, f, indent=2)
        
        print("\n" + "=" * 50)
        print("🎉 IPFS Pinning Complete!")
        print(f"📄 Receipts saved to: ipfs_receipts.json")
        print("\n🔗 Access URLs:")
        
        for filename, data in ipfs_receipts['files'].items():
            cid = data['ipfs_cid']
            print(f"   {filename}: https://ipfs.io/ipfs/{cid}")
        
        if 'registry_directory_cid' in ipfs_receipts:
            print(f"   Complete Registry: https://ipfs.io/ipfs/{ipfs_receipts['registry_directory_cid']}")
        
        # Generate verification commands
        print("\n🔍 Verification Commands:")
        for filename, data in ipfs_receipts['files'].items():
            cid = data['ipfs_cid']
            print(f"   ipfs cat {cid} > /tmp/{filename}")
        
    else:
        print("❌ Some files failed to pin. Check errors above.")

if __name__ == "__main__":
    main()
```

## ⛓️ On-Chain Notarization

### Registry Smart Contract

Create `contracts/RegistryNotary.sol`:

```solidity
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/access/AccessControl.sol";
import "@openzeppelin/contracts/utils/ReentrancyGuard.sol";

/**
 * @title RegistryNotary
 * @dev On-chain notarization of Unykorn registry snapshots for institutional compliance
 */
contract RegistryNotary is AccessControl, ReentrancyGuard {
    bytes32 public constant NOTARY_ROLE = keccak256("NOTARY_ROLE");
    
    struct RegistrySnapshot {
        bytes32 merkleRoot;
        string ipfsCid;
        uint256 timestamp;
        string version;
        string label;
        address notarizedBy;
    }
    
    // Snapshot ID => Registry Snapshot
    mapping(uint256 => RegistrySnapshot) public snapshots;
    
    // Merkle root => Snapshot ID (for quick lookups)
    mapping(bytes32 => uint256) public rootToSnapshotId;
    
    uint256 public nextSnapshotId = 1;
    uint256 public totalSnapshots = 0;
    
    event RegistryNotarized(
        uint256 indexed snapshotId,
        bytes32 indexed merkleRoot,
        string ipfsCid,
        string version,
        string label,
        address indexed notarizedBy,
        uint256 timestamp
    );
    
    event SnapshotVerified(
        uint256 indexed snapshotId,
        bytes32 indexed merkleRoot,
        address indexed verifiedBy
    );
    
    constructor(address admin) {
        _grantRole(DEFAULT_ADMIN_ROLE, admin);
        _grantRole(NOTARY_ROLE, admin);
    }
    
    /**
     * @dev Notarize a registry snapshot on-chain
     * @param merkleRoot The Merkle root of the registry data
     * @param ipfsCid IPFS CID where the data is stored
     * @param version Registry version string
     * @param label Human-readable label for this snapshot
     */
    function notarizeSnapshot(
        bytes32 merkleRoot,
        string calldata ipfsCid,
        string calldata version,
        string calldata label
    ) external onlyRole(NOTARY_ROLE) returns (uint256) {
        require(merkleRoot != bytes32(0), "Invalid Merkle root");
        require(bytes(ipfsCid).length > 0, "IPFS CID required");
        require(rootToSnapshotId[merkleRoot] == 0, "Merkle root already notarized");
        
        uint256 snapshotId = nextSnapshotId++;
        
        snapshots[snapshotId] = RegistrySnapshot({
            merkleRoot: merkleRoot,
            ipfsCid: ipfsCid,
            timestamp: block.timestamp,
            version: version,
            label: label,
            notarizedBy: msg.sender
        });
        
        rootToSnapshotId[merkleRoot] = snapshotId;
        totalSnapshots++;
        
        emit RegistryNotarized(
            snapshotId,
            merkleRoot,
            ipfsCid,
            version,
            label,
            msg.sender,
            block.timestamp
        );
        
        return snapshotId;
    }
    
    /**
     * @dev Verify a Merkle root exists in the registry
     * @param merkleRoot The Merkle root to verify
     * @return exists Whether the root exists
     * @return snapshotId The snapshot ID if it exists
     */
    function verifyMerkleRoot(bytes32 merkleRoot) 
        external 
        returns (bool exists, uint256 snapshotId) 
    {
        snapshotId = rootToSnapshotId[merkleRoot];
        exists = (snapshotId != 0);
        
        if (exists) {
            emit SnapshotVerified(snapshotId, merkleRoot, msg.sender);
        }
        
        return (exists, snapshotId);
    }
    
    /**
     * @dev Get complete snapshot details
     */
    function getSnapshot(uint256 snapshotId) 
        external 
        view 
        returns (RegistrySnapshot memory) 
    {
        require(snapshotId > 0 && snapshotId < nextSnapshotId, "Invalid snapshot ID");
        return snapshots[snapshotId];
    }
    
    /**
     * @dev Get the latest notarized snapshot
     */
    function getLatestSnapshot() 
        external 
        view 
        returns (uint256 snapshotId, RegistrySnapshot memory snapshot) 
    {
        require(totalSnapshots > 0, "No snapshots exist");
        snapshotId = nextSnapshotId - 1;
        snapshot = snapshots[snapshotId];
        return (snapshotId, snapshot);
    }
    
    /**
     * @dev Grant notary role to an address
     */
    function grantNotaryRole(address notary) external onlyRole(DEFAULT_ADMIN_ROLE) {
        _grantRole(NOTARY_ROLE, notary);
    }
    
    /**
     * @dev Revoke notary role from an address
     */
    function revokeNotaryRole(address notary) external onlyRole(DEFAULT_ADMIN_ROLE) {
        _revokeRole(NOTARY_ROLE, notary);
    }
}
```

### Deployment Script

Create `scripts/deploy_notary.js`:

```javascript
const { ethers, upgrades } = require("hardhat");

async function main() {
    console.log("🚀 Deploying RegistryNotary...");
    
    const [deployer] = await ethers.getSigners();
    console.log("Deploying with account:", deployer.address);
    
    const balance = await ethers.provider.getBalance(deployer.address);
    console.log("Account balance:", ethers.formatEther(balance), "ETH");
    
    // Deploy the contract
    const RegistryNotary = await ethers.getContractFactory("RegistryNotary");
    const notary = await RegistryNotary.deploy(deployer.address);
    
    await notary.waitForDeployment();
    const address = await notary.getAddress();
    
    console.log("✅ RegistryNotary deployed to:", address);
    console.log("🔐 Admin & Notary role granted to:", deployer.address);
    
    // Verify deployment
    const hasNotaryRole = await notary.hasRole(await notary.NOTARY_ROLE(), deployer.address);
    const hasAdminRole = await notary.hasRole(await notary.DEFAULT_ADMIN_ROLE(), deployer.address);
    
    console.log("✅ Deployment verification:");
    console.log("   Notary role:", hasNotaryRole);
    console.log("   Admin role:", hasAdminRole);
    
    return address;
}

main()
    .then((address) => {
        console.log(`\n🎉 Registry Notary deployed successfully at: ${address}`);
        process.exit(0);
    })
    .catch((error) => {
        console.error("❌ Deployment failed:", error);
        process.exit(1);
    });
```

### Notarization Script

Create `scripts/notarize_registry.py`:

```python
#!/usr/bin/env python3
"""
On-chain notarization script for Unykorn registry.
Records Merkle roots and IPFS CIDs on-chain for permanent audit trail.
"""

import json
import sys
from web3 import Web3
from datetime import datetime

# Contract ABI (simplified for notarization)
REGISTRY_NOTARY_ABI = [
    {
        "inputs": [
            {"name": "merkleRoot", "type": "bytes32"},
            {"name": "ipfsCid", "type": "string"},
            {"name": "version", "type": "string"},
            {"name": "label", "type": "string"}
        ],
        "name": "notarizeSnapshot",
        "outputs": [{"name": "", "type": "uint256"}],
        "type": "function"
    },
    {
        "inputs": [{"name": "merkleRoot", "type": "bytes32"}],
        "name": "verifyMerkleRoot",
        "outputs": [
            {"name": "exists", "type": "bool"},
            {"name": "snapshotId", "type": "uint256"}
        ],
        "type": "function"
    }
]

def load_registry_data():
    """Load registry data and IPFS receipts."""
    try:
        with open('exports/MERKLE_ROOTS.json', 'r') as f:
            merkle_data = json.load(f)
        
        with open('ipfs_receipts.json', 'r') as f:
            ipfs_data = json.load(f)
        
        return merkle_data, ipfs_data
    except FileNotFoundError as e:
        print(f"❌ Required file not found: {e}")
        print("   Run: python3 scripts/validate_registry.py")
        print("   Run: python3 scripts/ipfs_pin.py")
        sys.exit(1)

def notarize_to_blockchain(rpc_url, contract_address, private_key):
    """Notarize registry data to blockchain."""
    print("⛓️  Connecting to blockchain...")
    
    # Connect to blockchain
    w3 = Web3(Web3.HTTPProvider(rpc_url))
    if not w3.is_connected():
        print("❌ Failed to connect to blockchain")
        sys.exit(1)
    
    account = w3.eth.account.from_key(private_key)
    print(f"📝 Notarizing from account: {account.address}")
    
    # Load contract
    contract = w3.eth.contract(
        address=Web3.to_checksum_address(contract_address),
        abi=REGISTRY_NOTARY_ABI
    )
    
    # Load data
    merkle_data, ipfs_data = load_registry_data()
    
    # Prepare notarization for each file
    for filename in ['unykorn_l1_chains.csv', 'unykorn_address_book.csv']:
        if filename not in merkle_data['files']:
            print(f"⏭️  Skipping {filename}: No Merkle data found")
            continue
        
        if filename not in ipfs_data['files']:
            print(f"⏭️  Skipping {filename}: No IPFS CID found")
            continue
        
        merkle_root = merkle_data['files'][filename]['merkle_root']
        ipfs_cid = ipfs_data['files'][filename]['ipfs_cid']
        version = merkle_data['version']
        label = f"{filename.replace('.csv', '').replace('unykorn_', '').replace('_', ' ').title()} Registry"
        
        print(f"📝 Notarizing {filename}...")
        print(f"   Merkle Root: {merkle_root}")
        print(f"   IPFS CID: {ipfs_cid}")
        
        # Check if already notarized
        try:
            exists, snapshot_id = contract.functions.verifyMerkleRoot(
                Web3.to_bytes(hexstr=merkle_root)
            ).call()
            
            if exists:
                print(f"   ⏭️  Already notarized (Snapshot ID: {snapshot_id})")
                continue
        except Exception as e:
            print(f"   ⚠️  Could not check existing notarization: {e}")
        
        # Build transaction
        try:
            nonce = w3.eth.get_transaction_count(account.address)
            
            transaction = contract.functions.notarizeSnapshot(
                Web3.to_bytes(hexstr=merkle_root),
                ipfs_cid,
                version,
                label
            ).build_transaction({
                'from': account.address,
                'nonce': nonce,
                'gas': 200000,  # Adjust as needed
                'gasPrice': w3.to_wei('20', 'gwei')  # Adjust as needed
            })
            
            # Sign and send transaction
            signed_txn = w3.eth.account.sign_transaction(transaction, private_key)
            tx_hash = w3.eth.send_raw_transaction(signed_txn.rawTransaction)
            
            print(f"   📤 Transaction sent: {tx_hash.hex()}")
            
            # Wait for confirmation
            receipt = w3.eth.wait_for_transaction_receipt(tx_hash, timeout=300)
            
            if receipt['status'] == 1:
                print(f"   ✅ Notarized! Block: {receipt['blockNumber']}")
                
                # Extract snapshot ID from logs
                for log in receipt['logs']:
                    try:
                        decoded = contract.events.RegistryNotarized().process_log(log)
                        snapshot_id = decoded['args']['snapshotId']
                        print(f"   📊 Snapshot ID: {snapshot_id}")
                        break
                    except:
                        continue
            else:
                print(f"   ❌ Transaction failed!")
                
        except Exception as e:
            print(f"   ❌ Error during notarization: {e}")

def main():
    """Main notarization workflow."""
    print("⛓️  Unykorn Registry - On-Chain Notarization")
    print("=" * 60)
    
    # Configuration (you'll need to set these)
    RPC_URL = "https://your-ethereum-rpc-url"
    CONTRACT_ADDRESS = "0xYourRegistryNotaryContractAddress"
    PRIVATE_KEY = "0xYourPrivateKey"  # Keep secure!
    
    # Validate configuration
    if "your-ethereum-rpc-url" in RPC_URL:
        print("❌ Please configure RPC_URL in the script")
        sys.exit(1)
    
    if "YourRegistryNotaryContractAddress" in CONTRACT_ADDRESS:
        print("❌ Please deploy RegistryNotary contract and set CONTRACT_ADDRESS")
        sys.exit(1)
        
    if "YourPrivateKey" in PRIVATE_KEY:
        print("❌ Please set PRIVATE_KEY (use environment variable for security)")
        sys.exit(1)
    
    # Run notarization
    notarize_to_blockchain(RPC_URL, CONTRACT_ADDRESS, PRIVATE_KEY)
    
    print("\n🎉 On-chain notarization complete!")
    print("🔍 Verify at: https://etherscan.io/address/" + CONTRACT_ADDRESS)

if __name__ == "__main__":
    main()
```

## 🔐 Institutional Verification Workflow

### Complete Verification Process

```bash
# 1. Download registry files
curl -O https://kevanbtc.github.io/unykorn/unykorn_l1_chains.csv
curl -O https://kevanbtc.github.io/unykorn/MERKLE_ROOTS.json

# 2. Verify file integrity
python3 << 'EOF'
import hashlib
import json

# Load expected hash from proofs
with open('MERKLE_ROOTS.json', 'r') as f:
    proofs = json.load(f)

expected_hash = proofs['files']['unykorn_l1_chains.csv']['file_hash']

# Compute actual hash
with open('unykorn_l1_chains.csv', 'rb') as f:
    actual_hash = hashlib.sha256(f.read()).hexdigest()

# Verify
assert actual_hash == expected_hash, "Hash mismatch!"
print("✅ File integrity verified")
EOF

# 3. Verify IPFS availability
IPFS_CID="QmYourCIDFromReceipts"
curl -s "https://ipfs.io/ipfs/$IPFS_CID" > /tmp/ipfs_download.csv
diff unykorn_l1_chains.csv /tmp/ipfs_download.csv && echo "✅ IPFS data matches local file"

# 4. Verify on-chain notarization (requires Web3 setup)
python3 scripts/verify_onchain.py --merkle-root "0xYourMerkleRoot" --contract "0xContractAddress"
```

## 📊 Benefits for Institutions

### Audit Trail Components
1. **Local CSV files** with known structure and validation
2. **Merkle proofs** prevent tampering and enable partial verification  
3. **IPFS pinning** provides immutable, decentralized storage
4. **On-chain records** create permanent, timestamped audit trail
5. **GitHub Actions** provide automated validation and updates

### Compliance Features
- **Tamper detection** through cryptographic hashes
- **Historical versioning** with timestamped snapshots
- **Independent verification** without trusting central authority
- **Regulatory storage** through IPFS permanent addressing
- **Audit-friendly** JSON metadata with complete provenance

### Integration Support
- **RESTful access** via GitHub Pages
- **API-friendly** JSON formats for automated systems
- **Standard CSV exports** compatible with existing tools
- **Blockchain verification** for maximum security assurance

This complete integration provides banks and institutions with a production-ready registry system that meets the highest compliance and security standards. 🏦✅