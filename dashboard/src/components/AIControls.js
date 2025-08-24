import React from 'react';
import { BookOpen, Search, Bot } from 'lucide-react';

const AIControls = ({ setActiveAI }) => (
  <div className="grid grid-cols-1 md:grid-cols-3 gap-4 mb-8">
    <button
      onClick={() => setActiveAI('education')}
      className="bg-emerald-500/20 hover:bg-emerald-500/30 border border-emerald-500/50 rounded-xl p-4 flex items-center gap-3"
    >
      <BookOpen className="w-6 h-6 text-emerald-400" />
      <div className="text-left">
        <h3 className="font-semibold">Education AI</h3>
        <p className="text-sm text-slate-300">Learn compliance and legal framework</p>
      </div>
    </button>

    <button
      onClick={() => setActiveAI('discovery')}
      className="bg-purple-500/20 hover:bg-purple-500/30 border border-purple-500/50 rounded-xl p-4 flex items-center gap-3"
    >
      <Search className="w-6 h-6 text-purple-400" />
      <div className="text-left">
        <h3 className="font-semibold">Asset Discovery AI</h3>
        <p className="text-sm text-slate-300">Find verified institutional assets</p>
      </div>
    </button>

    <button
      onClick={() => setActiveAI('evaluation')}
      className="bg-blue-500/20 hover:bg-blue-500/30 border border-blue-500/50 rounded-xl p-4 flex items-center gap-3"
    >
      <Bot className="w-6 h-6 text-blue-400" />
      <div className="text-left">
        <h3 className="font-semibold">Evaluation AI</h3>
        <p className="text-sm text-slate-300">Analyze submitted assets</p>
      </div>
    </button>
  </div>
);

export default AIControls;
