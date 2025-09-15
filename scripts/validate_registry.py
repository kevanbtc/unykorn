#!/usr/bin/env python3
"""
Unykorn Registry Validation Suite
Validates CSV data integrity and computes Merkle tree proofs for tamper-evident storage.
"""

import csv
import json
import hashlib
import sys
import os
from datetime import datetime
from typing import List, Dict, Any, Optional


class MerkleTree:
    """Merkle tree implementation for registry data verification."""
    
    def __init__(self, data: List[str]):
        self.leaves = [self._hash_leaf(item) for item in data]
        self.tree = self._build_tree()
    
    def _hash_leaf(self, data: str) -> str:
        """Hash a single leaf node."""
        return hashlib.sha256(data.encode('utf-8')).hexdigest()
    
    def _hash_pair(self, left: str, right: str) -> str:
        """Hash a pair of nodes."""
        return hashlib.sha256((left + right).encode('utf-8')).hexdigest()
    
    def _build_tree(self) -> List[List[str]]:
        """Build the complete Merkle tree."""
        if not self.leaves:
            return [[]]
        
        tree = [self.leaves[:]]
        level = self.leaves[:]
        
        while len(level) > 1:
            next_level = []
            for i in range(0, len(level), 2):
                left = level[i]
                right = level[i + 1] if i + 1 < len(level) else level[i]
                next_level.append(self._hash_pair(left, right))
            tree.append(next_level)
            level = next_level
        
        return tree
    
    def get_root(self) -> str:
        """Get the Merkle root."""
        return self.tree[-1][0] if self.tree and self.tree[-1] else ""
    
    def get_proof(self, index: int) -> List[str]:
        """Get proof for a leaf at given index."""
        if index >= len(self.leaves):
            return []
        
        proof = []
        for level in self.tree[:-1]:
            if index % 2 == 0:
                sibling_index = index + 1
            else:
                sibling_index = index - 1
            
            if sibling_index < len(level):
                proof.append(level[sibling_index])
            
            index = index // 2
        
        return proof
    
    def verify_proof(self, leaf: str, proof: List[str], root: str) -> bool:
        """Verify a Merkle proof."""
        computed = self._hash_leaf(leaf)
        
        for sibling in proof:
            if computed <= sibling:
                computed = self._hash_pair(computed, sibling)
            else:
                computed = self._hash_pair(sibling, computed)
        
        return computed == root


