# CLAUDE.md — 小光项目上下文

## 项目: 零电商管理 (Zero E-Commerce Manager)

React + Vite + TypeScript 全自动化电商管理系统，部署到 VPS (Nginx)。

## 功能模块

- 📊 仪表盘 — 销售概览、关键指标
- 📦 商品管理 — 商品 CRUD、分类、定价
- 📋 订单管理 — 订单列表、状态流转、退款、物流
- 🏗️ 库存管理 — 库存查询、出入库、预警
- 👥 客户管理 — 客户列表、分组、消费记录
- 📈 销售报表 — 营收趋势、商品排行、导出

## 架构

- **前端框架**: React 19 + TypeScript 6 + React Router v7
- **构建工具**: Vite 8
- **样式**: CSS Modules
- **测试**: Vitest (单元/组件) + Playwright (E2E, 4 浏览器)
- **Lint**: ESLint + Prettier + eslint-plugin-security
- **CI/CD**: GitHub Actions (lint → test → security → build → deploy)
- **部署**: rsync → VPS Nginx，零停机切换 + 自动回滚

## 技术约束

- Strict TypeScript (`tsc --noEmit` 零容忍)
- 测试覆盖率 ≥ 80% (branches, functions, lines, statements)
- Pre-commit hook 自动运行: format → lint → typecheck → audit → test
- CSP headers 在 Nginx 层配置，前端不要内联脚本
- 所有 API 调用使用 `fetch`，统一错误处理
- 组件遵循: 一个组件一个文件夹 (Component/index.tsx + Component.test.tsx)

## 关键命令

```bash
npm run dev              # 开发服务器 (localhost:5173)
npm run build            # 生产构建
npm run preview          # 预览生产构建 (localhost:4173)
npm run test:unit        # Vitest 运行一次
npm run test:unit:watch  # Vitest 交互模式
npm run test:e2e         # Playwright E2E
npm run test:all         # 全部测试
npm run lint             # ESLint
npm run format           # Prettier
npm run security:audit   # npm audit
npm run security:all     # 全量安全扫描
npm run ci:check         # CI 完整检查
npm run deploy           # 部署到 VPS
```

## 目录结构

```
web-app/
├── src/                    # 源代码
│   ├── components/         # React 组件
│   ├── hooks/              # 自定义 hooks
│   ├── utils/              # 工具函数
│   ├── App.tsx
│   └── main.tsx
├── e2e/                    # Playwright E2E 测试
├── scripts/                # 运维脚本
│   ├── deploy.sh           # 部署脚本
│   ├── rollback.sh         # 回滚脚本
│   ├── zap-scan.sh         # ZAP 安全扫描
│   └── security-headers.sh # 安全头检查
├── nginx/                  # Nginx 配置模板
├── .github/workflows/      # CI/CD
├── .husky/                 # Git hooks
├── .zap/                   # OWASP ZAP 规则
└── vite.config.ts          # Vite + Vitest 配置
```

## 代码规范

- 2 空格缩进
- 单引号，必须有分号
- 组件: PascalCase，文件: kebab-case (组件文件夹) 或 camelCase (工具)
- 测试文件: `*.test.ts(x)` 放在源文件同级，E2E 放 `e2e/`
- CSS: CSS Modules (`*.module.css`) 或 Tailwind (待定)
- 无 `any` (warn 级别)，未使用变量以 `_` 开头忽略

## 安全注意事项

- **禁止**: `eval()`, `innerHTML` 直接赋值, 内联事件处理器
- **使用**: `textContent`, `DOMPurify` (如需富文本), React 的 JSX 安全转义
- **API 调用**: 始终检查 `response.ok`，处理网络错误
- **环境变量**: 使用 `import.meta.env.VITE_*` 前缀
- **依赖**: CI 阻断 HIGH/CRITICAL 级别的 `npm audit`
