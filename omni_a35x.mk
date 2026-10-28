#
# Copyright (C) 2024 The Android Open Source Project
# Copyright (C) 2024 The TWRP Open Source Project
#
# SPDX-License-Identifier: Apache-2.0
#

PRODUCT_PLATFORM := erd8835

PRODUCT_RELEASE_NAME := a35x

BOARD_VENDOR := samsung

PRODUCT_DEVICE := a35x
PRODUCT_NAME := omni_a35x
PRODUCT_BRAND := samsung
PRODUCT_MODEL := Samsung Galaxy A35
PRODUCT_MANUFACTURER := samsung

DEVICE_PATH := device/samsung/a35x

# Base
$(call inherit-product, $(SRC_TARGET_DIR)/product/base.mk)
$(call inherit-product, $(SRC_TARGET_DIR)/product/core_64_bit_only.mk)

# Device
$(call inherit-product, $(DEVICE_PATH)/device.mk)