class RegistryValidator:
    """Main validator for Unykorn registry data."""
    
    def __init__(self, exports_dir: str = "exports"):
        self.exports_dir = exports_dir
        self.errors: List[str] = []
        self.warnings: List[str] = []
    
    def validate_csv_structure(self, filepath: str, required_columns: List[str]) -> bool:
        """Validate CSV file structure and required columns."""
        if not os.path.exists(filepath):
            self.errors.append(f"File not found: {filepath}")
            return False
        
        try:
            with open(filepath, 'r', newline='', encoding='utf-8') as f:
                reader = csv.DictReader(f)
                headers = reader.fieldnames or []
                
                # Check required columns
                missing = set(required_columns) - set(headers)
                if missing:
                    self.errors.append(f"{filepath}: Missing required columns: {missing}")
                    return False
                
                # Validate data integrity
                row_count = 0
                for row_num, row in enumerate(reader, start=2):
                    row_count += 1
                    # Check for empty required fields
                    for col in required_columns:
                        if not row.get(col, '').strip():
                            self.warnings.append(f"{filepath}:{row_num}: Empty required field '{col}'")
                
                if row_count == 0:
                    self.errors.append(f"{filepath}: No data rows found")
                    return False
                
                print(f"✓ {filepath}: {row_count} rows validated")
                return True
        
        except Exception as e:
            self.errors.append(f"Error reading {filepath}: {str(e)}")
            return False
    
    def validate_chains_csv(self) -> bool:
        """Validate L1 chains CSV structure and data."""
        filepath = os.path.join(self.exports_dir, "unykorn_l1_chains.csv")
        required_columns = ["chain_id", "name", "symbol", "rpc_url", "status"]
        
        if not self.validate_csv_structure(filepath, required_columns):
            return False
        
        # Additional chain-specific validation
        try:
            with open(filepath, 'r', newline='', encoding='utf-8') as f:
                reader = csv.DictReader(f)
                chain_ids = set()
                
                for row_num, row in enumerate(reader, start=2):
                    chain_id = row.get('chain_id', '').strip()
                    
                    # Validate chain_id is numeric
                    try:
                        chain_id_int = int(chain_id)
                        if chain_id_int <= 0:
                            self.errors.append(f"chains:{row_num}: Invalid chain_id (must be positive): {chain_id}")
                    except ValueError:
                        self.errors.append(f"chains:{row_num}: chain_id must be numeric: {chain_id}")
                    
                    # Check for duplicates
                    if chain_id in chain_ids:
                        self.errors.append(f"chains:{row_num}: Duplicate chain_id: {chain_id}")
                    else:
                        chain_ids.add(chain_id)
                    
                    # Validate status
                    status = row.get('status', '').strip().lower()
                    if status not in ['active', 'inactive', 'deprecated']:
                        self.warnings.append(f"chains:{row_num}: Unknown status: {status}")
            
            return True
        
        except Exception as e:
            self.errors.append(f"Error validating chains CSV: {str(e)}")
            return False
    
    def validate_address_book_csv(self) -> bool:
        """Validate address book CSV structure and data."""
        filepath = os.path.join(self.exports_dir, "unykorn_address_book.csv")
        required_columns = ["address", "label", "chain_id", "contract_type"]
        
        if not self.validate_csv_structure(filepath, required_columns):
            return False
        
        # Additional address-specific validation
        try:
            with open(filepath, 'r', newline='', encoding='utf-8') as f:
                reader = csv.DictReader(f)
                addresses = set()
                
                for row_num, row in enumerate(reader, start=2):
                    address = row.get('address', '').strip()
                    chain_id = row.get('chain_id', '').strip()
                    
                    # Validate Ethereum address format
                    if not address.startswith('0x') or len(address) != 42:
                        self.errors.append(f"address_book:{row_num}: Invalid address format: {address}")
                    
                    # Check for duplicates (address + chain_id combination)
                    addr_key = f"{address}:{chain_id}"
                    if addr_key in addresses:
                        self.warnings.append(f"address_book:{row_num}: Duplicate address on chain: {addr_key}")
                    else:
                        addresses.add(addr_key)
                    
                    # Validate chain_id
                    try:
                        int(chain_id)
                    except ValueError:
                        self.errors.append(f"address_book:{row_num}: chain_id must be numeric: {chain_id}")
            
            return True
        
        except Exception as e:
            self.errors.append(f"Error validating address book CSV: {str(e)}")
            return False
    
    def compute_merkle_roots(self) -> Dict[str, Any]:
        """Compute Merkle roots for all registry files."""
        roots = {
            "generated_at": datetime.utcnow().isoformat() + "Z",
            "version": "1.0.0",
            "files": {}
        }
        
        csv_files = ["unykorn_l1_chains.csv", "unykorn_address_book.csv"]
        
        for filename in csv_files:
            filepath = os.path.join(self.exports_dir, filename)
            if not os.path.exists(filepath):
                continue
            
            try:
                # Read all rows as strings for consistent hashing
                with open(filepath, 'r', newline='', encoding='utf-8') as f:
                    content = f.read().strip()
                    lines = content.split('\n')
                
                # Create Merkle tree from all lines (including header)
                tree = MerkleTree(lines)
                root = tree.get_root()
                
                # Calculate file hash for additional verification
                file_hash = hashlib.sha256(content.encode('utf-8')).hexdigest()
                
                roots["files"][filename] = {
                    "merkle_root": root,
                    "file_hash": file_hash,
                    "row_count": len(lines) - 1,  # Exclude header
                    "last_updated": datetime.utcnow().isoformat() + "Z"
                }
                
                print(f"✓ Computed Merkle root for {filename}: {root[:16]}...")
                
            except Exception as e:
                self.errors.append(f"Error computing Merkle root for {filename}: {str(e)}")
        
        return roots
    
    def run_validation(self) -> bool:
        """Run complete validation suite."""
        print("🔍 Starting Unykorn Registry Validation...")
        print("=" * 50)
        
        # Validate directory structure
        if not os.path.exists(self.exports_dir):
            self.errors.append(f"Exports directory not found: {self.exports_dir}")
            return False
        
        # Validate individual CSV files
        chains_valid = self.validate_chains_csv()
        address_book_valid = self.validate_address_book_csv()
        
        # Compute and save Merkle roots
        if chains_valid and address_book_valid:
            roots = self.compute_merkle_roots()
            
            roots_file = os.path.join(self.exports_dir, "MERKLE_ROOTS.json")
            try:
                with open(roots_file, 'w', encoding='utf-8') as f:
                    json.dump(roots, f, indent=2, sort_keys=True)
                print(f"✓ Merkle roots saved to: {roots_file}")
            except Exception as e:
                self.errors.append(f"Error saving Merkle roots: {str(e)}")
        
        # Report results
        print("\n" + "=" * 50)
        print("🔍 Validation Results:")
        
        if self.errors:
            print(f"❌ {len(self.errors)} error(s) found:")
            for error in self.errors:
                print(f"  • {error}")
        
        if self.warnings:
            print(f"⚠️  {len(self.warnings)} warning(s) found:")
            for warning in self.warnings:
                print(f"  • {warning}")
        
        if not self.errors and not self.warnings:
            print("✅ All validations passed! Registry data is clean.")
        elif not self.errors:
            print("✅ Validation passed with warnings.")
        
        return len(self.errors) == 0


def main():
    """Main entry point for validation script."""
    import argparse
    
    parser = argparse.ArgumentParser(description="Unykorn Registry Validation Suite")
    parser.add_argument("--exports-dir", default="exports", 
                       help="Directory containing CSV exports (default: exports)")
    parser.add_argument("--quiet", "-q", action="store_true", 
                       help="Suppress output except errors")
    
    args = parser.parse_args()
    
    if args.quiet:
        # Redirect stdout but keep stderr for errors
        import io
        sys.stdout = io.StringIO()
    
    validator = RegistryValidator(args.exports_dir)
    success = validator.run_validation()
    
    if args.quiet:
        sys.stdout = sys.__stdout__
    
    if not success:
        sys.exit(1)


if __name__ == "__main__":
    main()