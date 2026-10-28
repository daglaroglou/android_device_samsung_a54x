#!/system/bin/sh
# Copyright (c) 2016, Samsung Electronics Co., Ltd.

# PDP : Preloaded-Data Preservation

# Unzip & un-tar
if [[ -f /data/pdp_bkup/apps_apks.tar.zip ]]; then
  echo "[PDP] [pdp_prep___fb_.s_]  un-zip ap___apk_.t__.z__ to /d /pd" > /dev/kmsg
  /system/bin/unzip -o /data/pdp_bkup/apps_apks.tar.zip -d /data/pdp_bkup/
  if [ $? -ne 0 ]; then echo "[PDP]![pdp_prep___fb_.s_] ERROR, unzip apps_apks.t.z r= $?" > /dev/kmsg; fi
else
  echo "[PDP]![pdp_prep___fb_.s_]  !!! something is wrong !!  there is no PDP backup file" > /dev/kmsg
fi

if [[ -f /data/pdp_bkup/apps_apks.tar ]]; then
  echo "[PDP] [pdp_prep___fb_.s_]  un-tar ap___apk_.t__ to /d /a__" > /dev/kmsg
  /system/bin/tar -xpf /data/pdp_bkup/apps_apks.tar -C /data
  if [ $? -ne 0 ]; then echo "[PDP]![pdp_prep___fb_.s_] ERROR, untar apps_apks.t r= $?" > /dev/kmsg; fi
else
  echo "[PDP]![pdp_prep___fb_.s_]  !!! something is wrong !!  ap___apk_.t__ file is not exist" > /dev/kmsg
fi

if [[ -d /data/pdp_bkup/META-INF ]]; then
  echo "[PDP] [pdp_prep___fb_.s_]  rm /d /p /META-INF" > /dev/kmsg
  /system/bin/rm -rf /data/pdp_bkup/META-INF
fi

# RAM-loading files
if [[ -f /data/pdp_bkup/pdp_ramload.tar.zip ]]; then
  echo "[PDP] [pdp_prep___fb_.s_]  un-zip pdp_ramload.t__.z__ to /d /a" > /dev/kmsg
  /system/bin/unzip -o /data/pdp_bkup/pdp_ramload.tar.zip -d /data/pdp_bkup/
  if [ $? -ne 0 ]; then echo "[PDP]![pdp_prep___fb_.s_] ERROR, unzip pdp_ramload.t.z r= $?" > /dev/kmsg; fi

  if [[ -f /data/pdp_bkup/pdp_ramload.tar ]]; then
    echo "[PDP] [pdp_prep___fb_.s_]  un-tar pdp_ramload.t__ to /d /a" > /dev/kmsg
    /system/bin/tar -xpf /data/pdp_bkup/pdp_ramload.tar -C /data
    if [ $? -ne 0 ]; then echo "[PDP]![pdp_prep___fb_.s_] ERROR, untar pdp_ramload.t r= $?" > /dev/kmsg; fi
    /system/bin/rm -f /data/pdp_bkup/pdp_ramload.tar
  else
    echo "[PDP]![pdp_prep___fb_.s_]  !!! something is wrong !!  pdp_ramload.t__ file is not exist" > /dev/kmsg
  fi

  if [[ -d /data/pdp_bkup/META-INF ]]; then
    echo "[PDP] [pdp_prep___fb_.s_]  rm /d /p /META-INF" > /dev/kmsg
    /system/bin/rm -rf /data/pdp_bkup/META-INF
  fi
else
  echo "[PDP] [pdp_prep___fb_.s_]  there is no pdp_ramload.t__.z__ " > /dev/kmsg
fi

