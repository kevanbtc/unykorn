import React from 'react';
import { render, screen } from '@testing-library/react';
import Dashboard from '../Dashboard';
import '@testing-library/jest-dom';

test('renders TrustUSDx header', () => {
  render(<Dashboard />);
  expect(screen.getByText(/TrustUSDx Enterprise Platform/i)).toBeInTheDocument();
});
