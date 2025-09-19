import argparse, json, re, os, io
import pandas as pd
from pathlib import Path
from datetime import datetime
import pdfplumber
import fitz  # PyMuPDF

try:
    from pdf2image import convert_from_path
    import pytesseract
    HAVE_OCR = True
except Exception:
    HAVE_OCR = False

def clean_text(t):
    return re.sub(r'[ \t]+', ' ', t).strip()

def extract_text_pdfplumber(pdf_path):
    full_text, pages = [], []
    with pdfplumber.open(pdf_path) as pdf:
        for i, page in enumerate(pdf.pages, start=1):
            txt = page.extract_text() or ""
            txt = clean_text(txt)
            pages.append({"page": i, "text": txt})
            full_text.append(txt)
    return "\n\n".join(full_text).strip(), pages

def ocr_fallback(pdf_path, dpi=300):
    if not HAVE_OCR:
        return "", []
    images = convert_from_path(pdf_path, dpi=dpi)
    pages, texts = [], []
    for i, img in enumerate(images, start=1):
        txt = pytesseract.image_to_string(img)
        txt = clean_text(txt)
        pages.append({"page": i, "text": txt})
        texts.append(txt)
    return "\n\n".join(texts).strip(), pages

def detect_scanned(text_by_plumber):
    # crude heuristic: if almost nothing came out, assume scanned or unusual encoding
    return len(text_by_plumber.strip()) < 50

def extract_tables(pdf_path):
    tables_out = []
    with pdfplumber.open(pdf_path) as pdf:
        for i, page in enumerate(pdf.pages, start=1):
            try:
                for table in page.extract_tables() or []:
                    df = pd.DataFrame(table)
                    # drop all-NaN columns/rows artifacts
                    df.replace("", pd.NA, inplace=True)
                    df.dropna(how="all", axis=0, inplace=True)
                    df.dropna(how="all", axis=1, inplace=True)
                    if not df.empty:
                        tables_out.append({"page": i, "table": df})
            except Exception:
                continue
    return tables_out

def extract_images(pdf_path, out_dir):
    Path(out_dir).mkdir(parents=True, exist_ok=True)
    doc = fitz.open(pdf_path)
    saved = []
    for page_index in range(len(doc)):
        for img_index, img in enumerate(doc.get_page_images(page_index), start=1):
            xref = img[0]
            pix = fitz.Pixmap(doc, xref)
            if pix.alpha:  # remove alpha for saving
                pix = fitz.Pixmap(fitz.csRGB, pix)
            out_path = Path(out_dir) / f"page{page_index+1}_img{img_index}.png"
            pix.save(out_path.as_posix())
            saved.append({"page": page_index+1, "path": str(out_path)})
    return saved

def heading_candidates(text):
    lines = [l.strip() for l in text.splitlines() if l.strip()]
    # crude guess: lines in Title Case or ALL CAPS and not too long
    heads = [l for l in lines if (len(l) <= 120 and (l.isupper() or re.search(r'\b[A-Z][a-z]+\b.*\b[A-Z][a-z]+\b', l)))]
    # dedupe while preserving order
    seen, out = set(), []
    for h in heads:
        if h not in seen:
            seen.add(h); out.append(h)
    return out[:50]

def summarize(text, max_chars=2000):
    # lightweight heuristic “summary”: first N chars + detected headings
    s = text[:max_chars]
    return s

def save_tables(tables, out_dir):
    csv_paths = []
    Path(out_dir).mkdir(parents=True, exist_ok=True)
    for idx, t in enumerate(tables, start=1):
        df = t["table"]
        p = Path(out_dir) / f"table_{idx:02d}_p{t['page']}.csv"
        df.to_csv(p, index=False)
        csv_paths.append(str(p))
    return csv_paths

def main():
    ap = argparse.ArgumentParser(description="Extract text, tables, images, and a quick summary from a PDF.")
    ap.add_argument("pdf", help="Path to PDF")
    ap.add_argument("--out", default="pdf_output", help="Output directory")
    ap.add_argument("--no-images", action="store_true", help="Skip image extraction")
    ap.add_argument("--no-tables", action="store_true", help="Skip table extraction")
    args = ap.parse_args()

    pdf_path = args.pdf
    out_dir = Path(args.out)
    out_dir.mkdir(parents=True, exist_ok=True)

    # Text
    text, pages = extract_text_pdfplumber(pdf_path)
    if detect_scanned(text):
        ocr_text, ocr_pages = ocr_fallback(pdf_path)
        if ocr_text:
            text, pages = ocr_text, ocr_pages

    # Tables
    csv_paths = []
    if not args.no_tables:
        tables = extract_tables(pdf_path)
        csv_paths = save_tables(tables, out_dir / "tables")

    # Images
    image_paths = []
    if not args.no_images:
        try:
            image_paths = [i["path"] for i in extract_images(pdf_path, out_dir / "images")]
        except Exception:
            pass

    # Headings + quick summary
    heads = heading_candidates(text)
    quick_summary = summarize(text)

    # Save outputs
    md_path = out_dir / "extracted.md"
    with open(md_path, "w", encoding="utf-8") as f:
        f.write(f"# Extracted Text\n\n{text}\n")
    json_meta = {
        "pdf": pdf_path,
        "generated_at": datetime.utcnow().isoformat() + "Z",
        "pages": len(pages),
        "headings_guess": heads,
        "tables_csv": csv_paths,
        "images": image_paths
    }
    with open(out_dir / "meta.json", "w", encoding="utf-8") as f:
        json.dump(json_meta, f, indent=2)

    # A brief console report
    print("Done.")
    print(f"- Text: {md_path}")
    if csv_paths: print(f"- Tables CSVs: {len(csv_paths)} files in {out_dir/'tables'}")
    if image_paths: print(f"- Images: {len(image_paths)} files in {out_dir/'images'}")
    print("- Headings (guessed):")
    for h in heads[:10]:
        print(f"  • {h}")

if __name__ == "__main__":
    main()
