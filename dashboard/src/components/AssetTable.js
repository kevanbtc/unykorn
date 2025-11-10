import React from 'react';
import { CheckCircle, AlertTriangle } from 'lucide-react';

const AssetTable = ({ assets }) => (
  <div className="overflow-x-auto">
    <table className="w-full">
      <thead>
        <tr className="border-b border-white/20">
          <th className="text-left py-3 px-4">Asset</th>
          <th className="text-right py-3 px-4">Balance</th>
          <th className="text-right py-3 px-4">Price</th>
          <th className="text-right py-3 px-4">Value USD</th>
          <th className="text-right py-3 px-4">LTV</th>
          <th className="text-center py-3 px-4">Status</th>
          <th className="text-center py-3 px-4">Compliance</th>
        </tr>
      </thead>
      <tbody>
        {assets.map(asset => (
          <tr key={asset.id} className="border-b border-white/10 hover:bg-white/5">
            <td className="py-4 px-4">
              <div>
                <div className="font-semibold">{asset.name}</div>
                <div className="text-sm text-slate-400">{asset.symbol}</div>
                <div className="text-xs text-slate-500 font-mono">{asset.address.slice(0,10)}...</div>
                <div className="text-xs text-slate-500">IPFS: {asset.ipfsHash}</div>
              </div>
            </td>
            <td className="text-right py-4 px-4">{asset.balance.toLocaleString()}</td>
            <td className="text-right py-4 px-4">${asset.price.toFixed(2)}</td>
            <td className="text-right py-4 px-4">${asset.valueUSD.toLocaleString()}</td>
            <td className="text-right py-4 px-4">{asset.ltv}%</td>
            <td className="text-center py-4 px-4">
              {asset.active ? (
                <CheckCircle className="w-5 h-5 text-green-400 mx-auto" />
              ) : (
                <AlertTriangle className="w-5 h-5 text-yellow-400 mx-auto" />
              )}
            </td>
            <td className="text-center py-4 px-4">
              <span className={`px-2 py-1 rounded text-xs ${asset.compliance === 'Approved' ? 'bg-green-500/20 text-green-400' : 'bg-yellow-500/20 text-yellow-400'}`}>
                {asset.compliance}
              </span>
            </td>
          </tr>
        ))}
      </tbody>
    </table>
  </div>
);

export default AssetTable;
