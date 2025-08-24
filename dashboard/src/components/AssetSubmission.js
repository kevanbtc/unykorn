import React from 'react';
import { Upload } from 'lucide-react';

const AssetSubmission = ({ assetSubmissions, onSubmit }) => (
  <div className="bg-white/10 backdrop-blur-md rounded-xl p-6 border border-white/20">
    <h3 className="text-lg font-bold mb-4 flex items-center gap-2">
      <Upload className="w-5 h-5" />
      Asset Submission Portal
    </h3>

    <div className="space-y-4">
      <div className="border-2 border-dashed border-white/30 rounded-lg p-6 text-center">
        <Upload className="w-8 h-8 mx-auto mb-2 text-slate-400" />
        <p className="text-sm text-slate-400 mb-2">Upload asset documentation</p>
        <input
          type="file"
          accept=".pdf,.json,.csv"
          onChange={(e) => e.target.files[0] && onSubmit(e.target.files[0], {
            symbol: 'NEW',
            name: 'New Asset',
            type: 'Token'
          })}
          className="hidden"
          id="file-upload"
        />
        <label htmlFor="file-upload" className="bg-blue-500 hover:bg-blue-600 px-4 py-2 rounded cursor-pointer text-sm">
          Choose Files
        </label>
      </div>

      <div className="space-y-2">
        {assetSubmissions.slice(-3).map(submission => (
          <div key={submission.id} className="bg-white/5 rounded p-3 text-sm">
            <div className="flex justify-between items-center">
              <span>{submission.fileName}</span>
              <span className={`px-2 py-1 rounded text-xs ${
                submission.status === 'Evaluated' ? 'bg-green-500/20 text-green-400' : 'bg-yellow-500/20 text-yellow-400'
              }`}>
                {submission.status}
              </span>
            </div>
            {submission.aiScore && (
              <div className="mt-2 text-xs text-slate-400">
                AI Score: {submission.aiScore}/100 | Compliance: {submission.complianceCheck}
              </div>
            )}
          </div>
        ))}
      </div>
    </div>
  </div>
);

export default AssetSubmission;
