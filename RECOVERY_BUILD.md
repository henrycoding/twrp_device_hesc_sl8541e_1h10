# TWRP Recovery Build 经验总结

## 设备信息

| 属性 | 值 |
|------|-----|
| 型号 | M53 TMSH |
| 品牌 | hesc |
| 设备名 | sl8541e_1h10 |
| 芯片 | 展锐 SL8541E |
| 原始 Android | 8.1 (SDK 27) |
| TWRP 版本 | twrp-12.1 |
| CPU 架构 | ARM64 (arm64-v8a) |

## 设备树仓库

https://github.com/henrycoding/twrp_device_hesc_sl8541e_1h10

## 构建参数

```
MANIFEST_URL: https://github.com/minimal-manifest-twrp/platform_manifest_twrp_aosp.git
MANIFEST_BRANCH: twrp-12.1
DEVICE_TREE_URL: https://github.com/henrycoding/twrp_device_hesc_sl8541e_1h10
DEVICE_TREE_BRANCH: main
DEVICE_PATH: device/hesc/sl8541e_1h10
COMMON_TREE_URL: (留空)
COMMON_PATH: (留空)
DEVICE_NAME: sl8541e_1h10
MAKEFILE_NAME: twrp_sl8541e_1h10
BUILD_TARGET: recovery
```

## 已解决的问题

### 1. `add_lunch_combo is obsolete`

**错误信息：**
```
vendorsetup.sh:1: add_lunch_combo is obsolete. Use COMMON_LUNCH_CHOICES in your AndroidProducts.mk instead.
```

**解决方案：**
- 删除 `vendorsetup.sh`
- 在 `AndroidProducts.mk` 中使用 `COMMON_LUNCH_CHOICES`

```makefile
COMMON_LUNCH_CHOICES := \
    twrp_sl8541e_1h10-eng \
    twrp_sl8541e_1h10-userdebug
```

### 2. `Building a 32-bit-app-only product on a 64-bit device`

**错误信息：**
```
build/make/core/board_config.mk:246: error: Building a 32-bit-app-only product on a 64-bit device. If this is intentional, set TARGET_SUPPORTS_64_BIT_APPS := false.
```

**解决方案：**
在 `BoardConfig.mk` 添加：
```makefile
TARGET_SUPPORTS_64_BIT_APPS := true
```

### 3. `twrp.dependencies does not exist`

**错误信息：**
```
** Input File : device/hesc/sl8541e_1h10/twrp.dependencies does not exist
```

**解决方案：**
创建空的 `twrp.dependencies` 文件：
```json
[
]
```

### 4. `overriding commands for target 'kernel'`

**错误信息：**
```
vendor/twrp/build/tasks/kernel.mk:411: error: overriding commands for target `out/target/product/sl8541e_1h10/kernel', previously defined at build/make/core/Makefile:61
```

**原因：** `TARGET_PREBUILT_KERNEL` 与 TWRP 的 `kernel.mk` 产生规则冲突。

**解决方案：**
不要使用 `TARGET_PREBUILT_KERNEL`，改用：
```makefile
BOARD_PREBUILT_BOOTIMAGE := $(DEVICE_PATH)/prebuilt/kernel
BOARD_PREBUILT_RECOVERYIMAGE := $(DEVICE_PATH)/prebuilt/kernel
```

### 5. `ninja: no work to do` (recovery.img 未生成)

**错误信息：**
```
ninja: no work to do.
#### build completed successfully ####
```

构建显示成功但 recovery.img 未生成。

**原因：** 设置 `TARGET_NO_KERNEL := true` 后构建系统跳过了 recovery.img 的生成。

**解决方案：**
```makefile
TARGET_NO_KERNEL := false
```

## 当前待解决问题

### 6. `rsync error: could not make way for new symlink`

**错误信息：**
```
could not make way for new symlink: root/etc
could not make way for new symlink: root/vendor
cannot delete non-empty directory: root/etc
cannot delete non-empty directory: root/vendor
rsync error: some files/attrs were not transferred (see previous errors) (code 23)
```

**原因分析：**
原始 ramdisk 中 `/etc` 和 `/vendor` 是**真实目录**，但 Android 12+ 的 TWRP 构建系统尝试将它们创建为指向 `/system/etc` 和 `/system/vendor` 的符号链接。rsync 无法覆盖非空目录导致失败。

**已尝试方案：**
- ❌ `BOARD_ROOT_EXTRA_SYMLINKS` — 无效
- ⏳ `BOARD_ROOT_EXTRA_FOLDERS := etc vendor` — 待验证

**可能的解决方案：**
1. 修改 ramdisk，将 `etc` 和 `vendor` 改为符号链接
2. 在 BoardConfig.mk 中使用其他配置
3. 修改构建脚本跳过 rsync 的符号链接创建

## 关键配置参考

### BoardConfig.mk

```makefile
# Architecture
TARGET_ARCH := arm64
TARGET_ARCH_VARIANT := armv8-a
TARGET_CPU_ABI := arm64-v8a
TARGET_CPU_VARIANT := generic

