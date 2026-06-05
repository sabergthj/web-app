import { describe, it, expect } from 'vitest';
import { render, screen } from '@testing-library/react';
import App from './App';

describe('App', () => {
  it('renders the welcome heading', () => {
    render(<App />);
    expect(screen.getByRole('heading', { level: 1 })).toBeInTheDocument();
  });

  it('renders the Vite + React logos', () => {
    render(<App />);
    const logos = screen.getAllByRole('img');
    expect(logos.length).toBeGreaterThanOrEqual(2);
  });

  it('has a counter button that increments', async () => {
    const { userEvent } = await import('@testing-library/user-event');
    render(<App />);
    const user = userEvent.setup();

    const button = screen.getByRole('button');
    expect(button).toHaveTextContent(/count is 0/i);

    await user.click(button);
    expect(button).toHaveTextContent(/count is 1/i);
  });
});
