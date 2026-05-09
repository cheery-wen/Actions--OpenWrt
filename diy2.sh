#!/bin/bash
set -e
set -o pipefail

# 替换25.12 Go环境
if [ -d "feeds/packages/lang/golang" ]; then
    rm -rf feeds/packages/lang/golang
fi

git clone --depth 1 https://github.com/sbwml/packages_lang_golang feeds/packages/lang/golang

./scripts/feeds update -a
./scripts/feeds install -a

echo "==================== Feeds 完整性校验 ===================="
./scripts/feeds list -r
echo "==================== Feeds 校验完成 ===================="

make defconfig

rm -rf tmp build_dir/tmp* 2>/dev/null

exit 0