TARGET_2ND_ARCH := arm
TARGET_2ND_ARCH_VARIANT := armv8-a
TARGET_2ND_CPU_ABI := armeabi-v7a
TARGET_2ND_CPU_ABI2 := armeabi
TARGET_2ND_CPU_VARIANT := generic

TARGET_SUPPORTS_64_BIT_APPS := true

# Boot image
TARGET_NO_KERNEL := false
TARGET_NO_RECOVERY := false
BOARD_KERNEL_IMAGE_NAME := Image

# Kernel - using prebuilt
BOARD_PREBUILT_BOOTIMAGE := $(DEVICE_PATH)/prebuilt/kernel
BOARD_PREBUILT_RECOVERYIMAGE := $(DEVICE_PATH)/prebuilt/kernel
BOARD_KERNEL_BASE := 0x00008000
BOARD_KERNEL_PAGESIZE := 2048
BOARD_KERNEL_CMDLINE := console=ttyS1,115200n8 buildvariant=user

# Partitions
BOARD_BOOTIMAGE_PARTITION_SIZE := 36700160
BOARD_RECOVERYIMAGE_PARTITION_SIZE := 36700160
BOARD_FLASH_BLOCK_SIZE := 2048

# Recovery
TARGET_RECOVERY_FSTAB := $(DEVICE_PATH)/recovery.fstab
BOARD_HAS_NO_SELECT_BUTTON := true
BOARD_SUPPRESS_EMMC_WIPE := true
TARGET_RECOVERY_PIXEL_FORMAT := "RGBX_8888"

# Root folders
BOARD_ROOT_EXTRA_FOLDERS := etc vendor

# TWRP specific
TW_THEME := portrait_hdpi
TW_EXTRA_LANGUAGES := true
TW_SCREEN_BLANK_ON_BOOT := true
TW_DEFAULT_ADB := true
TW_INCLUDE_CRYPTO := false
TW_HAS_USB_STORAGE := true
TW_HAS_OTG := true
TW_HAS_MTP := true
TW_EXCLUDE_TWRPAPP := true

# Android version
PLATFORM_SECURITY_PATCH := 2025-12-31
PLATFORM_VERSION := 10
PLATFORM_VERSION_LAST_STABLE := 10
```

### 设备树文件结构

```
device/hesc/sl8541e_1h10/
├── Android.mk
├── AndroidProducts.mk
├── BoardConfig.mk
├── device.mk
├── recovery.fstab
├── twrp.dependencies
├── twrp_sl8541e_1h10.mk
├── prebuilt/
│   └── kernel
└── RECOVERY_BUILD.md
```

## 提取设备信息方法

从 boot.img/recovery.img 提取设备信息：

```bash
# 1. 提取 ramdisk
python3 << 'EOF'
import struct, os

def extract_bootimg(img_path, output_dir):
    with open(img_path, 'rb') as f:
        data = f.read()
    
    page_size = struct.unpack('<I', data[36:40])[0]
    kernel_size = struct.unpack('<I', data[8:12])[0]
    ramdisk_size = struct.unpack('<I', data[16:20])[0]
    
    kernel_offset = page_size
    ramdisk_offset = kernel_offset + ((kernel_size + page_size - 1) // page_size) * page_size
    
    with open(os.path.join(output_dir, 'kernel'), 'wb') as f:
        f.write(data[kernel_offset:kernel_offset + kernel_size])
    
    with open(os.path.join(output_dir, 'ramdisk.gz'), 'wb') as f:
        f.write(data[ramdisk_offset:ramdisk_offset + ramdisk_size])

extract_bootimg('boot.img', 'extracted')
EOF

# 2. 解压 ramdisk
cd extracted && mkdir ramdisk && cd ramdisk
gunzip -c ../ramdisk.gz | cpio -idm

# 3. 查看设备信息
cat prop.default | grep ro.product
cat fstab.*
```

## 参考资源

- [TWRP 官方编译指南](https://twrp.me/faq/howtocompileTWRP.html)
- [Action-TWRP-Builder](https://github.com/azwhikaru/Action-TWRP-Builder)
- [minimal-manifest-twrp](https://github.com/minimal-manifest-twrp/platform_manifest_twrp_aosp)
