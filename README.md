# Gemini-Skill

คลังรวม **Agent Skills** สำหรับใช้งานร่วมกับ **Gemini CLI / Antigravity** เพื่อเพิ่มความสามารถเฉพาะด้านให้กับ AI Agent ในระดับ Global หรือระดับ Workspace

---

## สกิลที่พร้อมใช้งาน

| # | สกิล | โฟลเดอร์ | คำอธิบายสั้น |
|---|------|----------|-------------|
| 1 | Default Rules | `default_rules` | มาตรฐานพฤติกรรมและการเขียนโค้ดของ Agent ทุกโปรเจกต์ |
| 2 | Grill Me | `grill_me` | สัมภาษณ์เจาะลึกแผนการออกแบบและระบบก่อนเริ่มพัฒนา |
| 3 | Novel Translator | `novel_translator` | แปลนิยายและไลท์โนเวลเป็นภาษาไทยระดับวรรณกรรม |
| 4 | PO PDF Generator | `po_pdf` | สร้าง PDF รวมใบสั่งซื้อสินค้า (PO) จากรูปถ่ายเอกสาร |
| 5 | Song Translator | `song_translator` | แปลเนื้อเพลงต่างประเทศเป็นภาษาไทยพร้อมบรรทัดคำอ่าน |
| 6 | Technical Translator | `tech_translator` | แปลคู่มือและเอกสารวิชาการเป็นภาษาไทยตามมาตรฐานอุตสาหกรรม |
| 7 | Thai Tech Writer | `thai_tech_writer` | เขียนเอกสารทางเทคนิคเป็นภาษาไทยโดยตรงตั้งแต่ต้น |
| 8 | AV Embedded Planner | `av_embedded_planner` | วางแผนและออกแบบ embedded/IoT device สำหรับงาน AV event |

---

## รายละเอียดสกิล

### 1. Default Rules (`default_rules`)
กำหนดมาตรฐานพฤติกรรม ข้อกำหนด และแนวทางการเขียนโค้ดของ AI Agent ในทุกโปรเจกต์ ทำงานโดยอัตโนมัติเป็นกฎพื้นฐานโดยไม่ต้องเรียกใช้

### 2. Grill Me (`grill_me`)
สัมภาษณ์เจาะลึกผู้ใช้เกี่ยวกับแผนการออกแบบหรือโครงสร้างระบบ เพื่อปิดช่องโหว่และได้ข้อสรุปที่ดีก่อนเริ่มพัฒนาจริง

**เรียกใช้เมื่อ:** พิมพ์ `/grill-me` หรือพูดถึง "grill me", "ช่วยตรวจแบบระบบนี้", "stress-test แผนนี้หน่อย"

### 3. Novel Translator (`novel_translator`)
แปลนิยาย ไลท์โนเวล จากภาษาญี่ปุ่น เกาหลี จีน และอังกฤษ ให้เป็นภาษาไทยที่ไหลลื่นในระดับวรรณกรรม พร้อมระบบควบคุมระดับภาษาและคำลงท้ายของตัวละคร

**เรียกใช้เมื่อ:** สั่งแปลนิยายหรือไลท์โนเวล

### 4. PO PDF Generator (`po_pdf`)
สร้างไฟล์ PDF รวมใบสั่งซื้อสินค้า (Purchase Order) จากรูปถ่ายเอกสารในโฟลเดอร์ Downloads อัตโนมัติ พร้อมสารบัญ, Bookmarks, และ Searchable Text รองรับหลายเครื่อง — ไม่ hardcode path

**เรียกใช้เมื่อ:** พิมพ์ "ทำ PO PDF", "รวมใบ PO", "สร้าง PDF PO" หรือส่งรูปถ่ายใบสั่งซื้อมา

### 5. Song Translator (`song_translator`)
แปลเนื้อเพลงจากภาษาญี่ปุ่น เกาหลี จีน อังกฤษ และภาษาอื่นๆ ให้เป็นภาษาไทยที่สละสลวยและสื่ออารมณ์ พร้อมบรรทัดคำอ่าน (Romanized) ควบคู่กับต้นฉบับ

**เรียกใช้เมื่อ:** ส่งเนื้อเพลงมาให้แปลหรือถอดความ

### 6. Technical Translator (`tech_translator`)
แปลคู่มือการใช้งาน เอกสารวิชาการ และเอกสารเชิงเทคนิคให้เป็นภาษาไทยที่กระชับ แม่นยำ คงคำศัพท์มาตรฐานอุตสาหกรรม และระบุคำภาษาอังกฤษในวงเล็บเมื่อกล่าวถึงครั้งแรก

