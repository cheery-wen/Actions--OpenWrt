#!/bin/bash
set -e
set -o pipefail
export TZ=Asia/Shanghai

git config --global http.postBuffer 524288000
git config --global core.compression 0

git_clone() {
    for i in {1..3}; do
        if git clone --depth 1 "$1" "$2"; then
            return 0
        fi
        echo "克隆失败，正在重试 $i/3"
        sleep 5
    done
    exit 1
}

WORKDIR=$(pwd)
OPENWRT_DIR="${WORKDIR}/openwrt"
mkdir -p "${OPENWRT_DIR}"

# 清空root密码
sed -i '/^root:/d' package/base-files/files/etc/shadow
echo "root::0:0:99999:7:::" >> package/base-files/files/etc/shadow

# 固件版本信息
build_date=$(TZ=Asia/Shanghai date +%Y.%m.%d)
sed -i "s/DISTRIB_REVISION='.*'/DISTRIB_REVISION='($build_date compiled by cheery)'/" package/base-files/files/etc/openwrt_release
sed -i "s/OpenWrt /OpenWrt ($build_date compiled by cheery) /" package/base-files/files/etc/banner

# Argon主题
git_clone https://github.com/jerrykuku/luci-theme-argon package/lu-theme-argon
git_clone https://github.com/jerrykuku/luci-app-argon-config package/luci-app-argon-config

# Lucky
git_clone https://github.com/gdy666/lucky package/lucky
git_clone https://github.com/gdy666/luci-app-lucky package/luci-app-lucky

# Passwall全套
git_clone https://github.com/Openwrt-Passwall/openwrt-passwall-packages package/openwrt-passwall-packages
git_clone https://github.com/Openwrt-Passwall/openwrt-passwall package/luci-app-passwall

# 清理冲突旧插件
rm -rf "${WORKDIR}/feeds/luci/applications/luci-app-passwall"

# 时区 中文默认
mkdir -p "${WORKDIR}/files/etc/uci-defaults"
cat > "${WORKDIR}/files/etc/uci-defaults/99-custom" <<'EOF'
#!/bin/sh
[ -f /lib/functions.sh ] && . /lib/functions.sh
uci set system.@system[0].timezone='CST-8'
uci set system.@system[0].zonename='Asia/Shanghai'
uci set luci.main.lang=zh_cn
uci commit system
uci commit luci
exit 0
EOF
chmod +x "${WORKDIR}/files/etc/uci-defaults/99-custom"

cp -rf "${WORKDIR}/files" "${OPENWRT_DIR}/"
exit 0
