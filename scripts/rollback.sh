#!/usr/bin/env bash
# ============================================================
# 回滚脚本 — 快速回滚到上一个版本
# 用法: bash scripts/rollback.sh [backup-timestamp]
# 不加参数列出所有备份，加时间戳回滚到指定版本
# ============================================================
set -e

VPS_HOST="${VPS_HOST:?请设置 VPS_HOST 环境变量}"
VPS_USER="${VPS_USER:-root}"
VPS_KEY="${VPS_KEY:-$HOME/.ssh/id_rsa}"
DEPLOY_PATH="${DEPLOY_PATH:-/var/www/frontend}"

SSH="ssh -i $VPS_KEY -o StrictHostKeyChecking=no $VPS_USER@$VPS_HOST"

if [ -z "$1" ]; then
  echo "📦 可用备份:"
  $SSH "ls -d ${DEPLOY_PATH}-backup-* 2>/dev/null | sort -r" || echo "  (无备份)"
  echo ""
  echo "用法: npm run deploy:rollback -- <timestamp>"
  echo "示例: npm run deploy:rollback -- 20260606-120000"
  exit 0
fi

BACKUP="$1"
echo "⏪ 回滚到 $BACKUP..."

$SSH bash -s << ENDSSH
set -e

BACKUP_DIR="${DEPLOY_PATH}-backup-$BACKUP"

if [ ! -d "\$BACKUP_DIR" ]; then
  echo "❌ 备份不存在: \$BACKUP_DIR"
  exit 1
fi

# 备份当前版本
echo "📦 备份当前版本..."
TIMESTAMP=\$(date +%Y%m%d-%H%M%S)
cp -a $DEPLOY_PATH ${DEPLOY_PATH}-pre-rollback-\$TIMESTAMP

# 替换为指定备份
echo "🔄 还原备份..."
rm -rf $DEPLOY_PATH
cp -a \$BACKUP_DIR $DEPLOY_PATH

nginx -t && nginx -s reload
echo "✅ 回滚完成"
ENDSSH
