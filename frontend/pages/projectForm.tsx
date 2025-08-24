import { useState } from 'react';

export default function ProjectForm() {
  const [form, setForm] = useState({});

  function handleSubmit(e: React.FormEvent) {
    e.preventDefault();
    // TODO: send to backend
    console.log(form);
  }

  return (
    <form onSubmit={handleSubmit}>
      <h2>Project Inputs</h2>
      <button type="submit">Generate</button>
    </form>
  );
}
