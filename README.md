# TWRP Device Tree for Samsung Galaxy A54 5G
# This recovery has encryption, it asks us for our screen password to be able to access the data partition, so it works 100%, proof that it boots on a35x.
The Galaxy A54 5G (codenamed _"a54x"_) is an upper-mid-range smartphone from Samsung.

It was announced and released in March 2023.

## Device specifications

| Feature                      | Specification                                                                  |
| ---------------------------: | :----------------------------------------------------------------------------- |
| Chipset                      | Exynos 1380                                                                    |
| CPU                          | Octa-core (4x2.4 GHz Cortex-A78 & 4x2.0 GHz Cortex-A55)                        |
| GPU                          | Mali-G68 MP5                                                                   |
| Memory                       | 6GB / 8GB RAM (LPDDR4X)                                                        |
| Shipped OS                   | Android 13 (One UI 5.1)                                                        |
| Storage                      | 128GB / 256GB (UFS 2.2)                                                        |
| SIM                          | Single SIM (Nano-SIM, eSIM) or Hybrid Dual SIM (Nano-SIM, dual stand-by)       |
| MicroSD                      | Up to 1TB                                                                      |
| Battery                      | 5000mAh Li-Po (non-removable), 25W fast charge                                 |
| Dimensions                   | 158.2 x 76.7 x 8.2 mm (6.23 x 3.02 x 0.32 in)                                  |
| Display                      | 6.4", 1080 x 2340 pixels, 19.5:9 ratio, Super AMOLED, 120Hz (~403 ppi density) |
| Rear Camera 1 (IMX766)       | 50 MP, f/1.8, (wide), 1/1.56", 1.0µm, PDAF, OIS                                |
| Rear Camera 2 (S5K3L6)       | 12 MP, f/2.2, 123˚ (ultrawide), 1.12µm                                         |
| Rear Camera 3 (GC5035)       | 5 MP, f/2.4, (macro)                                                           |
| Front Camera (IMX616/S5KGD2) | 32 MP, f/2.2, 26mm (wide), 1/2.8", 0.8µm                                       |
| Fingerprint                  | Goodix GW9578 (under display, optical)                                         |
| Sensors                      | Accelerometer, Gyro, Proximity (virtual), Compass, Hall IC, Grip               |
| Extras                       | Dual speakers, NFC, MST                                                        |

## Kernel source 

Available at [https://github.com/BlackMesa123/android_kernel_samsung_s5e8835/tree/sep-15/twrp-12.1](https://github.com/BlackMesa123/android_kernel_samsung_s5e8835/tree/sep-15/twrp-12.1)

## How to build

This device tree was tested and is fully compatible with [minimal-manifest-twrp](https://github.com/minimal-manifest-twrp/platform_manifest_twrp_aosp).

1. Set up the build environment following the instructions [here](https://github.com/minimal-manifest-twrp/platform_manifest_twrp_aosp/blob/twrp-12.1/README.md#getting-started)

2. In the root folder of the fetched repo, clone the device tree:

```bash
git clone https://github.com/TeamWin/android_device_samsung_a54x.git -b android-12.1 device/samsung/a54x
```

3. To build:

```bash
export ALLOW_MISSING_DEPENDENCIES=true
. build/envsetup.sh
lunch twrp_a54x-eng
mka recoveryimage
```

## Copyright

```
#
# Copyright (C) 2024 The TWRP Open Source Project
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
#
```

## Notas de mantenimiento — fix del kernel (jul 2026)

`prebuilt/Image` traía un kernel custom (`5.15.153-twrp+`, build de ravindu644) cuyo `vermagic` **no coincidía** con los 291 módulos .ko en `recovery/root/lib/modules/` (compilados como `5.15.153-android13-3-31153516`). Resultado: ningún módulo cargaba — ni `exynos-drm.ko`/`mcd-panel*.ko` (pantalla) ni `ufs-exynos-core.ko`/`dw_mmc*.ko` (storage) — y el recovery se quedaba pegado en el logo porque la UI nunca lograba pintar sobre el splash del kernel.

**Fix aplicado:** se reemplazó `prebuilt/Image` por el kernel extraído del recovery stock del A35x (`Linux version 5.15.153-android13-3-31153516`), que coincide exacto con el vermagic de los módulos ya presentes. `prebuilt/dtb.img` y `prebuilt/dtbo.img` **no se tocaron** — ya eran idénticos, byte a byte, a los del stock. El kernel roto original queda respaldado en `prebuilt/Image.broken-twrp-kernel.bak` (bórralo cuando ya no lo necesites).

**Qué revisar cuando actualices la base (nueva versión de firmware / nuevos módulos):**

1. Extrae el kernel del nuevo `recovery.img` (o `vendor_boot.img`) stock correspondiente a la nueva base.
2. Compara su string de versión (`strings Image | grep "Linux version"`) contra el `vermagic=` de los módulos nuevos en `recovery/root/lib/modules/*.ko` (`strings modulo.ko | grep vermagic`).
3. Si coinciden exacto, reemplaza `prebuilt/Image` con ese kernel — así te aseguras de que los módulos vuelvan a cargar.
4. Si NO coinciden (por ejemplo si decides usar un kernel custom de nuevo, como el de ravindu644/BlackMesa123), vas a necesitar recompilar tú mismo los módulos contra ESE kernel source, o extraer los módulos del stock que corresponda a ese kernel — no mezcles kernel y módulos de dos compilaciones distintas.
5. Repite la comparación de `dtb.img`/`dtbo.img` contra el stock nuevo — si tu placa/hardware no cambió de revisión, normalmente siguen siendo idénticos y no hace falta tocarlos.

Kernel source de referencia (si algún día quieres compilar el kernel tú mismo en vez de usar un prebuilt): [BlackMesa123/android_kernel_samsung_s5e8835](https://github.com/BlackMesa123/android_kernel_samsung_s5e8835/tree/sep-15/twrp-12.1)

## Notas de mantenimiento — particiones Samsung ODE (jul 2026)

Tras el fix del kernel, `/data` fallaba al montar (`Could not mount /data and unable to find crypto footer`). Comparando contra `system/etc/recovery.fstab` del recovery stock, se detectó que `recovery.fstab` de este device tree no declaraba las particiones `/keydata` y `/keyrefuge` (esquema propio de Samsung de manejo de llaves — "Samsung ODE" — separado del FBE estándar de AOSP que usa `/metadata/vold/metadata_encryption`). Se agregaron ambas entradas calcando el stock.

**Esto es un fix parcial, no confirmado en hardware todavía.** Sigue pendiente por investigar/probar:
- Si el mount de `/data` (y de las particiones lógicas `system`/`vendor`/`product`/etc.) funciona ahora que los 291 módulos cargan con el kernel correcto — pedir `ls -la /dev/block/by-name/` y `dmesg | grep -iE "ufs|mmc|block"` desde `adb shell` en recovery para confirmar qué nodos de bloque existen realmente.
- Si el TA de Keymint (`extract_ta.sh` / `init.recovery.teegris.rc`) logra desenvolver la llave hardware-wrapped para el esquema ODE de Samsung — esto es standard AOSP FBE en el fstab, pero Samsung puede requerir lógica adicional en vold que TWRP/SHRP no trae de fábrica.
- `BOARD_GROUP_BASIC_PARTITION_LIST` en BoardConfig.mk no incluye `system_dlkm` aunque sí aparece como partición lógica en el fstab — revisar si hace falta agregarla.
