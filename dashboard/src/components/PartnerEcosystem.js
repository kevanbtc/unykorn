import React from 'react';
import { Users } from 'lucide-react';

export const partnerServices = {
  chainlink: { name: 'Chainlink', icon: '⛓️', status: 'Connected', function: 'Price Oracles' },
  insurance: { name: 'Nexus Mutual', icon: '🛡️', status: 'Active', function: 'Smart Contract Insurance' },
  custodialBank: { name: 'Fireblocks', icon: '🏦', status: 'Integrated', function: 'Institutional Custody' },
  ipfs: { name: 'IPFS Network', icon: '🌐', status: 'Live', function: 'Decentralized Storage' },
  compliance: { name: 'Chainalysis', icon: '⚖️', status: 'Monitoring', function: 'AML/KYC Compliance' }
};

const PartnerEcosystem = () => (
  <div className="bg-white/10 backdrop-blur-md rounded-xl p-6 border border-white/20 mb-8">
    <h2 className="text-xl font-bold mb-4 flex items-center gap-2">
      <Users className="w-5 h-5" />
      Partner Ecosystem
    </h2>
    <div className="grid grid-cols-1 md:grid-cols-5 gap-4">
      {Object.entries(partnerServices).map(([key, service]) => (
        <div key={key} className="bg-white/5 rounded-lg p-3 text-center">
          <div className="text-2xl mb-2">{service.icon}</div>
          <div className="font-semibold text-sm">{service.name}</div>
          <div className="text-xs text-green-400">{service.status}</div>
          <div className="text-xs text-slate-400 mt-1">{service.function}</div>
        </div>
      ))}
    </div>
  </div>
);

export default PartnerEcosystem;
