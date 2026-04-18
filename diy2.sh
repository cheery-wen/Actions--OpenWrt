#!/bin/bash
# ============================================
# DIY 脚本 2 - 在更新 feeds 后、make defconfig 前执行
# 功能：设置默认语言、设置默认主题
# ============================================

set -e

# ---------- 1. 设置 LuCI 默认语言为简体中文 ----------
LUCI_CONFIG="feeds/luci/modules/luci-base/root/etc/config/luci"
if [ -f "$LUCI_CONFIG" ]; then
    sed -i "s/option lang 'auto'/option lang 'zh_cn'/g" "$LUCI_CONFIG"
    sed -i 's/option lang auto/option lang zh_cn/g' "$LUCI_CONFIG"
    echo "✅ 默认语言已设置为简体中文"
else
    echo "⚠️ 未找到 $LUCI_CONFIG，跳过语言设置"
fi

# ---------- 2. 设置 Argon 为默认主题 (同时保留 bootstrap 作为备选) ----------
LUCI_MAKEFILE="feeds/luci/collections/luci/Makefile"
if [ -f "$LUCI_MAKEFILE" ] && [ -d "feeds/luci/themes/luci-theme-argon" ]; then
    sed -i 's/+luci-theme-bootstrap/+luci-theme-argon +luci-theme-bootstrap/g' "$LUCI_MAKEFILE"
    echo "✅ 默认主题已设置为 Argon"
else
    echo "⚠️ Argon 主题未找到或 Makefile 不存在，跳过主题设置"
fi

echo "✅ diy2.sh 执行完成"
