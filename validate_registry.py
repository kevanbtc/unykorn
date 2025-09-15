#!/usr/bin/env python3
"""
Unykorn Registry Validation Engine
Bank-ready sovereign proof machine for chain and address registry validation
"""

import hashlib
import json
import csv
import os
import sys
import requests
from datetime import datetime, timezone
from typing import Dict, List, Any, Optional, Tuple
from dataclasses import dataclass
import asyncio
try:
    import aiohttp
except ImportError:
    aiohttp = None
from pathlib import Path

@dataclass
class ValidationResult:
    """Result of registry validation"""
    is_valid: bool
    errors: List[str]
    warnings: List[str]
    merkle_root: str
    timestamp: str

@dataclass
class ChainInfo:
    """L1 Chain information"""
    chain_id: int
    name: str
    symbol: str
    rpc_url: str
    status: str
    type: str

@dataclass
class AddressInfo:
    """Verified address information"""
    address: str
    name: str
    protocol: str
    category: str
    chain_id: int
    verified_date: str

class MerkleTree:
    """Merkle tree implementation for cryptographic proofs"""
    
    def __init__(self, data: List[str]):
        self.data = data
        self.tree = self._build_tree()
        
    def _hash(self, data: str) -> str:
        """SHA-256 hash of data"""
        return hashlib.sha256(data.encode('utf-8')).hexdigest()
    
    def _build_tree(self) -> List[List[str]]:
        """Build Merkle tree from data"""
        if not self.data:
            return []
            
        # Start with leaf nodes (hashed data)
        current_level = [self._hash(item) for item in self.data]
        tree = [current_level[:]]  # Copy the level
        
        # Build tree bottom-up
        while len(current_level) > 1:
            next_level = []
            
            # Process pairs
            for i in range(0, len(current_level), 2):
                left = current_level[i]
                right = current_level[i + 1] if i + 1 < len(current_level) else left
                
                # Combine and hash
                combined = left + right
                next_level.append(self._hash(combined))
            
            tree.append(next_level[:])
            current_level = next_level
            
        return tree
    
    def get_root(self) -> str:
        """Get Merkle root"""
        if not self.tree:
            return ""
        return self.tree[-1][0]
    
    def get_proof(self, index: int) -> List[str]:
        """Get Merkle proof for data at index"""
        if index >= len(self.data) or not self.tree:
            return []
            
        proof = []
        current_index = index
        
        for level in self.tree[:-1]:  # Exclude root level
            # Find sibling
            if current_index % 2 == 0:  # Left node
                sibling_index = current_index + 1
            else:  # Right node
                sibling_index = current_index - 1
                
            if sibling_index < len(level):
                proof.append(level[sibling_index])
            
            current_index = current_index // 2
            
        return proof
    
    def verify_proof(self, data: str, index: int, proof: List[str]) -> bool:
        """Verify Merkle proof"""
        current_hash = self._hash(data)
        current_index = index
        
        for sibling_hash in proof:
            if current_index % 2 == 0:  # Left node
                combined = current_hash + sibling_hash
            else:  # Right node
                combined = sibling_hash + current_hash
                
            current_hash = self._hash(combined)
            current_index = current_index // 2
            
        return current_hash == self.get_root()

