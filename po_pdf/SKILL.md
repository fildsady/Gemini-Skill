---
name: po-pdf
description: >
  สร้าง PDF รวมใบ PO (ใบสั่งซื้อสินค้า) จากรูปถ่ายเอกสารในโฟลเดอร์ Downloads
  ให้ใช้ skill นี้ทันทีเมื่อผู้ใช้พูดถึง "ทำ PO PDF", "รวมใบ PO", "สร้าง PDF PO",
  "ทำ PDF ใบสั่งซื้อ", หรือส่งรูปถ่ายเอกสาร PO มาพร้อมขอให้รวมเป็น PDF
---
 
# PO PDF Skill
 
สร้าง PDF รวมใบ PO จากรูปถ่ายเอกสาร พร้อมสารบัญ, Bookmarks, และ Searchable Text
 
## ขั้นตอนการทำงาน
 
### 1. Resolve Paths (ทำก่อนทุกครั้ง)

ก่อนเริ่มทำงาน ให้ detect path จาก home directory ของเครื่องที่ใช้อยู่ **อย่า hardcode path**:

```python
import os
from pathlib import Path

home      = Path.home()                        # C:\Users\<username> หรือ /home/<username>
downloads = home / "Downloads"
desktop   = home / "Desktop"
script    = desktop / "make_po_pdf.py"
```

ถ้าโฟลเดอร์ Downloads อยู่ไม่ตรง (เช่น drive อื่น) ให้รัน `ls` / `dir` แล้วถามผู้ใช้ยืนยัน path ก่อนดำเนินการต่อ

### 2. ค้นหารูปภาพ

ดูรูปภาพที่ถ่ายมาวันนี้ใน Downloads (นามสกุล .jpg / .jpeg / .png)

```python
from datetime import date
today = date.today()
imgs = [f for f in os.listdir(downloads)
        if f.lower().endswith(('.jpg','.jpeg','.png'))
        and date.fromtimestamp(os.path.getmtime(downloads / f)) == today]
imgs.sort(key=lambda f: os.path.getmtime(downloads / f))
```
 
### 3. อ่านข้อมูลจากรูปด้วย OCR

อ่านรูปแต่ละใบเพื่อหา: **เลข PO**, **วันที่**, **เดือน** โดยใช้ pytesseract

```python
import pytesseract
from PIL import Image
import shutil

# หา tesseract อัตโนมัติ — รองรับหลายเครื่อง
tesseract_path = shutil.which("tesseract")
if not tesseract_path:
    # fallback: Windows default install path
    tesseract_path = r"C:\Program Files\Tesseract-OCR\tesseract.exe"
pytesseract.pytesseract.tesseract_cmd = tesseract_path

text = pytesseract.image_to_string(Image.open(path), lang='tha+eng', config='--psm 3')
```

ค้นหา pattern ใน text:
- เลข PO: `PO[.\w]+\d{6,}` หรือ `PO\.\w+\d+`
- วันที่: `\d{2}/\d{2}/25\d{2}`
### 4. แจ้งผู้ใช้ยืนยัน
 
แสดงตารางสรุปก่อนสร้าง PDF:
 
```
พบรูป X ใบ:
┌─────────────────────────────────────────────────────┐
│ ไฟล์              │ เลข PO         │ วันที่      │ เดือน    │
├─────────────────────────────────────────────────────┤
│ S__XXXX_0.jpg    │ PO.IM69050011  │ 28/05/2569  │ พฤษภาคม │
└─────────────────────────────────────────────────────┘
ยืนยันสร้าง PDF? (หรือแก้ไขก่อน)
```
 
รอผู้ใช้ยืนยัน ถ้ามีรูปไหนระบุ PO ไม่ได้ให้ถามผู้ใช้เพิ่ม
 
### 5. อัปเดต Script และรัน

เปิดไฟล์ `make_po_pdf.py` ที่ Desktop (ใช้ `script` path จาก Step 1) และอัปเดต `sections` ให้ตรงกับรูปชุดใหม่:

