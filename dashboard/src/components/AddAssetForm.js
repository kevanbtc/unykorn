import React from 'react';

const AddAssetForm = ({ newAsset, setNewAsset, onAdd, onCancel }) => (
  <div className="bg-white/5 rounded-lg p-4 mb-6 border border-white/10">
    <h3 className="text-lg font-semibold mb-4">Add New Collateral Asset</h3>
    <div className="grid grid-cols-1 md:grid-cols-3 gap-4 mb-4">
      <input type="text" placeholder="Asset Name" value={newAsset.name}
        onChange={(e) => setNewAsset(prev => ({...prev, name: e.target.value}))}
        className="bg-white/10 border border-white/20 rounded px-3 py-2 text-white placeholder-slate-400" />
      <input type="text" placeholder="Symbol (e.g. USDC)" value={newAsset.symbol}
        onChange={(e) => setNewAsset(prev => ({...prev, symbol: e.target.value}))}
        className="bg-white/10 border border-white/20 rounded px-3 py-2 text-white placeholder-slate-400" />
      <input type="text" placeholder="Contract Address" value={newAsset.address}
        onChange={(e) => setNewAsset(prev => ({...prev, address: e.target.value}))}
        className="bg-white/10 border border-white/20 rounded px-3 py-2 text-white placeholder-slate-400" />
      <input type="number" placeholder="Balance" value={newAsset.balance}
        onChange={(e) => setNewAsset(prev => ({...prev, balance: e.target.value}))}
        className="bg-white/10 border border-white/20 rounded px-3 py-2 text-white placeholder-slate-400" />
      <input type="number" placeholder="Price USD" step="0.01" value={newAsset.price}
        onChange={(e) => setNewAsset(prev => ({...prev, price: e.target.value}))}
        className="bg-white/10 border border-white/20 rounded px-3 py-2 text-white placeholder-slate-400" />
      <input type="number" placeholder="LTV %" min="50" max="95" value={newAsset.ltv}
        onChange={(e) => setNewAsset(prev => ({...prev, ltv: parseInt(e.target.value)}))}
        className="bg-white/10 border border-white/20 rounded px-3 py-2 text-white placeholder-slate-400" />
    </div>
    <div className="flex gap-2">
      <button onClick={onAdd} className="bg-green-500 hover:bg-green-600 px-4 py-2 rounded transition-colors">
        Add Asset
      </button>
      <button onClick={onCancel} className="bg-gray-500 hover:bg-gray-600 px-4 py-2 rounded transition-colors">
        Cancel
      </button>
    </div>
  </div>
);

export default AddAssetForm;
