# Copyright (C) 2024 The Android Open Source Project
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

# Inherit from the common Open Source product configuration
$(call inherit-product, $(SRC_TARGET_DIR)/product/full_base.mk)

# Inherit from TWRP common configuration
$(call inherit-product, vendor/twrp/config/common.mk)

# Inherit from device.mk
$(call inherit-product, device/hesc/sl8541e_1h10/device.mk)

PRODUCT_DEVICE := sl8541e_1h10
PRODUCT_NAME := twrp_sl8541e_1h10
PRODUCT_BRAND := hesc
PRODUCT_MODEL := M53 TMSH
PRODUCT_MANUFACTURER := hesc

PRODUCT_BUILD_PROP_OVERRIDES += \
    PRODUCT_NAME=sl8541e_1h10_oversea \
    TARGET_DEVICE=sl8541e_1h10
