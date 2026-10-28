#
# Copyright (C) 2024 The Android Open Source Project
# Copyright (C) 2024 The TWRP Open Source Project
#
# SPDX-License-Identifier: Apache-2.0
#

# =========================
# BOOT IMAGE (NORMAL BOOT)
# =========================
$(INSTALLED_BOOTIMAGE_TARGET): $(MKBOOTIMG) $(INTERNAL_BOOTIMAGE_FILES) $(BOOTIMAGE_EXTRA_DEPS)
	$(call pretty,"Target boot image: $@")
	$(hide) $(MKBOOTIMG) \
		--kernel $(call bootimage-to-kernel,$(1)) \
		$(INTERNAL_BOOTIMAGE_ARGS) \
		$(INTERNAL_MKBOOTIMG_VERSION_ARGS) \
		$(BOARD_MKBOOTIMG_ARGS) \
		--output $@
	$(hide) echo -n "SEANDROIDENFORCE" >> $@
	$(hide) $(call assert-max-image-size,$@,$(BOARD_BOOTIMAGE_PARTITION_SIZE),raw)
	@echo "Made boot image: $@"

# =========================
# RECOVERY IMAGE (FIXED)
# =========================
$(INSTALLED_RECOVERYIMAGE_TARGET): $(MKBOOTIMG) $(recovery_ramdisk) $(recovery_kernel) $(RECOVERYIMAGE_EXTRA_DEPS)
	@echo "----- Making recovery image ------"
	$(hide) $(MKBOOTIMG) \
		--kernel $(recovery_kernel) \
		--ramdisk $(recovery_ramdisk) \
		$(INTERNAL_MKBOOTIMG_VERSION_ARGS) \
		$(BOARD_MKBOOTIMG_ARGS) \
		--recovery_dtbo $(BOARD_PREBUILT_DTBOIMAGE) \
		--output $@
	$(hide) echo -n "SEANDROIDENFORCE" >> $@
	$(hide) $(call assert-max-image-size,$@,$(BOARD_RECOVERYIMAGE_PARTITION_SIZE),raw)
	@echo "Made recovery image: $@"
