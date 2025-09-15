#!/usr/bin/env python3
"""
RPC Health Check Utility
Manual tool for testing RPC endpoints and generating health reports.
"""

import csv
import json
import requests
import time
import argparse
from datetime import datetime, timezone
from typing import Dict, List, Tuple


def check_rpc_health(rpc_url: str, chain_name: str, expected_chain_id: str) -> Tuple[bool, str, float]:
    """
    Check if an RPC endpoint is healthy and responding correctly.
    
    Args:
        rpc_url: The RPC endpoint URL to test
        chain_name: Human-readable name of the chain
        expected_chain_id: Expected chain ID as string
        
    Returns:
        Tuple of (is_healthy, status_message, response_time_seconds)
    """
    try:
        # Standard JSON-RPC request for chain ID
        payload = {
            "jsonrpc": "2.0",
            "method": "eth_chainId", 
            "params": [],
            "id": 1
        }
        
        start_time = time.time()
        response = requests.post(
            rpc_url,
            json=payload,
            timeout=15,
            headers={
                "Content-Type": "application/json",
                "User-Agent": "Unykorn-Registry-Monitor/1.0"
            }
        )
        response_time = time.time() - start_time
        
        if response.status_code == 200:
            data = response.json()
            
            if 'result' in data:
                # Convert hex chain ID to int
                try:
                    returned_chain_id = int(data['result'], 16)
                    expected_chain_id_int = int(expected_chain_id)
                    
                    if returned_chain_id == expected_chain_id_int:
                        return True, "OK", response_time
                    else:
                        return False, f"Chain ID mismatch: expected {expected_chain_id_int}, got {returned_chain_id}", response_time
                        
                except ValueError as e:
                    return False, f"Invalid chain ID format: {data['result']}", response_time
                    
            elif 'error' in data:
                error_msg = data['error'].get('message', 'Unknown RPC error')
                return False, f"RPC error: {error_msg}", response_time
            else:
                return False, "Invalid RPC response format", response_time
                
        else:
            return False, f"HTTP {response.status_code}: {response.text[:100]}", response_time
            
    except requests.exceptions.Timeout:
        return False, "Timeout (>15s)", 15.0
    except requests.exceptions.ConnectionError:
        return False, "Connection failed", 0.0
    except requests.exceptions.RequestException as e:
        return False, f"Request error: {str(e)}", 0.0
    except Exception as e:
        return False, f"Unexpected error: {str(e)}", 0.0


def load_chains_from_csv(csv_file: str) -> List[Dict[str, str]]:
    """Load chain data from CSV file."""
    chains = []
    try:
        with open(csv_file, 'r', newline='', encoding='utf-8') as f:
            reader = csv.DictReader(f)
            for row in reader:
                chains.append(row)
        return chains
    except FileNotFoundError:
        print(f"❌ Error: CSV file not found: {csv_file}")
        return []
    except Exception as e:
        print(f"❌ Error reading CSV file: {str(e)}")
        return []