```python
sections = [
    {
        "month": "พฤษภาคม 2569",
        "pages": [
            {"file": str(downloads / "S__XXXX_0.jpg"), "po": "PO.XXXXXXX"},
            {"file": str(downloads / "S__YYYY_1.jpg"), "po": "PO.YYYYYYY", "rotate": 180}, # ใส่ "rotate": 180 (หรือ 90, 270) เพื่อแก้ปัญหาภาพกลับหัว
            ...
        ]
    },
    {
        "month": "มิถุนายน 2569",
        "pages": [...]
    },
]
```

จัดกลุ่มตามเดือน เรียงจากเก่าสุดก่อน แล้วรัน:

```
python "<desktop>/make_po_pdf.py"
```

> ใช้ path จาก `script` variable ที่ resolve ไว้ใน Step 1 — ไม่ hardcode
 
### 6. แจ้งผลลัพธ์
 
บอกผู้ใช้:
- ชื่อไฟล์ที่บันทึก
- ขนาดไฟล์ (MB)
- จำนวนหน้าทั้งหมด
- โครงสร้าง Bookmarks
---
 
## ข้อกำหนด Output
 
| รายการ | รายละเอียด |
|--------|-----------|
| ชื่อไฟล์ | `รวมใบ PO 2569.pdf` บันทึกที่ Desktop |
| ขนาด | ไม่เกิน 10 MB |
| หน้าแรก | ปก + สารบัญแยกตามเดือน |
| Bookmarks | คลิกข้ามหน้าได้ (เดือน → PO แต่ละใบ) |
| Text | Searchable + Copy ได้ (ภาษาไทย + อังกฤษ) |
| รูปภาพ | ตัดขอบโต๊ะ, ปรับมุมตรง, พื้นขาวสะอาด |
 
---
 
## Dependencies
 
- **Python packages**: `opencv-python`, `pytesseract`, `pillow`, `pypdf`, `reportlab`
- **Tesseract OCR**: detect อัตโนมัติด้วย `shutil.which("tesseract")` — fallback `C:\Program Files\Tesseract-OCR\tesseract.exe`
- **Language data**: `tha`, `eng`
- **Script หลัก**: `Path.home() / "Desktop" / "make_po_pdf.py"` (resolve ตามเครื่องที่ใช้)
- **Font**: TH Sarabun New — หาด้วย `Path(os.environ.get('WINDIR','C:/Windows')) / 'Fonts' / 'THSarabunNew.ttf'`
## ถ้า Script ไม่มีหรือเสียหาย
 
ให้สร้างใหม่โดยใช้ logic เหล่านี้:
 
```python
# 1. ตรวจจับขอบเอกสาร (ตัดโต๊ะ + ปรับมุม)
#    Otsu threshold → find largest 4-corner contour → perspective transform
 
# 2. ลบเงา (divide normalisation)
#    bg = GaussianBlur(dilate(gray), sigma=60)
#    norm = gray / bg * 255
 
# 3. ทำพื้นขาว เส้นดำ
#    adaptiveThreshold(norm, blockSize=41, C=18) + medianBlur(3)
#    (หากรับค่า extra_rotate มา ให้หมุนภาพด้วย cv2.rotate ก่อนไปขั้นต่อไป เพื่อแก้ปัญหาภาพกลับหัว)
 
# 4. Resize พอดี A4 @ 200 DPI (1654×2338 px)
 
# 5. Searchable PDF
#    pytesseract.image_to_pdf_or_hocr(img, lang='tha+eng', extension='pdf')
 
# 6. รวม pages + bookmarks
#    pypdf.PdfWriter + add_outline_item()
#    **สำคัญ**: ต้องตรวจสอบไม่ให้สร้าง Bookmark ซ้ำ (ใช้ set บันทึก PO ที่เคยสร้างแล้ว) สำหรับกรณีที่ PO เดียวกันมีหลายหน้า
 
# 7. ปก + สารบัญ + divider pages
#    reportlab canvas, font TH Sarabun New
```
