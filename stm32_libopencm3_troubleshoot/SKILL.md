---
name: stm32-libopencm3-troubleshoot
description: >
  แก้ปัญหาการ Build โปรเจกต์ STM32 + libopencm3 + FreeRTOS บน Windows
  ใช้เมื่อเจอ error ระหว่างคอมไพล์โปรเจกต์ที่ใช้ libopencm3, FreeRTOS หรือ
  ARM GCC toolchain บน Windows (PowerShell / Git Bash)
  ครอบคลุมปัญหา: make not found, python3 not found, undefined reference,
  missing NVIC priority config, nostartfiles, และปัญหาสภาพแวดล้อม Windows ทั่วไป
---

# STM32 libopencm3 + FreeRTOS — คู่มือแก้ปัญหา Build บน Windows

เมื่อพบ Error ระหว่าง Build โปรเจกต์ STM32 ที่ใช้ `libopencm3` และ/หรือ `FreeRTOS` บน Windows ให้ตรวจสอบตามลำดับต่อไปนี้

---

## 1. ไม่มี `make` ใน PATH

**อาการ:**
```
make : The term 'make' is not recognized
```

**สาเหตุ:** Windows ไม่มี GNU Make ติดมาให้

**วิธีแก้:** โหลด xPack Windows Build Tools (Portable — ไม่ต้องติดตั้ง):
```powershell
$url = "https://github.com/xpack-dev-tools/windows-build-tools-xpack/releases/download/v4.4.1-2/xpack-windows-build-tools-4.4.1-2-win32-x64.zip"
$dest = "$env:TEMP\make.zip"
Invoke-WebRequest -Uri $url -OutFile $dest
Expand-Archive -Path $dest -DestinationPath "$env:USERPROFILE\make" -Force
```

**ตำแหน่งไฟล์ make.exe:**
```
%USERPROFILE%\make\xpack-windows-build-tools-4.4.1-2\bin\make.exe
```

---

## 2. `libopencm3` Build ใช้คำสั่ง Unix (`printf`, `env`) ไม่ได้ใน PowerShell

**อาการ:**
```
process_begin: CreateProcess(NULL, printf "  GENHDR  stm32/f4\n;", ...) failed.
process_begin: CreateProcess(NULL, env python3 ...) failed.
```

**สาเหตุ:** Makefile ของ `libopencm3` เรียกใช้คำสั่ง Unix เช่น `printf`, `env` ซึ่ง PowerShell ไม่มี

**วิธีแก้:** สั่ง Build ผ่าน **Git Bash** แทน PowerShell:
```powershell
& "C:\Program Files\Git\bin\bash.exe" -c 'export PATH="/c/Users/<USERNAME>/make/xpack-windows-build-tools-4.4.1-2/bin:$PATH" && cd /path/to/project && make 2>&1'
```

> **หมายเหตุ:** Git Bash (มากับ Git for Windows) มีคำสั่ง `printf`, `env`, `rm` ครบถ้วน

---

## 3. ไม่พบ `python3`

**อาการ:**
```
Python was not found; run without arguments to install from the Microsoft Store
```

**สาเหตุ:** Windows มี App Execution Alias ที่ดักคำสั่ง `python3` แล้ว redirect ไป Microsoft Store แทน

**วิธีแก้ (เรียงลำดับความง่าย):**

1. **ถ้ามี Python อยู่แล้ว** (เช่น Pico SDK) — สร้างสำเนาชื่อ `python3.exe`:
   ```powershell
   Copy-Item "$env:USERPROFILE\.pico-sdk\python\3.13.7\python.exe" "$env:USERPROFILE\.pico-sdk\python\3.13.7\python3.exe"
   ```
   แล้วเพิ่ม Path ตอน Build:
   ```bash
   export PATH="/c/Users/<USERNAME>/.pico-sdk/python/3.13.7:$PATH"
   ```

2. **ถ้ายังไม่มี Python เลย** — ติดตั้งจาก https://python.org แล้วติ๊ก "Add to PATH"

3. **ปิด App Execution Alias:** Settings → Apps → Advanced app settings → App execution aliases → ปิด `python.exe` และ `python3.exe`

---

## 4. `configMAX_SYSCALL_INTERRUPT_PRIORITY` undeclared

**อาการ:**
```
error: 'configMAX_SYSCALL_INTERRUPT_PRIORITY' undeclared
```

**สาเหตุ:** `FreeRTOSConfig.h` ขาดค่า Interrupt Priority สำหรับพอร์ต ARM_CM4F

**วิธีแก้:** เพิ่มบรรทัดเหล่านี้ใน `FreeRTOSConfig.h`:
```c
/* Cortex-M4 uses 4 priority bits (STM32F4) */
#define configPRIO_BITS                         4
#define configLIBRARY_LOWEST_INTERRUPT_PRIORITY         15
#define configLIBRARY_MAX_SYSCALL_INTERRUPT_PRIORITY    5
#define configKERNEL_INTERRUPT_PRIORITY         ( configLIBRARY_LOWEST_INTERRUPT_PRIORITY << (8 - configPRIO_BITS) )
#define configMAX_SYSCALL_INTERRUPT_PRIORITY    ( configLIBRARY_MAX_SYSCALL_INTERRUPT_PRIORITY << (8 - configPRIO_BITS) )
```

> **หมายเหตุ:** STM32F4 ใช้ 4 bits, STM32F1 ใช้ 4 bits, STM32H7 ใช้ 4 bits — ส่วนใหญ่เหมือนกัน

