import Link from 'next/link';

export default function Home() {
  return (
    <div>
      <h1>FTH Platform</h1>
      <ul>
        <li><Link href="/projectForm">Create Project</Link></li>
        <li><Link href="/dashboard">Dashboard</Link></li>
      </ul>
    </div>
  );
}
