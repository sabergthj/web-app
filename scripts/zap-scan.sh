#!/usr/bin/env bash
# ============================================================
# ZAP 安全扫描脚本（本地使用）
# 需要先安装 OWASP ZAP: https://www.zaproxy.org/download/
# ============================================================
set -e

ZAP_PATH="${ZAP_PATH:-/usr/local/bin/zap.sh}"
TARGET_URL="${1:-http://localhost:4173}"
REPORT_DIR="test-results/zap"
TIMESTAMP=$(date +%Y%m%d-%H%M%S)

echo "🛡️  OWASP ZAP 基线扫描"
echo "   目标: $TARGET_URL"

# 检查 ZAP 是否安装
if [ ! -f "$ZAP_PATH" ]; then
  echo "⚠️  ZAP 未安装。跳过 DAST 扫描。"
  echo "   安装: https://www.zaproxy.org/download/"
  echo "   或使用 Docker: docker run -t owasp/zap2docker-stable zap-baseline.py -t $TARGET_URL"
  exit 0
fi

mkdir -p "$REPORT_DIR"

# 启动站点预览
echo "🚀 启动预览服务器..."
npx vite preview --port 4173 --host 0.0.0.0 &
PREVIEW_PID=$!
sleep 3

cleanup() {
  echo "🛑 停止预览服务器..."
  kill $PREVIEW_PID 2>/dev/null || true
}
trap cleanup EXIT

# 运行基线扫描
echo "🔍 扫描中..."
"$ZAP_PATH" -cmd -quickurl "$TARGET_URL" -quickprogress -quickout "$REPORT_DIR/zap-report-$TIMESTAMP.html" || true

echo "✅ ZAP 扫描完成: $REPORT_DIR/zap-report-$TIMESTAMP.html"
