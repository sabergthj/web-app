#!/usr/bin/env bash
# ============================================================
# 部署脚本 — 零停机部署到 VPS
# 用法: bash scripts/deploy.sh [--staging|--production]
# 环境变量:
#   VPS_HOST    — 服务器 IP/域名
#   VPS_USER    — SSH 用户名 (默认 root)
#   VPS_KEY     — SSH 私钥路径 (默认 ~/.ssh/id_rsa)
#   DEPLOY_PATH — 部署路径 (默认 /var/www/frontend)
# ============================================================
set -e

ENV="${1:---production}"
VPS_HOST="${VPS_HOST:?请设置 VPS_HOST 环境变量}"
VPS_USER="${VPS_USER:-root}"
VPS_KEY="${VPS_KEY:-$HOME/.ssh/id_rsa}"
DEPLOY_PATH="${DEPLOY_PATH:-/var/www/frontend}"
TIMESTAMP=$(date +%Y%m%d-%H%M%S)

SSH="ssh -i $VPS_KEY -o StrictHostKeyChecking=no $VPS_USER@$VPS_HOST"
RSYNC="rsync -avz --delete -e 'ssh -i $VPS_KEY -o StrictHostKeyChecking=no'"

echo "🚀 开始部署..."
echo "   目标: $VPS_USER@$VPS_HOST:$DEPLOY_PATH"
echo "   环境: $ENV"

# 1. 运行完整检查
echo ""
echo "📋 Step 1/6: 预部署检查..."
npm run format:check
npm run lint
npm run typecheck
echo "   ✅ 代码检查通过"

echo ""
echo "📋 Step 2/6: 运行测试..."
npm run test:unit -- --reporter=verbose
echo "   ✅ 测试通过"

echo ""
echo "📋 Step 3/6: 安全审计..."
npm audit --audit-level=high || {
  echo "   ⚠️  发现高危漏洞，是否继续? (y/n)"
  read -r CONTINUE
  [ "$CONTINUE" != "y" ] && exit 1
}

echo ""
echo "📋 Step 4/6: 构建..."
npm run build
echo "   ✅ 构建完成"

echo ""
echo "📋 Step 5/6: 上传到 VPS..."
# 上传到临时目录
eval "$RSYNC dist/ $VPS_USER@$VPS_HOST:${DEPLOY_PATH}-new/"
echo "   ✅ 上传完成"

echo ""
echo "📋 Step 6/6: 零停机切换..."
$SSH bash -s << ENDSSH
set -e

# 验证新版本文件存在
if [ ! -f ${DEPLOY_PATH}-new/index.html ]; then
  echo "❌ 新版本缺少 index.html，部署中止"
  exit 1
fi

# 备份当前版本
if [ -d $DEPLOY_PATH ]; then
  echo "   📦 备份当前版本 → ${DEPLOY_PATH}-backup-$TIMESTAMP"
  cp -a $DEPLOY_PATH ${DEPLOY_PATH}-backup-$TIMESTAMP
fi

# 原子切换
echo "   🔄 切换到新版本..."
rm -rf $DEPLOY_PATH
mv ${DEPLOY_PATH}-new $DEPLOY_PATH

# 更新权限
chown -R www-data:www-data $DEPLOY_PATH 2>/dev/null || true
chmod -R 755 $DEPLOY_PATH

# 验证 Nginx 配置
echo "   🔍 验证 Nginx 配置..."
nginx -t

# 平滑重启
echo "   🔄 重启 Nginx..."
nginx -s reload

# 健康检查
sleep 2
HTTP_CODE=\$(curl -s -o /dev/null -w "%{http_code}" https://localhost/health || echo "000")
if [ "\$HTTP_CODE" = "200" ]; then
  echo "   ✅ 健康检查通过 (HTTP \$HTTP_CODE)"
else
  echo "   ❌ 健康检查失败 (HTTP \$HTTP_CODE)，回滚..."
  rm -rf $DEPLOY_PATH
  mv ${DEPLOY_PATH}-backup-$TIMESTAMP $DEPLOY_PATH
  nginx -s reload
  exit 1
fi

echo ""
echo "✅ 部署成功！"
ENDSSH

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "  🎉 部署完成 — 自动回滚备份保留在 VPS"
echo "  回滚命令: npm run deploy:rollback"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
