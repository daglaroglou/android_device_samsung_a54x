#!/sbin/sh
#
# Copy the A35's TEEGRIS trustlets from the read-only vendor partition
# into the recovery-only /vendor/tee tmpfs. Never report crypto.ready=1
# unless every required trustlet was copied successfully.

log_error() {
  echo "extract_ta: $*" > /dev/kmsg 2>/dev/null || true
}

attempt=0
while [ ! -e "/dev/block/mapper/vendor" ]; do
  attempt=$((attempt + 1))
  if [ "$attempt" -ge 60 ]; then
    log_error "Timed out waiting for /dev/block/mapper/vendor"
    setprop "crypto.ready" "0"
    exit 1
  fi
  sleep 1
done

mkdir -p "/tmp/vendor" || {
  log_error "Could not create /tmp/vendor"
  setprop "crypto.ready" "0"
  exit 1
}

if ! mount -o ro "/dev/block/mapper/vendor" "/tmp/vendor"; then
  log_error "Could not mount vendor read-only"
  rmdir "/tmp/vendor" 2>/dev/null || true
  setprop "crypto.ready" "0"
  exit 1
fi

model="$(getprop "ro.boot.em.model")"
case "$model" in
  "SM-A546E")
    if [ -d "/tmp/vendor/tee_sea" ]; then
      tee_dir="/tmp/vendor/tee_sea"
    else
      tee_dir="/tmp/vendor/tee"
    fi
    ;;
  "SM-A546B")
    if [ -d "/tmp/vendor/tee_eur" ]; then
      tee_dir="/tmp/vendor/tee_eur"
    else
      tee_dir="/tmp/vendor/tee"
    fi
    ;;
  *)
    tee_dir="/tmp/vendor/tee"
    ;;
esac

copy_ta() {
  source_file="$1"
  destination_file="$2"

  if [ ! -f "$source_file" ]; then
    log_error "Required TA file is missing: $source_file"
    return 1
  fi

  if ! cp -p "$source_file" "$destination_file"; then
    log_error "Could not copy TA file: $source_file"
    return 1
  fi

  return 0
}

status=0
if ! mkdir -p "/vendor/tee/driver"; then
  log_error "Could not create /vendor/tee/driver; is the TEE tmpfs mounted?"
  status=1
fi

if [ "$status" -eq 0 ]; then
  # Crypto Manager Driver
  copy_ta "$tee_dir/driver/00000000-0000-0000-0000-53626f786476" \
    "/vendor/tee/driver/00000000-0000-0000-0000-53626f786476" || status=1
  # ICCC Driver
  copy_ta "$tee_dir/driver/00000000-0000-0000-0000-494363447256" \
    "/vendor/tee/driver/00000000-0000-0000-0000-494363447256" || status=1
  # KeyMint TA
  copy_ta "$tee_dir/00000000-0000-0000-0000-4b45594d5354" \
    "/vendor/tee/00000000-0000-0000-0000-4b45594d5354" || status=1
  # TZ_ICCC TA
  copy_ta "$tee_dir/00000000-0000-0000-0000-0053545354ab" \
    "/vendor/tee/00000000-0000-0000-0000-0053545354ab" || status=1
  # Gatekeeper TA
  copy_ta "$tee_dir/00000000-0000-0000-0000-474154454b45" \
    "/vendor/tee/00000000-0000-0000-0000-474154454b45" || status=1
fi

if ! umount "/tmp/vendor"; then
  log_error "Could not unmount temporary vendor mount"
  status=1
fi
rm -rf "/tmp/vendor"

if [ "$status" -ne 0 ]; then
  # Do not start KeyMint against a partial trustlet set.
  setprop "crypto.ready" "0"
  exit 1
fi

setprop "crypto.ready" "1"
exit 0