---

## 5. `undefined reference to 'main'` + `__bss_start__` / `__bss_end__`

**อาการ:**
```
crt0.o: undefined reference to `main'
crt0.o: undefined reference to `__bss_start__'
crt0.o: undefined reference to `__bss_end__'
```

**สาเหตุ:** Linker ใช้ `crt0.o` ของ ARM GCC toolchain (Newlib startup) ซึ่งขัดแย้งกับ `vector.c` ของ `libopencm3` ที่มี startup code ของตัวเอง

**วิธีแก้:** เพิ่ม `-nostartfiles` ใน LDFLAGS ของ Makefile:
```makefile
LDFLAGS += --specs=nosys.specs -nostartfiles
```

---

## 6. `OBJS` ว่าง — Linker ไม่เห็นไฟล์ `.o`

**อาการ:**
```
arm-none-eabi-gcc  -lopencm3_stm32f4 ... -o bin/project.elf
# ไม่มี .o file ใดๆ อยู่ในคำสั่ง link
undefined reference to `main'
```

**สาเหตุ:** Makefile ไม่ได้กำหนดตัวแปร `OBJS` จาก `CFILES` ทำให้ `gcc-rules.mk` ของ libopencm3 ลิงก์โดยไม่มี object files

**วิธีแก้:** เพิ่มบรรทัดนี้ใน Makefile (หลัง CFILES):
```makefile
OBJS = $(CFILES:.c=.o)
```

---

## 7. `cannot open output file bin/*.elf: No such file or directory`

**อาการ:**
```
ld.exe: cannot open output file bin/project.elf: No such file or directory
```

**สาเหตุ:** โฟลเดอร์ output (`bin/`) ยังไม่ถูกสร้าง

**วิธีแก้:** เพิ่ม rule สร้างโฟลเดอร์ใน Makefile:
```makefile
$(BUILD_DIR):
	mkdir -p $(BUILD_DIR)

all: libopencm3 $(BUILD_DIR) $(BUILD_DIR)/$(PROJECT).elf $(BUILD_DIR)/$(PROJECT).bin
```

---

## 8. FreeRTOS Interrupt Handler ชนกับ libopencm3

**อาการ:** โปรแกรม Hang ทันทีที่เรียก `vTaskStartScheduler()` หรือเมื่อ SysTick interrupt เกิดขึ้น

**สาเหตุ:** FreeRTOS ต้องการ handler ชื่อ `vPortSVCHandler`, `xPortPendSVHandler`, `xPortSysTickHandler` แต่ libopencm3 ใช้ชื่อ `sv_call_handler`, `pend_sv_handler`, `sys_tick_handler`

**วิธีแก้:** เพิ่ม macro mapping ใน `FreeRTOSConfig.h`:
```c
#define vPortSVCHandler    sv_call_handler
#define xPortPendSVHandler pend_sv_handler
#define xPortSysTickHandler sys_tick_handler
```

---

## คำสั่ง Build แบบเต็มสำหรับ Windows (Copy-Paste ได้เลย)

```powershell
# Build ผ่าน Git Bash (ปรับ USERNAME ให้ตรง)
& "C:\Program Files\Git\bin\bash.exe" -c '
export PATH="/c/Users/<USERNAME>/.pico-sdk/python/3.13.7:/c/Users/<USERNAME>/make/xpack-windows-build-tools-4.4.1-2/bin:$PATH"
cd /d/Users/<USERNAME>/Documents/GitHub/<PROJECT_NAME>
make -C libopencm3 TARGETS=stm32/f4
make
'
```

---

## Makefile Template (libopencm3 + FreeRTOS)

```makefile
PROJECT = my_project
BUILD_DIR = bin

CFILES = Src/main.c

FREERTOS_DIR = FreeRTOS-Kernel
FREERTOS_PORT = $(FREERTOS_DIR)/portable/GCC/ARM_CM4F
CFILES += \
	$(FREERTOS_DIR)/tasks.c \
	$(FREERTOS_DIR)/list.c \
	$(FREERTOS_DIR)/queue.c \
	$(FREERTOS_DIR)/timers.c \
	$(FREERTOS_PORT)/port.c \
	$(FREERTOS_DIR)/portable/MemMang/heap_4.c

OBJS = $(CFILES:.c=.o)

DEVICE = stm32f446re
V ?= 0
OPENCM3_DIR = libopencm3

CPPFLAGS += -IInc -I$(FREERTOS_DIR)/include -I$(FREERTOS_PORT)
LDFLAGS += --specs=nosys.specs -nostartfiles -Wl,--print-memory-usage

include $(OPENCM3_DIR)/mk/genlink-config.mk
include $(OPENCM3_DIR)/mk/gcc-config.mk

.PHONY: clean all libopencm3

all: libopencm3 $(BUILD_DIR) $(BUILD_DIR)/$(PROJECT).elf $(BUILD_DIR)/$(PROJECT).bin

$(BUILD_DIR):
	mkdir -p $(BUILD_DIR)

libopencm3:
	$(MAKE) -C $(OPENCM3_DIR) TARGETS=stm32/f4

clean:
	$(RM) -rf $(BUILD_DIR) generated.* $(OBJS)
	$(MAKE) -C $(OPENCM3_DIR) clean

include $(OPENCM3_DIR)/mk/genlink-rules.mk
include $(OPENCM3_DIR)/mk/gcc-rules.mk
```
