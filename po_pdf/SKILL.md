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
 
### 1. ค้นหารูปภาพ
 
ดูรูปภาพที่ถ่ายมาวันนี้ใน `D:\Users\anon.s\Downloads` (นามสกุล .jpg / .jpeg / .png)
 
```python
import os
from datetime import date
downloads = r"D:\Users\anon.s\Downloads"
today = date.today()
imgs = [f for f in os.listdir(downloads)
        if f.lower().endswith(('.jpg','.jpeg','.png'))
        and date.fromtimestamp(os.path.getmtime(os.path.join(downloads,f))) == today]
imgs.sort(key=lambda f: os.path.getmtime(os.path.join(downloads,f)))
```
 
### 2. อ่านข้อมูลจากรูปด้วย OCR
 
อ่านรูปแต่ละใบเพื่อหา: **เลข PO**, **วันที่**, **เดือน** โดยใช้ pytesseract
 
```python
import pytesseract
from PIL import Image
pytesseract.pytesseract.tesseract_cmd = r'C:\Program Files\Tesseract-OCR\tesseract.exe'
 
text = pytesseract.image_to_string(Image.open(path), lang='tha+eng', config='--psm 3')
```
 
ค้นหา pattern ใน text:
- เลข PO: `PO[.\w]+\d{6,}` หรือ `PO\.\w+\d+`
- วันที่: `\d{2}/\d{2}/25\d{2}`
### 3. แจ้งผู้ใช้ยืนยัน
 
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
 
### 4. อัปเดต Script และรัน
 
เปิดไฟล์ `D:\Users\anon.s\Desktop\make_po_pdf.py` และอัปเดต `sections` ให้ตรงกับรูปชุดใหม่:
 
```python
sections = [
    {
        "month": "พฤษภาคม 2569",
        "pages": [
            {"file": r"D:\Users\anon.s\Downloads\S__XXXX_0.jpg", "po": "PO.XXXXXXX"},
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
python D:\Users\anon.s\Desktop\make_po_pdf.py
```
 
### 5. แจ้งผลลัพธ์
 
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
- **Tesseract OCR**: `C:\Program Files\Tesseract-OCR\tesseract.exe`
- **Language data**: `tha`, `eng`
- **Script หลัก**: `D:\Users\anon.s\Desktop\make_po_pdf.py`
- **Font**: TH Sarabun New (`C:\Windows\Fonts\THSarabunNew.ttf`)
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
 
# 4. Resize พอดี A4 @ 200 DPI (1654×2338 px)
 
# 5. Searchable PDF
#    pytesseract.image_to_pdf_or_hocr(img, lang='tha+eng', extension='pdf')
 
# 6. รวม pages + bookmarks
#    pypdf.PdfWriter + add_outline_item()
 
# 7. ปก + สารบัญ + divider pages
#    reportlab canvas, font TH Sarabun New
```
