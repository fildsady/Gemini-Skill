---
name: stm32-ll-cmake-dsp-troubleshoot
description: แก้ปัญหาการย้ายโครงสร้างโปรเจกต์เป็น STM32 LL API ร่วมกับ CMake, FreeRTOS, และ CMSIS-DSP บน Windows (แก้ปัญหา Unknown Arm architecture profile, VS Code ไม่จำโปรเจกต์, และ Submodule รวน)
---

# 🛠️ STM32 LL API + CMake + CMSIS-DSP Migration & Troubleshooting

**ใช้ Skill นี้เมื่อ:** ผู้ใช้ต้องการย้ายจากไลบรารีอื่น (เช่น libopencm3 หรือ HAL) มาเป็น **STM32 LL API แบบเพียวๆ** และใช้ระบบบิลด์ **CMake** พร้อมติดตั้ง **CMSIS-DSP** และเจอปัญหาเกี่ยวกับการตั้งค่า Compiler หรือ Submodule รวน

---

## 🛑 ปัญหาที่ 1: ติดตั้ง CMSIS-DSP แล้วเจอ Error "Unknown Arm architecture profile"
**อาการ:**
เวลาใช้คำสั่ง `add_subdirectory()` ดึง `CMSIS-DSP` เข้ามาใน CMakeLists.txt แล้วคอมไพล์ จะเจอ Error แบบนี้ในไฟล์ `cmsis_gcc.h`:
```
error: #error "Unknown Arm architecture profile"
```
**สาเหตุ:** 
โดยปกติเรามักจะใส่ Flag ของ CPU (`-mcpu=cortex-m4`, `-mfloat-abi=hard` ฯลฯ) ผ่านคำสั่ง `target_compile_options(MainProject ...)` ซึ่งทำให้ไลบรารีลูกอย่าง `CMSISDSP` ไม่ได้รับ Flag เหล่านี้ไปด้วย ทำให้มันไม่รู้ว่าจะต้องคอมไพล์สำหรับชิปตัวไหน
**วิธีแก้ไข:**
ให้เปลี่ยนไปใช้คำสั่งกำหนด Flag **ระดับ Global** ก่อนที่จะเรียก `add_subdirectory` ดังนี้:
```cmake
# กำหนด Flag แบบ Global เพื่อให้ CMSIS-DSP ได้รับด้วย
add_compile_options(-mcpu=cortex-m4 -mthumb -mfloat-abi=hard -mfpu=fpv4-sp-d16)
add_compile_definitions(ARM_MATH_CM4)

# จากนั้นค่อยเรียก Subdirectory
add_subdirectory(Drivers/CMSIS-DSP/Source)
```

---

## 🛑 ปัญหาที่ 2: โปรเจกต์หลักฟ้องว่า Submodule (เช่น FreeRTOS) ถูก Modify และมี Commit แปลกๆ
**อาการ:** 
เมื่อรัน `git status` โปรเจกต์หลักจะฟ้องว่า `modified: FreeRTOS-Kernel (untracked content)` หรือมี Commit โผล่มาใน Submodule ทั้งที่ไม่ได้ตั้งใจแก้โค้ดของ FreeRTOS
**สาเหตุ:** 
เกิดจากการใช้ระบบบิลด์แบบ `Makefile` รุ่นเก่า (In-source build) ที่ไปสร้างไฟล์นามสกุล `.o` ทิ้งไว้ในโฟลเดอร์ของ Submodule ทำให้ VS Code ตรวจจับเจอว่ามีไฟล์เปลี่ยน และผู้ใช้อาจเผลอกด Commit เข้าไปใน Submodule
**วิธีแก้ไข:**
1. เข้าไปใน Submodule เพื่อลบ Commit ที่ผิดพลาดและล้างไฟล์ขยะ:
```bash
cd FreeRTOS-Kernel
git reset --hard HEAD~1
git clean -fdx
cd ..
git submodule update --init
```
2. **เปลี่ยนไปใช้ระบบบิลด์แบบ CMake** (Out-of-source build) ซึ่งจะเก็บไฟล์ที่คอมไพล์เสร็จไว้ในโฟลเดอร์ `build/` เท่านั้น เพื่อไม่ให้ไปกวน Source Code ของ Submodule อีก

---

## 🛑 ปัญหาที่ 3: CMake หา C Compiler ไม่เจอ บน Windows
**อาการ:**
สั่ง `cmake -B build` แล้วขึ้น Error ว่า `No CMAKE_C_COMPILER could be found.`
**สาเหตุ:** 
Windows ไม่มี `gcc` มาให้แต่แรก และผู้ใช้อาจไม่ได้เซ็ต Environment PATH ไปที่ `arm-none-eabi-gcc`
**วิธีแก้ไข:**
1. ใช้ **CMakePresets.json** ที่มีการชี้ `toolchainFile` ไว้
2. หรือใช้ Toolchain ที่แถมมากับ **STM32CubeCLT** โดยตรง ผ่านการ Inject PATH ใน PowerShell (หรือใน `tasks.json`):
```powershell
$env:PATH += ";C:\ST\STM32CubeCLT_1.21.0\GNU-tools-for-STM32\bin;C:\ST\STM32CubeCLT_1.21.0\CMake\bin;C:\ST\STM32CubeCLT_1.21.0\Ninja\bin"
cmake --preset Debug
```

---

## 🛑 ปัญหาที่ 4: VS Code (STM32 Extension) ไม่ยอมทำงาน / ไม่ยอมอ่าน CMake
**อาการ:**
ปุ่มค้อน (Build) หรือฟังก์ชันของ STM32 VS Code Extension หายไป หรือทำงานผิดปกติ
**สาเหตุ:** 
มีการตั้งค่าใน `.vscode/settings.json` เช่น `"cmake.ignoreCMakeListsMissing": true` ซึ่งไปปิดการทำงานของ CMake Tools
**วิธีแก้ไข:**
1. ลบไฟล์ตั้งค่าที่ขัดแย้งทิ้ง: `rm .vscode/settings.json` และ `rm .vscode/tasks.json` (ให้ Extension เป็นคนจัดการแทน)
2. กด `Ctrl + Shift + P` แล้วสั่ง **`Reload Window`** เพื่อให้ Extension เริ่มค้นหาไฟล์ `CMakeLists.txt` ใหม่อีกครั้ง