class UnykornValidator:
    """Main validation engine for Unykorn registry"""
    
    def __init__(self, base_path: str = "."):
        self.base_path = Path(base_path)
        self.chains_file = self.base_path / "unykorn_l1_chains.csv"
        self.addresses_file = self.base_path / "unykorn_address_book.csv"
        self.merkle_file = self.base_path / "MERKLE_ROOTS.json"
        
    def load_chains(self) -> List[ChainInfo]:
        """Load L1 chains from CSV"""
        chains = []
        try:
            with open(self.chains_file, 'r', newline='', encoding='utf-8') as f:
                reader = csv.DictReader(f)
                for row in reader:
                    chains.append(ChainInfo(
                        chain_id=int(row['chain_id']),
                        name=row['name'],
                        symbol=row['symbol'],
                        rpc_url=row['rpc_url'],
                        status=row['status'],
                        type=row['type']
                    ))
        except Exception as e:
            print(f"Error loading chains: {e}")
            
        return chains
    
    def load_addresses(self) -> List[AddressInfo]:
        """Load verified addresses from CSV"""
        addresses = []
        try:
            with open(self.addresses_file, 'r', newline='', encoding='utf-8') as f:
                reader = csv.DictReader(f)
                for row in reader:
                    addresses.append(AddressInfo(
                        address=row['address'],
                        name=row['name'],
                        protocol=row['protocol'],
                        category=row['category'],
                        chain_id=int(row['chain_id']),
                        verified_date=row['verified_date']
                    ))
        except Exception as e:
            print(f"Error loading addresses: {e}")
            
        return addresses
    
    def validate_chain_format(self, chain: ChainInfo) -> List[str]:
        """Validate chain data format"""
        errors = []
        
        if chain.chain_id <= 0:
            errors.append(f"Invalid chain ID: {chain.chain_id}")
            
        if not chain.name or len(chain.name) < 2:
            errors.append(f"Invalid chain name: {chain.name}")
            
        if not chain.rpc_url or not chain.rpc_url.startswith('http'):
            errors.append(f"Invalid RPC URL: {chain.rpc_url}")
            
        if chain.status not in ['active', 'deprecated', 'testnet']:
            errors.append(f"Invalid status: {chain.status}")
            
        return errors
    
    def validate_address_format(self, address: AddressInfo) -> List[str]:
        """Validate address data format"""
        errors = []
        
        if not address.address or not address.address.startswith('0x'):
            errors.append(f"Invalid address format: {address.address}")
            
        if len(address.address) != 42:  # 0x + 40 hex chars
            errors.append(f"Invalid address length: {address.address}")
            
        if not address.name or len(address.name) < 2:
            errors.append(f"Invalid address name: {address.name}")
            
        if address.chain_id <= 0:
            errors.append(f"Invalid chain ID for address: {address.chain_id}")
            
        return errors
    
    async def check_rpc_health(self, rpc_url: str) -> bool:
        """Check if RPC endpoint is healthy"""
        if not aiohttp:
            return True  # Skip RPC check if aiohttp not available
            
        try:
            timeout = aiohttp.ClientTimeout(total=10)
            async with aiohttp.ClientSession(timeout=timeout) as session:
                payload = {
                    "jsonrpc": "2.0",
                    "method": "eth_blockNumber",
                    "params": [],
                    "id": 1
                }
                
                async with session.post(rpc_url, json=payload) as response:
                    if response.status == 200:
                        data = await response.json()
                        return 'result' in data
                    return False
        except Exception:
            return False
    
    def calculate_merkle_roots(self, chains: List[ChainInfo], addresses: List[AddressInfo]) -> Dict[str, Any]:
        """Calculate Merkle roots for registry data"""
        
        # Prepare chain data for Merkle tree
        chain_data = []
        for chain in chains:
            chain_str = f"{chain.chain_id}|{chain.name}|{chain.symbol}|{chain.rpc_url}|{chain.status}"
            chain_data.append(chain_str)
        
        # Prepare address data for Merkle tree
        address_data = []
        for addr in addresses:
            addr_str = f"{addr.address}|{addr.name}|{addr.protocol}|{addr.category}|{addr.chain_id}"
            address_data.append(addr_str)
        
        # Calculate Merkle roots
        chain_tree = MerkleTree(chain_data)
        address_tree = MerkleTree(address_data)
        
        # Combined root
        combined_data = chain_data + address_data
        combined_tree = MerkleTree(combined_data)
        
        return {
            "timestamp": datetime.now(timezone.utc).isoformat(),
            "chain_count": len(chains),
            "address_count": len(addresses),
            "merkle_roots": {
                "chains": chain_tree.get_root(),
                "addresses": address_tree.get_root(),
                "combined": combined_tree.get_root()
            },
            "validation_metadata": {
                "validator_version": "1.0.0",
                "algorithm": "SHA-256",
                "tree_type": "binary_merkle"
            }
        }
    
    def save_merkle_roots(self, merkle_data: Dict[str, Any]) -> None:
        """Save Merkle roots to JSON file"""
        try:
            with open(self.merkle_file, 'w', encoding='utf-8') as f:
                json.dump(merkle_data, f, indent=2)
        except Exception as e:
            print(f"Error saving Merkle roots: {e}")
    
    async def validate_registry(self, check_rpc: bool = False) -> ValidationResult:
        """Validate complete registry"""
        errors = []
        warnings = []
        
        # Load data
        chains = self.load_chains()
        addresses = self.load_addresses()
        
        if not chains:
            errors.append("No chains loaded")
        
        if not addresses:
            errors.append("No addresses loaded")
        
        # Validate formats
        for chain in chains:
            chain_errors = self.validate_chain_format(chain)
            errors.extend([f"Chain {chain.name}: {error}" for error in chain_errors])
        
        for address in addresses:
            addr_errors = self.validate_address_format(address)
            errors.extend([f"Address {address.address}: {error}" for error in addr_errors])
        
        # Check RPC health if requested
        if check_rpc and chains:
            print("Checking RPC health...")
            rpc_tasks = [self.check_rpc_health(chain.rpc_url) for chain in chains[:5]]  # Limit to first 5
            rpc_results = await asyncio.gather(*rpc_tasks, return_exceptions=True)
            
            for i, (chain, is_healthy) in enumerate(zip(chains[:5], rpc_results)):
                if isinstance(is_healthy, Exception):
                    warnings.append(f"RPC check failed for {chain.name}: {is_healthy}")
                elif not is_healthy:
                    warnings.append(f"RPC appears unhealthy for {chain.name}")
        
        # Calculate Merkle roots
        merkle_data = self.calculate_merkle_roots(chains, addresses)
        self.save_merkle_roots(merkle_data)
        
        return ValidationResult(
            is_valid=len(errors) == 0,
            errors=errors,
            warnings=warnings,
            merkle_root=merkle_data["merkle_roots"]["combined"],
            timestamp=merkle_data["timestamp"]
        )

async def main():
    """Main validation function"""
    validator = UnykornValidator()
    
    print("🔍 Unykorn Registry Validation Engine")
    print("=" * 50)
    
    # Run validation
    result = await validator.validate_registry(check_rpc=True)
    
    print(f"Validation Result: {'✅ VALID' if result.is_valid else '❌ INVALID'}")
    print(f"Timestamp: {result.timestamp}")
    print(f"Merkle Root: {result.merkle_root}")
    
    if result.errors:
        print("\n❌ Errors:")
        for error in result.errors:
            print(f"  - {error}")
    
    if result.warnings:
        print("\n⚠️ Warnings:")
        for warning in result.warnings:
            print(f"  - {warning}")
    
    print("\n📊 Registry Statistics:")
    chains = validator.load_chains()
    addresses = validator.load_addresses()
    
    print(f"  - L1 Chains: {len(chains)}")
    print(f"  - Verified Addresses: {len(addresses)}")
    print(f"  - Active Chains: {sum(1 for c in chains if c.status == 'active')}")
    
    # Exit with appropriate code
    sys.exit(0 if result.is_valid else 1)

if __name__ == "__main__":
    asyncio.run(main())