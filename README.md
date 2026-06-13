# TWRP Device Tree for hesc M53 TMSH (sl8541e_1h10)

## Device Information

| 属性 | 值 |
|------|-----|
| 型号 | M53 TMSH |
| 品牌 | hesc |
| 设备名 | sl8541e_1h10 |
| 芯片 | 展锐 SL8541E |
| Android版本 | 10 (API 29) |
| LineageOS版本 | 17.x |
| CPU架构 | ARM64 (arm64-v8a) |

## 使用方法

### 方法 1: 使用 Action-TWRP-Builder (GitHub Actions)

1. Fork 或使用模板创建 [Action-TWRP-Builder](https://github.com/azwhikaru/Action-TWRP-Builder) 仓库

2. 将本设备树推送到你的 GitHub 仓库

3. 在 Actions 中运行 Recovery Build，填写参数：
   - `MANIFEST_URL`: `https://github.com/minimal-manifest-twrp/platform_manifest_twrp_aosp.git`
   - `MANIFEST_BRANCH`: `twrp-12.1` (推荐) 或 `twrp-11`
   - `DEVICE_TREE_URL`: `https://github.com/henrycoding/twrp_device_hesc_sl8541e_1h10`
   - `DEVICE_TREE_BRANCH`: `main`
   - `DEVICE_PATH`: `device/hesc/sl8541e_1h10`
   - `DEVICE_NAME`: `sl8541e_1h10`
   - `MAKEFILE_NAME`: `twrp_sl8541e_1h10`
   - `BUILD_TARGET`: `recovery`

### 方法 2: 本地编译

```bash
# 1. 初始化 TWRP 源码 (twrp-12.1)
mkdir twrp && cd twrp
repo init --depth=1 -u https://github.com/minimal-manifest-twrp/platform_manifest_twrp_aosp.git -b twrp-12.1
repo sync -j$(nproc) --force-sync

# 2. 克隆设备树
git clone https://github.com/henrycoding/twrp_device_hesc_sl8541e_1h10 -b main device/hesc/sl8541e_1h10

# 3. 编译
source build/envsetup.sh
export ALLOW_MISSING_DEPENDENCIES=true
lunch twrp_sl8541e_1h10-eng
make recoveryimage -j$(nproc)
```

## 文件结构

```
device/hesc/sl8541e_1h10/
├── Android.mk
├── AndroidProducts.mk
├── BoardConfig.mk          # 板级配置
├── device.mk               # 设备配置
├── recovery.fstab           # TWRP 分区挂载表
├── twrp_sl8541e_1h10.mk    # 产品配置
├── vendorsetup.sh           # lunch 配置
├── prebuilt/
│   └── kernel               # 预编译内核
└── README.md
```

## 分区信息

| 分区 | 路径 | 文件系统 |
|------|------|----------|
| system | /dev/block/platform/soc/soc:ap-ahb/20600000.sdio/by-name/system | ext4 |
| userdata | /dev/block/platform/soc/soc:ap-ahb/20600000.sdio/by-name/userdata | f2fs/ext4 |
| cache | /dev/block/platform/soc/soc:ap-ahb/20600000.sdio/by-name/cache | ext4 |
| boot | /dev/block/platform/soc/soc:ap-ahb/20600000.sdio/by-name/boot | emmc |
| recovery | /dev/block/platform/soc/soc:ap-ahb/20600000.sdio/by-name/recovery | emmc |

## 注意事项

1. 本设备树基于提取的 boot.img 和 recovery.img 创建
2. 内核使用预编译版本（从原始 boot.img 提取）
3. 如需触屏、显示等功能，可能需要进一步调试配置
4. 建议先测试基本功能，再逐步添加特性

## 参考资源

- [TWRP 官方文档](https://twrp.me/faq/howtocompileTWRP.html)
- [Action-TWRP-Builder](https://github.com/azwhikaru/Action-TWRP-Builder)
- [展锐平台 TWRP 移植指南](https://forum.xda-developers.com/)
