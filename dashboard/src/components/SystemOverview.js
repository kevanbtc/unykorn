import React from 'react';
import { DollarSign, TrendingUp, Shield, PlusCircle } from 'lucide-react';

const SystemOverview = ({ systemStats, totalCollateralValue, healthScore, mintMoreUSDx }) => (
  <div className="grid grid-cols-1 md:grid-cols-4 gap-6 mb-8">
    <div className="bg-white/10 backdrop-blur-md rounded-xl p-6 border border-white/20">
      <div className="flex items-center justify-between mb-2">
        <DollarSign className="text-green-400 w-8 h-8" />
        <span className="text-2xl font-bold">{systemStats.totalUSDx.toLocaleString()}</span>
      </div>
      <p className="text-slate-300 text-sm">Total USDx Supply</p>
    </div>

    <div className="bg-white/10 backdrop-blur-md rounded-xl p-6 border border-white/20">
      <div className="flex items-center justify-between mb-2">
        <TrendingUp className="text-blue-400 w-8 h-8" />
        <span className="text-2xl font-bold">${totalCollateralValue.toLocaleString()}</span>
      </div>
      <p className="text-slate-300 text-sm">Total Collateral Value</p>
    </div>

    <div className="bg-white/10 backdrop-blur-md rounded-xl p-6 border border-white/20">
      <div className="flex items-center justify-between mb-2">
        <Shield className={`w-8 h-8 ${healthScore === 'Excellent' ? 'text-green-400' : healthScore === 'Good' ? 'text-yellow-400' : 'text-red-400'}`} />
        <span className="text-2xl font-bold">{systemStats.collateralRatio.toFixed(1)}%</span>
      </div>
      <p className="text-slate-300 text-sm">Collateral Ratio</p>
      <p className={`text-xs mt-1 ${healthScore === 'Excellent' ? 'text-green-400' : healthScore === 'Good' ? 'text-yellow-400' : 'text-red-400'}`}>{healthScore}</p>
    </div>

    <div className="bg-white/10 backdrop-blur-md rounded-xl p-6 border border-white/20">
      <div className="flex items-center justify-between mb-2">
        <PlusCircle className="text-purple-400 w-8 h-8" />
        <span className="text-2xl font-bold">{systemStats.maxMintable.toLocaleString()}</span>
      </div>
      <p className="text-slate-300 text-sm">Max Mintable USDx</p>
      <button
        onClick={() => mintMoreUSDx(Math.min(10000, systemStats.maxMintable))}
        className="bg-purple-500 hover:bg-purple-600 px-3 py-1 rounded text-xs mt-2 transition-colors"
        disabled={systemStats.maxMintable < 1000}
      >
        Mint 10k USDx
      </button>
    </div>
  </div>
);

export default SystemOverview;
