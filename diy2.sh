#!/bin/bash
set -e

echo "🚀 开始注入 openwrt 25.12 优化补丁"

# 1. 自适应网口
# ==================================================
BOARD_D_PATH="target/linux/x86/base-files/etc/board.d"
mkdir -p "$BOARD_D_PATH"

cat > "$BOARD_D_PATH/02_network" << "EOF"
#!/bin/sh
. /lib/functions.sh
. /lib/functions/uci-defaults.sh

board_config_update

ALL_ETH=$(ls /sys/class/net/ | grep -E '^eth[0-9]+$' | grep -v '@' | sort -V)
COUNT=$(echo "$ALL_ETH" | wc -l)

if [ "$COUNT" -ge 2 ]; then
    WAN_PORT=$(echo "$ALL_ETH" | head -n1)
    LAN_PORTS=$(echo "$ALL_ETH" | tail -n +2 | tr '\n' ' ' | sed 's/ $//')
    ucidef_set_interfaces_lan_wan "$LAN_PORTS" "$WAN_PORT"
elif [ "$COUNT" -eq 1 ]; then
    ucidef_set_interface_lan "$ALL_ETH"
fi

board_config_flush
exit 0
EOF

chmod +x "$BOARD_D_PATH/02_network"

# ==================================================
# board_detect 兜底
# ==================================================
mkdir -p package/base-files/files/etc/uci-defaults

cat > package/base-files/files/etc/uci-defaults/99-force-board-detect << "EOF"
#!/bin/sh
/bin/board_detect
exit 0
EOF

chmod +x package/base-files/files/etc/uci-defaults/99-force-board-detect

set -e
set -o pipefail

# ========== 2. 清理 Go 模块缓存 ==========
echo "🗑️ 清理 Go 模块缓存..."
rm -rf dl/go-mod-cache 2>/dev/null || true
echo "✅ Go 缓存已清理"

# ========== 3. 替换官方 Golang 为 26.x 版本 ==========
#rm -rf feeds/packages/lang/golang
#git clone https://github.com/sbwml/packages_lang_golang -b 26.x feeds/packages/lang/golang
#echo "✅ Golang 已更新至 26.x"


echo "🚀 openwrt 25.12 优化补丁注入完成"
