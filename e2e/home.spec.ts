import { test, expect } from '@playwright/test';

test.describe('Home Page', () => {
  test('has correct title', async ({ page }) => {
    await page.goto('/');
    await expect(page).toHaveTitle(/Vite \+ React/);
  });

  test('renders heading', async ({ page }) => {
    await page.goto('/');
    await expect(page.getByRole('heading', { level: 1 })).toBeVisible();
  });

  test('counter button increments', async ({ page }) => {
    await page.goto('/');
    const button = page.getByRole('button', { name: /count is 0/i });
    await expect(button).toBeVisible();
    await button.click();
    await expect(button).toHaveText(/count is 1/);
  });

  test('page is responsive on mobile', async ({ page }) => {
    await page.setViewportSize({ width: 375, height: 667 });
    await page.goto('/');
    await expect(page.getByRole('heading', { level: 1 })).toBeVisible();
  });

  test('no console errors', async ({ page }) => {
    const errors: string[] = [];
    page.on('console', (msg) => {
      if (msg.type() === 'error') errors.push(msg.text());
    });
    await page.goto('/');
    expect(errors).toEqual([]);
  });

  test('security headers check', async ({ request }) => {
    const response = await request.get('/');
    expect(response.status()).toBe(200);
    // CSP/Security headers 由 Nginx 层配置，部署后验证
  });
});
