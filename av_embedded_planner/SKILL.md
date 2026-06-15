---
name: av-embedded-planner
description: วางแผนและออกแบบ embedded/IoT device สำหรับงาน AV event — ระบบควบคุมไฟ, sensor interactive, เล่น MP3 ผ่านเครือข่าย, ควบคุม projector, เปิดปิดอุปกรณ์ระยะไกล ใช้เมื่อเจ้านายหรือลูกค้าต้องการอุปกรณ์ควบคุมพิเศษที่ไม่มีขายสำเร็จรูป หรือต้องการ grill requirement ก่อนเริ่ม development
---

# AV Embedded Planner

ช่วยวางแผน embedded/IoT device สำหรับงาน AV event ตั้งแต่ดึง requirement จากเจ้านาย/ลูกค้า จนได้ spec ที่นำไปพัฒนาหรือสั่งทำได้จริง

Platform หลักที่ใช้: **STM32, RP2040/RP2350, ESP32** — FreeRTOS, MQTT, Ethernet (W5500/LAN8720), WiFi

## ภาษาและ Toolchain

**Embedded (MCU):** C เป็นหลัก
- STM32: STM32CubeIDE / Makefile + arm-none-eabi-gcc
- RP2350/RP2040: Pico SDK (C/C++)
- ESP32: ESP-IDF (C) — ไม่ใช้ Arduino framework ถ้าต้องการ production-grade

**PC / Host side:** C# (ความรู้เล็กน้อย)
- ใช้สำหรับ UI เบาๆ หรือ tool ควบคุม — WinForms / console app
- ถ้างานซับซ้อนเกินไปสำหรับ C# ที่มี → แนะนำ Python แทน (ง่ายกว่าสำหรับ network/serial tool) แต่ต้องแจ้งก่อน
- ห้ามแนะนำ JavaScript, web stack, หรือ framework ที่ไม่เกี่ยวกับ C/C#

**ห้ามแนะนำโดยไม่บอก tradeoff:**
- MicroPython / CircuitPython — ง่ายแต่ไม่ suitable สำหรับ realtime
- Arduino framework บน ESP32 — prototype ได้แต่ hidden abstraction มาก
- ถ้าต้องแนะนำสิ่งที่นอกเหนือจาก C ให้บอกเหตุผลและขอ confirm ก่อน

## เมื่อไหร่ควรใช้

- เจ้านายหรือลูกค้าต้องการอุปกรณ์ควบคุมที่ไม่มีขายสำเร็จรูป
- มีไอเดียคร่าวๆ แต่ยังไม่รู้จะ implement ยังไง
- ต้องการ spec ก่อนเริ่มซื้อ component หรือเขียนโค้ด
- ต้องการ estimate งบและเวลาให้เจ้านาย

## Domain ที่รองรับ

### 1. ระบบควบคุมไฟ (Lighting Control)
- DMX512 over Ethernet (Art-Net / sACN)
- Relay module สำหรับไฟ AC
- PWM dimmer สำหรับ LED
- Integration กับ lighting console (GrandMA, Avolites)

### 2. Sensor Interactive
- PIR, ultrasonic, capacitive touch, LIDAR distance
- Camera-based (OpenCV บน Pi / ส่ง trigger ผ่าน network)
- MIDI trigger, OSC message
- ส่ง event ผ่าน MQTT หรือ UDP broadcast ให้ระบบอื่น

### 3. ระบบเล่น Audio (MP3/Audio over Network)
- Networked audio trigger (รับ MQTT/OSC/UDP → เล่นไฟล์)
- Multi-zone playback
- Sync กับ timecode หรือ show controller
- Hardware: RP2350 + I2S DAC หรือ ESP32 + VS1053

### 4. ควบคุม Projector
- PJLink (TCP/IP) — เปิด/ปิด/เช็คสถานะ
- RS232 over IP (serial server)
- HDMI CEC
- Shutter control, input switching

### 5. ระบบ Power Control
- Networked PDU / smart relay
- Wake-on-LAN
- Scheduled power on/off
- Emergency shutdown trigger

## Workflow

เมื่อได้รับ requirement คร่าวๆ ให้ทำตามลำดับนี้:

### Step 1 — Grill Requirements

ถามทีละคำถาม ไม่ถามรัวพร้อมกัน ครอบคลุม:

**Functional:**
- ควบคุมอะไร / trigger จากอะไร / output คืออะไร
- มี timeline หรือ show sequence ไหม
- ต้องการ feedback / status กลับมาไหม

**Network:**
- Ethernet หรือ WiFi (หรือทั้งคู่ redundant)
- มี network infrastructure ในงานไหม (managed switch, VLAN)
- protocol ที่ระบบอื่นใช้อยู่ (MQTT broker, OSC, Art-Net, PJLink)

