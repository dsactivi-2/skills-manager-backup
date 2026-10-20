# CallCenterEN Dataset Loading — Fallback Strategy

## Problem

The `datasets` Python library can fail when loading CallCenterEN:
- Streaming mode: `ArrowInvalid: JSON parse error: Column() changed from object to string`
- Background processes: `ModuleNotFoundError: No module named 'datasets'` (different Python path)
- Some ZIP files in the dataset have malformed JSON that pandas can't parse

## Solution: Direct ZIP Download

Skip the `datasets` library entirely. Download the ZIP files directly from HuggingFace and extract JSON transcripts with Python's built-in `zipfile`.

```python
import urllib.request, io, zipfile, json

HF_BASE = "https://huggingface.co/datasets/AIxBlock/92k-real-world-call-center-scripts-english/resolve/main/"

# Outbound-sales-relevant ZIPs:
ZIP_FILES = [
    "insurance_outbound.zip",        # 4004 transcripts, 55MB
    "medical_equipment_outbound.zip", # 738 transcripts, 13MB
]

def download_and_extract(zip_name):
    url = HF_BASE + zip_name
    req = urllib.request.Request(url)
    with urllib.request.urlopen(req, timeout=120) as resp:
        data = resp.read()
    
    transcripts = []
    with zipfile.ZipFile(io.BytesIO(data)) as zf:
        for name in zf.namelist():
            if name.endswith(".json"):
                try:
                    content = zf.read(name).decode("utf-8")
                    item = json.loads(content)
                    text = item.get("transcript") or item.get("text") or ""
                    if text:
                        transcripts.append(str(text))
                except Exception:
                    pass
    return transcripts
```

## Sales Filtering

Filter transcripts for sales-relevant content:

```python
SALES_KEYWORDS = ["sell", "sale", "offer", "price", "discount", "order", "buy", 
                  "purchase", "product", "interest", "deal", "promotion"]

sales = [t for t in all_transcripts 
         if any(kw in t.lower() for kw in SALES_KEYWORDS)]
```

## Translation Prompt

Use GPT-4.1 to translate English dialogues to Bosnian with Aquaphor Smile context. CRITICAL: use `str.replace()` not `str.format()` for the prompt template — the original transcripts contain curly braces that break `.format()`.

```python
TRANSLATE_PROMPT = """...Original-Dialog:
__ORIGINAL__
..."""

prompt = TRANSLATE_PROMPT.replace("__ORIGINAL__", original)
```

## OpenAI Library Workaround

If `openai` Python library throws `APIConnectionError` but `curl` works fine, use `urllib.request` directly:

```python
import urllib.request, json

data = json.dumps({"model": "gpt-4.1", "messages": [...], ...}).encode()
req = urllib.request.Request("https://api.openai.com/v1/chat/completions", data=data,
    headers={"Authorization": f"Bearer {API_KEY}", "Content-Type": "application/json"})
with urllib.request.urlopen(req, timeout=120) as resp:
    result = json.loads(resp.read())
```
