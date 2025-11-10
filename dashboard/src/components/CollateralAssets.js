import React from 'react';
import { PlusCircle } from 'lucide-react';
import AddAssetForm from './AddAssetForm';
import AssetTable from './AssetTable';

const CollateralAssets = ({ assets, showAddForm, setShowAddForm, newAsset, setNewAsset, onAddAsset }) => (
  <div className="bg-white/10 backdrop-blur-md rounded-xl p-6 border border-white/20 mb-8">
    <div className="flex justify-between items-center mb-6">
      <h2 className="text-2xl font-bold">Collateral Assets</h2>
      <button onClick={() => setShowAddForm(!showAddForm)}
        className="bg-blue-500 hover:bg-blue-600 px-4 py-2 rounded-lg flex items-center gap-2 transition-colors">
        <PlusCircle className="w-4 h-4" />
        Add Asset
      </button>
    </div>

    {showAddForm && (
      <AddAssetForm
        newAsset={newAsset}
        setNewAsset={setNewAsset}
        onAdd={onAddAsset}
        onCancel={() => setShowAddForm(false)}
      />
    )}

    <AssetTable assets={assets} />
  </div>
);

export default CollateralAssets;