# OneShot-type apps
if [[ -f /data/pdp_bkup/pdp_oneshot.tar.zip ]]; then
  echo "[PDP] [pdp_prep___fb_.s_]  un-zip pdp_oneshot.t__.z__ to /d /a" > /dev/kmsg
  /system/bin/unzip -o /data/pdp_bkup/pdp_oneshot.tar.zip -d /data/pdp_bkup/
  if [ $? -ne 0 ]; then echo "[PDP]![pdp_prep___fb_.s_] ERROR, unzip pdp_oneshot.t.z r= $?" > /dev/kmsg; fi

  if [[ -f /data/pdp_bkup/pdp_oneshot.tar ]]; then
    echo "[PDP] [pdp_prep___fb_.s_]  un-tar pdp_oneshot.t__ to /d /a" > /dev/kmsg
    /system/bin/tar -xpf /data/pdp_bkup/pdp_oneshot.tar -C /data
    if [ $? -ne 0 ]; then echo "[PDP]![pdp_prep___fb_.s_] ERROR, untar pdp_oneshot.t r= $?" > /dev/kmsg; fi
    /system/bin/rm -f /data/pdp_bkup/pdp_oneshot.tar
  else
    echo "[PDP]![pdp_prep___fb_.s_]  !!! something is wrong !!  pdp_oneshot.t__ file is not exist" > /dev/kmsg
  fi

  if [[ -d /data/pdp_bkup/META-INF ]]; then
    echo "[PDP] [pdp_prep___fb_.s_]  rm /d /p /META-INF" > /dev/kmsg
    /system/bin/rm -rf /data/pdp_bkup/META-INF
  fi
else
  echo "[PDP] [pdp_prep___fb_.s_]  there is no pdp_oneshot.t__.z__ " > /dev/kmsg
fi



# dex files
if [[ -f /data/pdp_bkup/apps_dex.tar ]]; then
  echo "[PDP] [pdp_prep___fb_.s_]  un-tar app__de_.tar to /d /a__" > /dev/kmsg
  /system/bin/tar -xpf /data/pdp_bkup/apps_dex.tar -C /data;ret=$?
  if [ $ret -ne 0 ]; then echo "[PDP]![pdp_prep___fb_.s_] ERROR, untar apps_dex.t r= $ret" > /dev/kmsg; fi
else
  echo "[PDP] [pdp_prep___fb_.s_]  there is no apps_dex.tar " > /dev/kmsg
fi

# remove temporary *.tar files
echo "[PDP] [pdp_prep___fb_.s_]  rm app__apk_.tar, app__de_.tar at /d" > /dev/kmsg
/system/bin/rm -f /data/pdp_bkup/apps_apks.tar
/system/bin/rm -f /data/pdp_bkup/apps_dex.tar

# let init process know the current status, it is waiting for this
echo "[PDP] [pdp_prep___fb_.s_]  mkdir fsh_pfbe_done" > /dev/kmsg
/system/bin/mkdir -p /data/pdp_bkup/fsh_pfbe_done

# 2 seconds, waiting for the init process to flush the file-cache.
sleep 2


# Move files
# -p option can preserve the additional attributes: context, links, xattr, all
if [[ -f /cache/pdp_bkup/pdp_bkup.tar.zip ]]; then
  echo "[PDP] [pdp_prep___fb_.s_]  mv p___bk__.t__.z__ file from /c to /d" > /dev/kmsg
  /system/bin/mv -f /cache/pdp_bkup/pdp_bkup.tar.zip /data/pdp_bkup/pdp_bkup.tar.zip
  if [ $? -ne 0 ]; then echo "[PDP]![pdp_prep___fb_.s_] ERROR, mv pdp_.t.z from /c to /d r= $?" > /dev/kmsg; fi
else
  echo "[PDP] [pdp_prep___fb_.s_]  there is no /c /p /pdp_bkup.tar.zip" > /dev/kmsg
fi


if [[ -d /cache/pdp_bkup ]]; then
  echo "[PDP] [pdp_prep___fb_.s_]  rm -r /c /p" > /dev/kmsg
  /system/bin/rm -rf /cache/pdp_bkup
fi

echo "[PDP] [pdp_prep___fb_.s_]  p.FBE done" > /dev/kmsg
# End of PrepareFBE.sh