**Physical:**
- ติดตั้งที่ไหน (rack, hidden, บนเวที)
- power source (AC 220V, DC 12/24V, PoE, battery)
- สภาพแวดล้อม (กลางแจ้ง/ในร่ม, ความชื้น, การสั่นสะเทือน)
- housing ต้องการหรือเปล่า

**Reliability:**
- ถ้า device restart กลางโชว์ยอมรับได้ไหม
- ต้องการ watchdog / auto-recovery ไหม
- มี backup plan ถ้า network ล่ม

**Timeline:**
- ต้องพร้อมใช้งานเมื่อไหร่
- มีเวลา test กี่วัน

### Step 2 — สรุป Spec

หลัง grill แล้วสรุปเป็น:

```
## Spec Summary

**Function:** [สิ่งที่ device ต้องทำ]
**Input:** [trigger source]
**Output:** [สิ่งที่ควบคุม]
**Protocol:** [network protocol ที่ใช้]
**Platform แนะนำ:** [MCU + เหตุผล]
**Power:** [power requirement]
**Housing:** [ความต้องการ enclosure]
**Reliability requirement:** [ระดับ critical]
**Timeline:** [deadline + test period]
```

### Step 3 — Platform Recommendation

แนะนำ platform ตาม requirement:

| Use Case | Platform แนะนำ | ภาษา | เหตุผล |
|---|---|---|---|
| Ethernet critical + realtime | STM32 + W5500 | C + HAL/LL | Deterministic, ไม่มี OS overhead |
| WiFi + network protocol | ESP32 | C (ESP-IDF) | Built-in WiFi, MQTT library ดี |
| Audio playback + processing | RP2350 | C (Pico SDK) | Dual-core, I2S, DMA |
| หลาย task concurrent | STM32 + FreeRTOS | C | Production-grade, task isolation |
| PC control tool | Windows app | C# (WinForms/Console) | เหมาะกับความรู้ที่มี |
| PC tool ซับซ้อน / network หนัก | แนะนำ Python แทน | Python | ถ้า C# เกินขอบเขต — ต้อง confirm ก่อน |

### Step 4 — BOM & งบประมาณคร่าว

ประมาณ component หลักพร้อมราคา (ตลาดไทย / AliExpress) และ development time คร่าว

### Step 5 — Risk Assessment

ระบุ risk ที่ต้องรู้ก่อน approve:
- อะไรที่ไม่เคยทำมาก่อน → ต้องการ research/test ก่อน
- single point of failure ที่กระทบงาน
- dependency กับ vendor/อุปกรณ์อื่น

## สิ่งที่ต้องระวังสำหรับงาน Live Event

**ห้ามลืมถามเสมอ:**
- Recovery time หลัง power cut — งาน live ไม่มีเวลา re-flash
- Network topology — WiFi ในงานใหญ่มักมีปัญหา interference
- Fallback mode — ถ้า network ล่ม device ควร default ไปสถานะอะไร
- Latency requirement — interactive show มักต้องการ < 50ms

**Common pitfall:**
- WiFi ในงาน expo/concert มีคนเยอะ → interference สูง → ควร Ethernet เสมอถ้าทำได้
- RP2040/ESP32 boot time ~2-3 วินาที — ถ้า power cut กลางโชว์อาจกระทบ
- MQTT broker single point of failure — ควรมี fallback protocol (UDP broadcast)

## ตัวอย่าง

**Input:** "อยากได้ระบบเปิดปิด projector 8 ตัวผ่าน network ได้จากโน้ตบุ๊ค"

**Grill questions (ทีละข้อ):**
1. projector รุ่นไหน รองรับ PJLink ไหม หรือมีแค่ RS232?
2. ต้องการ UI บนโน้ตบุ๊คหรือแค่ script/command?
3. network ในงานเป็น Ethernet หรือ WiFi?
4. ต้องการ status feedback (on/off/error) กลับมาแสดงด้วยไหม?
5. ต้องการ schedule (เปิดอัตโนมัติตามเวลา) หรือ manual only?

**Spec Summary ตัวอย่าง:**
```
Function: สั่ง on/off/input switch projector 8 ตัว
Input: command จาก PC ผ่าน web UI หรือ REST API
Output: PJLink TCP command ไปแต่ละ projector
Protocol: PJLink (port 4352) + HTTP REST สำหรับ UI
Platform: Raspberry Pi Zero 2W หรือ mini PC (Linux + Python)
Power: AC 220V (rack)
Reliability: auto-restart service, health check loop
Timeline: 2 สัปดาห์ dev + 3 วัน test
```
