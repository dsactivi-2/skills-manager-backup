# PDF & Excel Generation for Project Documentation

## PDF Generation with fpdf2

### Latin-1 Encoding Pitfall

fpdf2's built-in Helvetica font only supports latin-1 encoding. Characters outside latin-1 (em-dash `—`, bullet `•`, German umlauts `äöüß`, Bosnian diacritics `ćčšđž`) will crash with `FPDFUnicodeEncodingException`.

**Fix:** Replace all non-latin-1 characters with ASCII equivalents before rendering:
```python
replacements = {
    'ä': 'ae', 'ö': 'oe', 'ü': 'ue', 'ß': 'ss',
    'ć': 'c', 'č': 'c', 'š': 's', 'đ': 'd', 'ž': 'z',
    '—': '-', '–': '-', '•': '-', '…': '...',
}
```

### Bullet Points

The `bullet()` method using `chr(8226)` (•) fails with latin-1 fonts. Use `body_text("  - text")` instead of a separate bullet method.

### multi_cell Width

When calling `multi_cell(w=0, ...)` after a `cell()` that changed x-position, the width calculation can fail with "Not enough horizontal space". Always reset x with `set_x(self.l_margin)` before multi_cell, or use explicit width: `multi_cell(w=self.w - self.l_margin - self.r_margin, ...)`.

## Excel Generation with openpyxl

### Checklist Pattern

Four-sheet workbook structure proven for voice agent projects:
1. **Test-Checkliste** — Test cases with phase, expected behavior, status column
2. **Konfiguration** — All agent parameters in key-value format
3. **Call-Log** — Empty rows for manual test call logging
4. **Prompt-Versionen** — Changelog for prompt iterations

### Styling

- Header: dark blue background (#1E3C78), white bold text
- Data: Calibri 10pt, thin borders, wrap text
- Status column: pre-filled with "NICHT GETESTET" in gray
- Summary row: COUNTIF formula for pass/total ratio

### FileNotFoundError

`wb.save()` fails if the output directory doesn't exist. Always `mkdir -p` the output directory before saving.
