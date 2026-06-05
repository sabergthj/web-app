# 部署设置指南

## ✅ 已完成 (不需要你动)

- ✅ React + Vite + TypeScript 项目骨架
- ✅ 电商管理面板 (6 模块: 仪表盘/商品/订单/库存/客户/报表)
- ✅ Vitest 单元测试 (6 测试, 覆盖率 100%)
- ✅ Playwright E2E 配置 (4 浏览器)
- ✅ ESLint + Prettier + eslint-plugin-security
- ✅ Husky pre-commit (format→lint→typecheck→audit→test)
- ✅ GitHub Actions CI/CD workflow (lint→test→security→build→deploy)
- ✅ OWASP ZAP DAST + Trivy SAST 配置
- ✅ Nginx 配置模板 (HTTPS/CSP/HSTS/SPA fallback)
- ✅ 零停机部署脚本 + 自动回滚
- ✅ VPS 部署 SSH 密钥对
- ✅ GitHub 仓库: https://github.com/sabergthj/web-app

---

## 需要你做的 (3 步)

### Step 1: 启用 GitHub Actions

```bash
gh auth refresh -h github.com -s workflow
git add .github/workflows/ci.yml
git commit -m "ci: 启用 CI/CD workflow"
git push origin master
```

### Step 2: 配置 VPS

```bash
# SSH 进 VPS
ssh root@你的VPS_IP

# 添加部署公钥
echo 'ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIFFpBOrEFaBSoAmrjLddZuCOXbPIaQ5bq6OZFgOiaQG1 web-app-deploy' >> ~/.ssh/authorized_keys

# 安装 Nginx (如果没有)
apt update && apt install -y nginx certbot python3-certbot-nginx

# 创建部署目录
mkdir -p /var/www/frontend
chown -R www-data:www-data /var/www/frontend
```

### Step 3: 设置 GitHub Secrets

在 https://github.com/sabergthj/web-app/settings/secrets/actions 添加:

| Secret 名称 | 值 |
|-------------|-----|
| `VPS_HOST` | 你的 VPS IP |
| `VPS_USER` | root |
| `VPS_SSH_KEY` | (见 deploy_key 文件内容) |
| `VPS_KNOWN_HOSTS` | 运行 `ssh-keyscan -H 你的VPS_IP` 得到 |

### 可选: 配置域名

1. DNS 添加 A 记录指向 VPS IP
2. 修改 `nginx/frontend.conf` 的 `server_name`
3. 运行 `certbot --nginx -d your-domain.com`
4. 部署后运行 `npm run security:headers` 验证安全头

---

## 常用命令

```bash
npm run dev          # 本地开发 (localhost:5173)
npm run ci:check     # 提交前完整检查
npm run deploy       # 部署到 VPS
npm run deploy:rollback  # 回滚
npm run security:all # 全量安全扫描
```

## 项目结构

```
src/pages/           # 6 个业务模块 (骨架已搭好, 你自己填内容)
src/components/      # 布局组件 (Layout with Sidebar)
e2e/                 # Playwright E2E 测试
scripts/             # 部署+安全脚本
nginx/               # Nginx 配置
.github/workflows/   # CI/CD (待你启用)
```
