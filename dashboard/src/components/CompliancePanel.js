import React from 'react';
import { FileText, CheckCircle } from 'lucide-react';

const CompliancePanel = () => (
  <div className="bg-white/10 backdrop-blur-md rounded-xl p-6 border border-white/20">
    <h3 className="text-lg font-bold mb-4 flex items-center gap-2">
      <FileText className="w-5 h-5" />
      Compliance & Documentation
    </h3>

    <div className="space-y-3">
      {['Legal Framework','IPFS Documentation','AML/KYC Verification','Insurance Coverage','Regulatory Approval'].map(item => (
        <div key={item} className="flex items-center justify-between">
          <span className="text-sm">{item}</span>
          <CheckCircle className="w-4 h-4 text-green-400" />
        </div>
      ))}
    </div>

    <button className="w-full bg-emerald-500 hover:bg-emerald-600 px-4 py-2 rounded mt-4">
      Generate Compliance Report
    </button>
  </div>
);

export default CompliancePanel;
