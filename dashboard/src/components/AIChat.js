import React from 'react';
import { Bot } from 'lucide-react';

const AIChat = ({
  activeAI,
  chatMessages,
  onClose,
  onSend,
  onEvaluate,
  inputMessage,
  setInputMessage
}) => (
  activeAI ? (
    <div className="bg-white/10 backdrop-blur-md rounded-xl p-6 border border-white/20 mb-8">
      <div className="flex justify-between items-center mb-4">
        <h2 className="text-xl font-bold flex items-center gap-2">
          <Bot className="w-5 h-5" />
          {activeAI === 'education' ? 'Compliance Education AI' :
           activeAI === 'discovery' ? 'Asset Discovery AI' : 'Asset Evaluation AI'}
        </h2>
        <button onClick={onClose} className="text-slate-400 hover:text-white">✕</button>
      </div>

      <div className="h-64 overflow-y-auto mb-4 space-y-3">
        {chatMessages.map((msg, i) => (
          <div key={i} className={`p-3 rounded-lg ${msg.type === 'user' ? 'bg-blue-500/20 ml-8' : 'bg-white/10 mr-8'}`}>
            <p className="text-sm">{msg.content}</p>
          </div>
        ))}
        {chatMessages.length === 0 && (
          <div className="text-center text-slate-400 py-8">
            <div className="flex flex-wrap gap-2 mt-4 justify-center">
              {activeAI === 'education' && ['Compliance','Insurance','Partners','Legal Framework'].map(q => (
                <button key={q} onClick={() => onSend(q)} className="bg-white/10 px-3 py-1 rounded text-xs hover:bg-white/20">
                  {q}
                </button>
              ))}
              {activeAI === 'evaluation' && (
                <button onClick={onEvaluate} className="bg-blue-500 hover:bg-blue-600 px-4 py-2 rounded">
                  Evaluate Latest Submission
                </button>
              )}
            </div>
          </div>
        )}
      </div>

      {activeAI === 'education' && (
        <div className="flex gap-2">
          <input
            type="text"
            value={inputMessage}
            onChange={(e) => setInputMessage(e.target.value)}
            onKeyPress={(e) => e.key === 'Enter' && onSend(inputMessage)}
            placeholder="Ask about compliance, legal, or partners..."
            className="flex-1 bg-white/10 border border-white/20 rounded px-3 py-2 text-white placeholder-slate-400"
          />
          <button onClick={() => onSend(inputMessage)} className="bg-emerald-500 hover:bg-emerald-600 px-4 py-2 rounded">
            Ask
          </button>
        </div>
      )}
    </div>
  ) : null
);

export default AIChat;
