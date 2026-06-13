# Gemini-Skill

คลังเก็บรวบรวม **Agent Skills** สำหรับใช้งานร่วมกับ **Gemini CLI / Antigravity** เพื่อเพิ่มความสามารถเฉพาะด้านให้กับ AI Agent ในระดับ Global หรือระดับ Workspace

---

## 🛠️ รายชื่อสกิลที่พร้อมใช้งาน (Available Skills)

คลังนี้ประกอบด้วยสกิลต่าง ๆ ดังนี้:

### 1. 📋 Default Rules (`default_rules`)
* **คำอธิบาย:** กำหนดค่ามาตรฐานพฤติกรรม ข้อกำหนด และแนวทางการเขียนโค้ด (Coding Standards) ของ AI Assistant ในทุก ๆ โปรเจกต์
* **การเปิดใช้งาน:** ทำงานโดยอัตโนมัติเป็นกฎพื้นฐานของเอเจนต์

### 2. 💬 Grill Me (`grill_me`)
* **คำอธิบาย:** สกิลสำหรับวิเคราะห์ แนะนำ และระดมสมอง (Design Review) โดย AI จะสัมภาษณ์เจาะลึกผู้ใช้เกี่ยวกับแผนการออกแบบหรือโครงสร้างระบบ เพื่อปิดช่องโหว่และได้ข้อสรุปที่ดีที่สุดก่อนเริ่มเขียนโค้ดจริง
* **การเปิดใช้งาน:** เรียกใช้เมื่อกล่าวถึง "grill me", "ช่วยตรวจแบบระบบนี้หน่อย", หรือเริ่มต้นออกแบบโครงร่างของโปรเจกต์

### 3. 📚 Novel Translator (`novel_translator`)
* **คำอธิบาย:** แปลนิยาย, ไลท์โนเวล (Light Novels) จากภาษาญี่ปุ่น เกาหลี จีน และอังกฤษ ให้เป็นภาษาไทยที่มีความลื่นไหลระดับงานเขียนวรรณกรรม พร้อมทั้งควบคุมระดับภาษา คำลงท้าย และมีระบบเซนเซอร์คำหยาบแบบอัจฉริยะ (Smart Censorship)
* **การเปิดใช้งาน:** เรียกใช้โดยอัตโนมัติเมื่อสั่งให้แปลนิยายหรือผลงานวรรณกรรมทั่วไป

### 4. 📄 PO PDF Generator (`po_pdf`)
* **คำอธิบาย:** สร้างไฟล์ PDF รวมใบสั่งซื้อสินค้า (PO - Purchase Order) จากรูปถ่ายเอกสารต่าง ๆ ที่อยู่ในโฟลเดอร์ Downloads โดยอัตโนมัติ
* **การเปิดใช้งาน:** เรียกใช้เมื่อพิมพ์คำว่า "ทำ PO PDF", "รวมใบ PO", "สร้าง PDF PO" หรือส่งรูปถ่ายใบสั่งซื้อเข้ามา

### 5. 🎵 Song Translator (`song_translator`)
* **คำอธิบาย:** แปลเนื้อเพลงจากภาษาต่างประเทศ (ญี่ปุ่น, เกาหลี, จีน, อังกฤษ) ให้เป็นภาษาไทยที่สละสลวย งดงาม และสื่ออารมณ์เพลงได้อย่างลึกซึ้ง พร้อมสร้างบรรทัดคำอ่านออกเสียง (Romanized) ควบคู่ไปกับเนื้อเพลงต้นฉบับ
* **การเปิดใช้งาน:** เรียกใช้เมื่อส่งเนื้อเพลงหรือลิงก์เพลงมาให้ถอดความและแปลภาษาไทย

### 6. 🔬 Technical Translator (`tech_translator`)
* **คำอธิบาย:** แปลคู่มือการใช้งาน (Manuals), เอกสารวิชาการ (Academic Papers), และเอกสารเฉพาะทางเทคนิคให้เป็นภาษาไทยที่กระชับ แม่นยำ คงคำศัพท์เทคนิคตามหลักมาตรฐานอุตสาหกรรม และระบุคำแปลภาษาอังกฤษควบคู่ในการกล่าวถึงครั้งแรก
* **การเปิดใช้งาน:** เรียกใช้เมื่อส่งคู่มือทางเทคนิคมาให้แปล หรือสั่งการผ่านคำสั่ง `/technical-translator`

---

## 🚀 วิธีการติดตั้งและใช้งาน (Installation)

### วิธีที่ 1: ติดตั้งแบบคัดลอกไฟล์ปกติ (Standard Copy)
สำหรับคัดลอกโฟลเดอร์สกิลทั้งหมดไปวางในโฟลเดอร์ระบบของ Gemini โดยตรง:

1. เปิด PowerShell (ในโฟลเดอร์ของ Repository นี้)
2. รันคำสั่งสคริปต์ซิงค์ข้อมูล:
   ```powershell
   powershell -ExecutionPolicy Bypass -File .\sync.ps1
   ```

### วิธีที่ 2: ติดตั้งแบบเชื่อมโยงไฟล์สด (Global Junction Link - แนะนำสำหรับผู้พัฒนา)
ช่วยให้สามารถแก้ไขปรับปรุงสกิลหรือทำการ `git pull` ในโฟลเดอร์ Git นี้ แล้วตัวระบบระดับ Global ของเครื่องจะได้รับอัปเดตตามโดยตรงทันที ไม่ต้องรันสคริปต์ก๊อปปี้ซ้ำ:

1. เปิด PowerShell
2. รันสคริปต์นี้เพื่อสร้าง Junction Link:
   ```powershell
   $sourceDir = "d:\Users\Anon\Documents\GitHub\Gemini-Skill"
   $destPaths = @(
       "$env:USERPROFILE\.gemini\antigravity\skills",
       "$env:USERPROFILE\.gemini\config\skills"
   )
   $folders = @("default_rules", "grill_me", "po_pdf", "novel_translator", "tech_translator", "song_translator")

   foreach ($destPath in $destPaths) {
       if (!(Test-Path $destPath)) {
           New-Item -ItemType Directory -Force -Path $destPath
       }
       foreach ($folder in $folders) {
           $dest = Join-Path $destPath $folder
           if (Test-Path $dest) {
               Remove-Item -Recurse -Force $dest
           }
           $src = Join-Path $sourceDir $folder
           New-Item -ItemType Junction -Path $dest -Target $src
       }
   }
   ```

---

## 🔄 วิธีการอัปเดตสกิล (Update)
หากต้องการอัปเดตข้อมูลของสกิลให้เป็นเวอร์ชันล่าสุดจาก GitHub:
```bash
git pull
```
*(หากใช้วิธีติดตั้งแบบที่ 1 อย่าลืมรันสคริปต์ `.\sync.ps1` ซ้ำอีกครั้งหลังทำการ pull)*
