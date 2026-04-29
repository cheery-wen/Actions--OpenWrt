#!/bin/bash
set -e
set -o pipefail

# 刷新全部feeds索引
./scripts/feeds update -a
./scripts/feeds install -a

# 彻底移除内置Go，锁定 OpenWrt25.12 专属 Go1.24 稳定版
rm -rf feeds/packages/lang/golang
git clone --depth 1 --retry 3 --branch go1.24 https://github.com/sbwml/packages_lang_golang feeds/packages/lang/golang
./scripts/feeds update packages
./scripts/feeds install -a

# 补齐Passwall&证书依赖
echo 'CONFIG_PACKAGE_ca-bundle=y' >> .config
echo 'CONFIG_PACKAGE_v2ray-geodata=y' >> .config
echo 'CONFIG_PACKAGE_luci-lib-ip=y' >> .config

# 强制固化配置，防止make defconfig回弹改写
sed -i 's/CONFIG_USE_SSTRIP=y/CONFIG_USE_SSTRIP=n/g' .config
sed -i 's/CONFIG_TRANSPARENT_HUGEPAGE=y/CONFIG_TRANSPARENT_HUGEPAGE=n/g' .config

# 最终配置写入
make defconfig

# 清理临时垃圾
rm -rf tmp build_dir/tmp* 2>/dev/null

exit 0
