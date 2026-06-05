import { describe, it, expect } from 'vitest';
import { render, screen } from '@testing-library/react';
import App from './App';

function renderApp(initialRoute = '/') {
  window.history.pushState({}, '', initialRoute);
  return render(<App />);
}

describe('App', () => {
  it('renders sidebar brand', () => {
    renderApp();
    expect(screen.getByText('零电商管理')).toBeInTheDocument();
  });

  it('renders sidebar navigation items', () => {
    renderApp();
    expect(screen.getByText('📊 仪表盘')).toBeInTheDocument();
    expect(screen.getByText('📦 商品管理')).toBeInTheDocument();
    expect(screen.getByText('📋 订单管理')).toBeInTheDocument();
    expect(screen.getByText('🏗️ 库存管理')).toBeInTheDocument();
    expect(screen.getByText('👥 客户管理')).toBeInTheDocument();
    expect(screen.getByText('📈 销售报表')).toBeInTheDocument();
  });

  it('redirects / to /dashboard', () => {
    renderApp('/');
    expect(screen.getByText('仪表盘')).toBeInTheDocument();
  });

  it('renders dashboard page at /dashboard', () => {
    renderApp('/dashboard');
    expect(screen.getByText('仪表盘')).toBeInTheDocument();
    expect(screen.getByText('今日销售额')).toBeInTheDocument();
  });

  it('renders products page at /products', () => {
    renderApp('/products');
    expect(screen.getByText('商品管理')).toBeInTheDocument();
  });

  it('renders orders page at /orders', () => {
    renderApp('/orders');
    expect(screen.getByText('订单管理')).toBeInTheDocument();
  });
});
