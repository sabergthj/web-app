#!/usr/bin/env bash
# ============================================================
# Security Headers 检查脚本
# 检查部署后的站点是否配置了正确的安全头
# ============================================================
set -e

TARGET_URL="${1:-http://localhost:4173}"

echo "🛡️  Security Headers 检查: $TARGET_URL"

# 获取响应头
HEADERS=$(curl -sI -L "$TARGET_URL" 2>/dev/null || echo "")

if [ -z "$HEADERS" ]; then
  echo "❌ 无法连接到 $TARGET_URL"
  exit 1
fi

# 定义需要检查的安全头
declare -A CHECKS=(
  ["X-Frame-Options"]="DENY|SAMEORIGIN"
  ["X-Content-Type-Options"]="nosniff"
  ["Strict-Transport-Security"]="max-age"
  ["X-XSS-Protection"]="1; mode=block"
  ["Referrer-Policy"]="no-referrer|strict-origin|same-origin"
  ["Content-Security-Policy"]="default-src"
  ["Permissions-Policy"]=".*"
)

PASS=0
FAIL=0

for HEADER in "${!CHECKS[@]}"; do
  PATTERN="${CHECKS[$HEADER]}"
  if echo "$HEADERS" | grep -qi "^$HEADER:.*$PATTERN"; then
    echo "  ✅ $HEADER: 已配置"
    ((PASS++))
  else
    echo "  ❌ $HEADER: 缺失或不正确"
    ((FAIL++))
  fi
done

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "  通过: $PASS  | 未通过: $FAIL"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

if [ $FAIL -gt 0 ]; then
  echo ""
  echo "💡 提示: 参考 nginx/frontend.conf 配置安全头"
  exit 1
else
  echo "✅ 所有安全头检查通过！"
fi