def run_health_check(csv_file: str, include_inactive: bool = False, output_file: str = None) -> Dict:
    """
    Run complete RPC health check on all chains.
    
    Args:
        csv_file: Path to the chains CSV file
        include_inactive: Whether to check inactive/deprecated chains
        output_file: Optional file to save results
        
    Returns:
        Dictionary with complete health check results
    """
    print("🌐 Unykorn RPC Health Check")
    print("=" * 60)
    
    chains = load_chains_from_csv(csv_file)
    if not chains:
        return {}
    
    results = []
    failed_chains = []
    total_response_time = 0.0
    checked_count = 0
    
    for chain in chains:
        chain_id = chain.get('chain_id', '').strip()
        name = chain.get('name', '').strip()
        rpc_url = chain.get('rpc_url', '').strip()
        status = chain.get('status', '').strip().lower()
        
        # Skip chains without required data
        if not all([chain_id, name, rpc_url]):
            print(f"⏭️  Skipping {name or 'Unknown'}: Missing required data")
            continue
            
        # Skip inactive chains unless requested
        if not include_inactive and status in ['inactive', 'deprecated']:
            print(f"⏭️  Skipping {name} (status: {status})")
            continue
            
        print(f"🔍 Testing {name} (Chain {chain_id})...")
        print(f"   RPC: {rpc_url[:60]}{'...' if len(rpc_url) > 60 else ''}")
        
        is_healthy, message, response_time = check_rpc_health(rpc_url, name, chain_id)
        
        result = {
            'chain_id': int(chain_id) if chain_id.isdigit() else chain_id,
            'name': name,
            'symbol': chain.get('symbol', ''),
            'rpc_url': rpc_url,
            'status': status,
            'healthy': is_healthy,
            'message': message,
            'response_time_ms': round(response_time * 1000, 2),
            'checked_at': datetime.now(timezone.utc).isoformat(),
            'block_explorer': chain.get('block_explorer', ''),
            'native_token': chain.get('native_token', '')
        }
        
        results.append(result)
        
        if is_healthy:
            print(f"   ✅ {message} ({result['response_time_ms']}ms)")
            total_response_time += response_time
            checked_count += 1
        else:
            print(f"   ❌ {message} ({result['response_time_ms']}ms)")
            failed_chains.append(name)
        
        # Be respectful to RPC providers
        time.sleep(0.5)
    
    # Generate summary
    healthy_count = len([r for r in results if r['healthy']])
    total_count = len(results)
    avg_response_time = (total_response_time / checked_count * 1000) if checked_count > 0 else 0
    
    summary = {
        'check_timestamp': datetime.now(timezone.utc).isoformat(),
        'total_chains': total_count,
        'healthy_chains': healthy_count,
        'failed_chains': len(failed_chains),
        'success_rate': round((healthy_count / total_count * 100), 1) if total_count > 0 else 0,
        'average_response_time_ms': round(avg_response_time, 2),
        'failed_chain_names': failed_chains,
        'results': results
    }
    
    # Print summary
    print("\n" + "=" * 60)
    print("📊 Health Check Summary")
    print(f"✅ Healthy chains: {healthy_count}/{total_count} ({summary['success_rate']}%)")
    print(f"❌ Failed chains: {len(failed_chains)}")
    print(f"⏱️  Average response time: {summary['average_response_time_ms']}ms")
    
    if failed_chains:
        print(f"⚠️  Failed chains: {', '.join(failed_chains)}")
    
    # Save to file if requested
    if output_file:
        try:
            with open(output_file, 'w', encoding='utf-8') as f:
                json.dump(summary, f, indent=2, sort_keys=True)
            print(f"💾 Results saved to: {output_file}")
        except Exception as e:
            print(f"❌ Error saving results: {str(e)}")
    
    return summary


def main():
    """Main entry point for RPC health check utility."""
    parser = argparse.ArgumentParser(
        description="Unykorn RPC Health Check Utility",
        formatter_class=argparse.RawDescriptionHelpFormatter,
        epilog="""
Examples:
  python3 scripts/rpc_health.py                                    # Check active chains
  python3 scripts/rpc_health.py --include-inactive                 # Check all chains  
  python3 scripts/rpc_health.py --output rpc_report.json          # Save results
  python3 scripts/rpc_health.py --csv custom_chains.csv           # Custom CSV file
        """
    )
    
    parser.add_argument(
        '--csv',
        default='exports/unykorn_l1_chains.csv',
        help='Path to chains CSV file (default: exports/unykorn_l1_chains.csv)'
    )
    
    parser.add_argument(
        '--include-inactive',
        action='store_true',
        help='Include inactive and deprecated chains in health check'
    )
    
    parser.add_argument(
        '--output', '-o',
        help='Save results to JSON file'
    )
    
    parser.add_argument(
        '--quiet', '-q',
        action='store_true',
        help='Suppress detailed output, show only summary'
    )
    
    args = parser.parse_args()
    
    if args.quiet:
        import io
        import sys
        # Capture stdout but preserve stderr for errors
        old_stdout = sys.stdout
        sys.stdout = io.StringIO()
        
        try:
            results = run_health_check(args.csv, args.include_inactive, args.output)
        finally:
            output = sys.stdout.getvalue()
            sys.stdout = old_stdout
            
        # Print only summary in quiet mode
        if results:
            healthy = results['healthy_chains']
            total = results['total_chains']
            success_rate = results['success_rate']
            print(f"RPC Health: {healthy}/{total} ({success_rate}%) chains healthy")
            
            if results['failed_chains'] > 0:
                print(f"Failed: {', '.join(results['failed_chain_names'])}")
    else:
        results = run_health_check(args.csv, args.include_inactive, args.output)
    
    # Exit with non-zero code if any chains failed (useful for CI)
    if results and results['failed_chains'] > 0:
        exit(1)


if __name__ == "__main__":
    main()