**เรียกใช้เมื่อ:** พิมพ์ `/technical-translator` หรือส่งเอกสารทางเทคนิคมาให้แปล

### 7. Thai Tech Writer (`thai_tech_writer`)
เขียนเอกสารทางเทคนิคเป็นภาษาไทยโดยตรงตั้งแต่ต้น ไม่ใช่การแปล — ใช้กฎคำศัพท์เดียวกับ Technical Translator ครอบคลุม README, คู่มือ, เอกสาร API และเนื้อหาทางเทคนิคทุกประเภท

**เรียกใช้เมื่อ:** พิมพ์ `/thai-tech-writer` แล้วบอกว่าต้องการเขียนอะไร

### 8. AV Embedded Planner (`av_embedded_planner`)
ช่วยวางแผนและออกแบบ embedded/IoT device สำหรับงาน AV event ตั้งแต่ดึง requirement จนได้ spec ที่นำไปพัฒนาได้จริง ครอบคลุมระบบควบคุมไฟ, sensor interactive, เล่น audio, ควบคุม projector และระบบ power control

Platform หลัก: **STM32, RP2040/RP2350, ESP32** — FreeRTOS, MQTT, Ethernet

**เรียกใช้เมื่อ:** พิมพ์ `/av-embedded-planner` หรือเมื่อต้องการวางแผน device ที่ไม่มีขายสำเร็จรูป

---

## การติดตั้ง

### วิธีที่ 1 — Copy ผ่าน Script (ใช้งานทั่วไป)

Clone repo แล้วรัน `sync.ps1` เพื่อ copy สกิลทั้งหมดไปยังโฟลเดอร์ระบบของ Gemini:

```powershell
git clone https://github.com/fildsady/Gemini-Skill.git
cd Gemini-Skill
powershell -ExecutionPolicy Bypass -File .\sync.ps1
```

### วิธีที่ 2 — Junction Link (แนะนำสำหรับผู้พัฒนา)

เชื่อมโยงโฟลเดอร์ Git โดยตรงกับโฟลเดอร์ระบบ — รัน `git pull` แล้วทุก skill อัปเดตทันทีโดยไม่ต้อง copy ซ้ำ:

```powershell
$sourceDir = "$env:USERPROFILE\Documents\GitHub\Gemini-Skill"
$destPaths = @(
    "$env:USERPROFILE\.gemini\antigravity\skills",
    "$env:USERPROFILE\.gemini\config\skills"
)
$folders = @(
    "default_rules", "grill_me", "po_pdf", "novel_translator",
    "tech_translator", "song_translator", "thai_tech_writer", "av_embedded_planner"
)

foreach ($destPath in $destPaths) {
    if (!(Test-Path $destPath)) {
        New-Item -ItemType Directory -Force -Path $destPath
    }
    foreach ($folder in $folders) {
        $dest = Join-Path $destPath $folder
        if (Test-Path $dest) { Remove-Item -Recurse -Force $dest }
        $src = Join-Path $sourceDir $folder
        New-Item -ItemType Junction -Path $dest -Target $src
    }
}
Write-Host "Junction links created!"
```

> [!NOTE]
> `$sourceDir` ใช้ `$env:USERPROFILE` แทน path แบบ hardcode เพื่อรองรับหลายเครื่อง ถ้าโฟลเดอร์ GitHub อยู่คนละที่ให้แก้ `$sourceDir` ให้ตรง

---

## การอัปเดต

```bash
git pull
```

- **วิธีที่ 1:** หลัง pull ให้รัน `.\sync.ps1` ซ้ำอีกครั้ง
- **วิธีที่ 2:** pull แล้ว skill อัปเดตทันทีผ่าน Junction Link

---

## โครงสร้างโปรเจกต์

```
Gemini-Skill/
├── default_rules/
│   └── SKILL.md
├── grill_me/
│   └── SKILL.md
├── novel_translator/
│   └── SKILL.md
├── po_pdf/
│   └── SKILL.md
├── song_translator/
│   └── SKILL.md
├── tech_translator/
│   └── SKILL.md
├── thai_tech_writer/
│   └── SKILL.md
├── av_embedded_planner/
│   └── SKILL.md
├── sync.ps1       ← script copy skill ไปยังโฟลเดอร์ระบบ
└── README.md
```
