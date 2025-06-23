import React, { useState } from 'react';
import { useAccount, useContractWrite, useContractRead } from 'wagmi';
import { ConnectButton } from '@rainbow-me/rainbowkit';
import SoulboundSafe from '../artifacts/contracts/SoulboundSafe.sol/SoulboundSafe.json';

const contractAddress = import.meta.env.VITE_CONTRACT_ADDRESS;

export default function App() {
  const { address } = useAccount();
  const [tokenId, setTokenId] = useState('');
  const [label, setLabel] = useState('');
  const [uri, setUri] = useState('');

  const { write: mint } = useContractWrite({
    address: contractAddress,
    abi: SoulboundSafe.abi,
    functionName: 'mint',
  });

  const { data } = useContractRead({
    address: contractAddress,
    abi: SoulboundSafe.abi,
    functionName: 'labelOf',
    args: tokenId ? [BigInt(tokenId)] : undefined,
  });

  return (
    <div className="space-y-4">
      <ConnectButton />
      <div>
        <input className="border p-1" placeholder="Token ID" value={tokenId} onChange={e=>setTokenId(e.target.value)} />
        <input className="border p-1" placeholder="Label" value={label} onChange={e=>setLabel(e.target.value)} />
        <input className="border p-1" placeholder="Metadata URI" value={uri} onChange={e=>setUri(e.target.value)} />
        <button className="bg-blue-500 text-white px-4" onClick={() => mint({ args:[address, BigInt(tokenId), label, uri] })}>Mint</button>
      </div>
      <div>Label: {data && data.toString()}</div>
    </div>
  );
}
