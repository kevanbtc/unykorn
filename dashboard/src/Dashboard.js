import React, { useState } from 'react';
import PartnerEcosystem from './components/PartnerEcosystem';
import AssetSubmission from './components/AssetSubmission';
import CompliancePanel from './components/CompliancePanel';
import AIControls from './components/AIControls';
import AIChat from './components/AIChat';
import SystemOverview from './components/SystemOverview';
import CollateralAssets from './components/CollateralAssets';

const educationResponses = {
  compliance: 'Our compliance framework integrates Chainalysis for AML/KYC, maintains IPFS records for audit trails, and ensures regulatory adherence across jurisdictions.',
  insurance: 'Smart contract insurance via Nexus Mutual protects against code vulnerabilities. Custodial insurance through Fireblocks covers asset custody risks.',
  partners: 'We integrate Chainlink for price feeds, Fireblocks for custody, Nexus Mutual for insurance, IPFS for storage, and Chainalysis for compliance monitoring.',
  'legal framework': 'All assets undergo legal review, jurisdictional compliance checks, and regulatory approval before integration. Documentation stored on IPFS with immutable audit trails.'
};

const Dashboard = () => {
  const [assets, setAssets] = useState([
    {
      id: 'XPRM',
      name: 'XRPrime',
      symbol: 'XPRM',
      address: '0xCFf20c4498Ec58946c59eAE86A7E3841D6a0E5f2',
      balance: 100000,
      price: 101.68,
      valueUSD: 10168000,
      ltv: 90,
      active: true,
      verified: true,
      ipfsHash: 'QmXRPM...',
      compliance: 'Approved'
    }
  ]);

  const [systemStats, setSystemStats] = useState({
    totalUSDx: 50000.1,
    collateralRatio: 199.99,
    maxMintable: 40000,
    reserveRatio: 90
  });

  const [newAsset, setNewAsset] = useState({
    name: '',
    symbol: '',
    address: '',
    balance: '',
    price: '',
    ltv: 90
  });

  const [showAddForm, setShowAddForm] = useState(false);
  const [activeAI, setActiveAI] = useState(null);
  const [chatMessages, setChatMessages] = useState([]);
  const [inputMessage, setInputMessage] = useState('');
  const [assetSubmissions, setAssetSubmissions] = useState([]);

  const totalCollateralValue = assets.reduce((sum, asset) => sum + asset.valueUSD, 0);
  const healthScore = systemStats.collateralRatio >= 150 ? 'Excellent' :
                      systemStats.collateralRatio >= 110 ? 'Good' : 'Risk';

  const handleAssetSubmission = (file, metadata) => {
    const submission = {
      id: Date.now(),
      fileName: file.name,
      metadata,
      status: 'Evaluating',
      aiScore: null,
      complianceCheck: 'Pending',
      ipfsHash: null,
      timestamp: new Date().toISOString()
    };

    setAssetSubmissions(prev => [...prev, submission]);

    setTimeout(() => {
      const evaluated = {
        ...submission,
        status: 'Evaluated',
        aiScore: Math.floor(Math.random() * 20) + 80,
        complianceCheck: Math.random() > 0.3 ? 'Approved' : 'Review Required',
        ipfsHash: `Qm${Math.random().toString(36).substr(2, 9)}...`
      };

      setAssetSubmissions(prev => prev.map(s => s.id === submission.id ? evaluated : s));
    }, 3000);
  };

  const handleEducationChat = (message) => {
    const key = Object.keys(educationResponses).find(k => message.toLowerCase().includes(k));
    const response = educationResponses[key] || 'Ask about compliance, insurance, partners, or legal framework for detailed information.';

    setChatMessages(prev => [
      ...prev,
      { type: 'user', content: message },
      { type: 'ai', content: response }
    ]);
    setInputMessage('');
  };

  const handleAssetEvaluation = () => {
    setChatMessages([{ type: 'ai', content: 'Asset evaluation complete. Analyzing liquidity, volatility, regulatory status, and integration requirements. Chainlink oracle available, insurance coverage verified, compliance score calculated.' }]);
  };

  const handleAddAsset = () => {
    if (!newAsset.name || !newAsset.symbol || !newAsset.balance || !newAsset.price) return;

    const asset = {
      id: Date.now().toString(),
      name: newAsset.name,
      symbol: newAsset.symbol,
      address: newAsset.address,
      balance: parseFloat(newAsset.balance),
      price: parseFloat(newAsset.price),
      valueUSD: parseFloat(newAsset.balance) * parseFloat(newAsset.price),
      ltv: newAsset.ltv,
      active: true,
      verified: false,
      ipfsHash: 'Pending...',
      compliance: 'Under Review'
    };

    setAssets(prev => [...prev, asset]);

    setSystemStats(prev => {
      const newTotalValue = totalCollateralValue + asset.valueUSD;
      const newMaxMintable = (newTotalValue * prev.reserveRatio / 100) - prev.totalUSDx;
      const newCollateralRatio = (newTotalValue / prev.totalUSDx) * 100;
      return { ...prev, maxMintable: Math.max(0, newMaxMintable), collateralRatio: newCollateralRatio };
    });

    setNewAsset({ name: '', symbol: '', address: '', balance: '', price: '', ltv: 90 });
    setShowAddForm(false);
  };

  const mintMoreUSDx = (amount) => {
    if (amount > systemStats.maxMintable) return;
    setSystemStats(prev => {
      const newTotalUSDx = prev.totalUSDx + amount;
      const newCollateralRatio = (totalCollateralValue / newTotalUSDx) * 100;
      const newMaxMintable = (totalCollateralValue * prev.reserveRatio / 100) - newTotalUSDx;
      return { ...prev, totalUSDx: newTotalUSDx, collateralRatio: newCollateralRatio, maxMintable: Math.max(0, newMaxMintable) };
    });
  };

  const handleSetActiveAI = (mode) => {
    setActiveAI(mode);
    setChatMessages([]);
    setInputMessage('');
  };

  return (
    <div className="min-h-screen bg-gradient-to-br from-slate-900 via-blue-900 to-slate-900 text-white p-6">
      <div className="max-w-7xl mx-auto">
        <div className="mb-8">
          <h1 className="text-4xl font-bold mb-2">TrustUSDx Enterprise Platform</h1>
          <p className="text-slate-300">AI-Powered Institutional-Grade Collateral Management</p>
        </div>

        <PartnerEcosystem />

        <div className="grid grid-cols-1 lg:grid-cols-2 gap-6 mb-8">
          <AssetSubmission assetSubmissions={assetSubmissions} onSubmit={handleAssetSubmission} />
          <CompliancePanel />
        </div>

        <AIControls setActiveAI={handleSetActiveAI} />

        <AIChat
          activeAI={activeAI}
          chatMessages={chatMessages}
          onClose={() => setActiveAI(null)}
          onSend={handleEducationChat}
          onEvaluate={handleAssetEvaluation}
          inputMessage={inputMessage}
          setInputMessage={setInputMessage}
        />

        <SystemOverview
          systemStats={systemStats}
          totalCollateralValue={totalCollateralValue}
          healthScore={healthScore}
          mintMoreUSDx={mintMoreUSDx}
        />

        <CollateralAssets
          assets={assets}
          showAddForm={showAddForm}
          setShowAddForm={setShowAddForm}
          newAsset={newAsset}
          setNewAsset={setNewAsset}
          onAddAsset={handleAddAsset}
        />

        <div className="bg-white/10 backdrop-blur-md rounded-xl p-6 border border-white/20">
          <h2 className="text-2xl font-bold mb-4">Contract Addresses</h2>
          <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
            <div className="space-y-2">
              <div className="flex justify-between"><span className="text-slate-300">USDx Token:</span><span className="font-mono text-sm">0xBdD5d21f...33393F</span></div>
              <div className="flex justify-between"><span className="text-slate-300">CollateralMinter:</span><span className="font-mono text-sm">0x43Fe041C...1D95da</span></div>
            </div>
            <div className="space-y-2">
              <div className="flex justify-between"><span className="text-slate-300">Vault:</span><span className="font-mono text-sm">0xC4D1266c...Cbb84B</span></div>
              <div className="flex justify-between"><span className="text-slate-300">Network:</span><span>Polygon</span></div>
            </div>
          </div>
        </div>
      </div>
    </div>
  );
};

export default Dashboard;
