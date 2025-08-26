"use client";

import { useEffect, useState } from "react";
import { ExternalLink } from "lucide-react";

interface FundingProgram {
  program: string;
  eligibility: string;
  amount: string;
  deadline: string;
  applyLink: string;
  unykornFit: string;
}

export default function FundingDashboard() {
  const [programs, setPrograms] = useState<FundingProgram[]>([]);
  const [search, setSearch] = useState("");
  const [filter, setFilter] = useState("All");

  useEffect(() => {
    fetch("/api/funding")
      .then((res) => res.json())
      .then((data) => setPrograms(data))
      .catch((err) => console.error("Error loading funding data", err));
  }, []);

  const filtered = programs.filter((p) => {
    const matchesSearch =
      p.program.toLowerCase().includes(search.toLowerCase()) ||
      p.eligibility.toLowerCase().includes(search.toLowerCase()) ||
      p.unykornFit.toLowerCase().includes(search.toLowerCase());
    const matchesFilter = filter === "All" || p.unykornFit.includes(filter);
    return matchesSearch && matchesFilter;
  });

  return (
    <div className="p-8 max-w-6xl mx-auto">
      <h1 className="text-3xl font-bold mb-6">Funding & Partnerships Dashboard</h1>

      <div className="flex gap-4 mb-6">
        <input
          type="text"
          placeholder="Search grants..."
          className="w-full border p-2 rounded-md"
          value={search}
          onChange={(e) => setSearch(e.target.value)}
        />
        <select
          className="border p-2 rounded-md"
          value={filter}
          onChange={(e) => setFilter(e.target.value)}
        >
          <option value="All">All Categories</option>
          <option value="Education">Education</option>
          <option value="R&D">R&D</option>
          <option value="Blockchain">Blockchain</option>
          <option value="ESG">ESG</option>
        </select>
      </div>

      <div className="overflow-x-auto">
        <table className="w-full border-collapse bg-white shadow-lg rounded-lg">
          <thead className="bg-gray-100">
            <tr>
              <th className="p-3 text-left">Program</th>
              <th className="p-3 text-left">Eligibility</th>
              <th className="p-3 text-left">Amount</th>
              <th className="p-3 text-left">Deadline</th>
              <th className="p-3 text-center">Apply</th>
              <th className="p-3 text-left">Unykorn Fit</th>
            </tr>
          </thead>
          <tbody>
            {filtered.map((p, i) => (
              <tr key={i} className="border-b hover:bg-gray-50">
                <td className="p-3 font-medium">{p.program}</td>
                <td className="p-3">{p.eligibility}</td>
                <td className="p-3">{p.amount}</td>
                <td
                  className={`p-3 ${
                    isUrgent(p.deadline) === "urgent"
                      ? "text-red-600 font-bold"
                      : isUrgent(p.deadline) === "soon"
                      ? "text-orange-500"
                      : ""
                  }`}
                >
                  {p.deadline}
                </td>
                <td className="p-3 text-center">
                  <a
                    href={p.applyLink}
                    target="_blank"
                    rel="noopener noreferrer"
                    className="inline-flex items-center px-3 py-1 bg-green-600 text-white rounded-md hover:bg-green-700"
                  >
                    Apply <ExternalLink size={14} className="ml-1" />
                  </a>
                </td>
                <td className="p-3">{p.unykornFit}</td>
              </tr>
            ))}
          </tbody>
        </table>
      </div>
    </div>
  );
}

function isUrgent(deadline: string) {
  if (deadline.toLowerCase().includes("rolling")) return "none";
  const date = new Date(deadline);
  const today = new Date();
  const diff = (date.getTime() - today.getTime()) / (1000 * 60 * 60 * 24);
  if (diff < 7) return "urgent";
  if (diff < 30) return "soon";
  return "none";
}

