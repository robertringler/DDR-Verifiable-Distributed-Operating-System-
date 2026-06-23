#!/usr/bin/env python3
"""Build a typeset PDF of the CIIR corrected monograph from monograph.md."""
import datetime
import re
import markdown
from weasyprint import HTML

SRC = "monograph.md"
OUT = "CIIR-corrected-monograph.pdf"

with open(SRC, encoding="utf-8") as f:
    md_text = f.read()

# Drop the first H1 (we render a dedicated title page instead)
lines = md_text.splitlines()
if lines and lines[0].startswith("# "):
    title = lines[0][2:].strip()
    # also drop an immediate H3 subtitle if present
    body_start = 1
    while body_start < len(lines) and lines[body_start].strip() == "":
        body_start += 1
    subtitle = ""
    if body_start < len(lines) and lines[body_start].startswith("### "):
        subtitle = lines[body_start][4:].strip()
        body_start += 1
    md_body = "\n".join(lines[body_start:])
else:
    title, subtitle, md_body = "CIIR — A Corrected Monograph", "", md_text

html_body = markdown.markdown(
    md_body,
    extensions=["tables", "fenced_code", "toc", "sane_lists", "attr_list"],
)

date = datetime.date.today().isoformat()
css = """
@page {
  size: A4; margin: 22mm 20mm 24mm 20mm;
  @bottom-center { content: counter(page); font-size: 9pt; color: #555; }
  @top-center { content: "CIIR — A Corrected Monograph"; font-size: 8pt; color: #999; }
}
@page :first { @top-center { content: none; } @bottom-center { content: none; } }
html { font-family: "DejaVu Serif", "Noto Serif", Georgia, serif;
       font-size: 10.5pt; line-height: 1.45; color: #111; }
body { hyphens: auto; text-align: justify; }
h1, h2, h3, h4 { font-family: "DejaVu Sans", "Noto Sans", Helvetica, sans-serif;
                 line-height: 1.2; color: #0b2545; page-break-after: avoid; }
h1 { font-size: 19pt; margin: 0 0 .3em; border-bottom: 2px solid #0b2545;
     padding-bottom: .15em; page-break-before: always; }
h1:first-of-type { page-break-before: avoid; }
h2 { font-size: 14pt; margin: 1.3em 0 .35em; page-break-before: always; }
h3 { font-size: 11.5pt; margin: 1.1em 0 .3em; color: #1d3b6b; }
h4 { font-size: 10.5pt; margin: 1em 0 .25em; color: #333; }
p { margin: .35em 0; }
blockquote { border-left: 3px solid #c2c2c2; background: #f6f7f9;
             margin: .6em 0; padding: .4em .9em; }
code, pre { font-family: "DejaVu Sans Mono", "Noto Sans Mono", monospace;
            font-size: 8.6pt; }
pre { background: #f4f4f6; border: 1px solid #e0e0e6; border-radius: 4px;
      padding: .6em .8em; white-space: pre-wrap; word-wrap: break-word;
      page-break-inside: avoid; }
:not(pre) > code { background: #eef0f3; padding: .04em .3em; border-radius: 3px; }
table { border-collapse: collapse; width: 100%; margin: .7em 0; font-size: 9pt;
        page-break-inside: avoid; }
th, td { border: 1px solid #c9ccd3; padding: 4px 7px; text-align: left;
         vertical-align: top; }
th { background: #0b2545; color: #fff; font-family: "DejaVu Sans", sans-serif; }
tr:nth-child(even) td { background: #f5f6f8; }
hr { border: none; border-top: 1px solid #d8d8de; margin: 1.1em 0; }
strong { color: #0b2545; }
a { color: #1d3b6b; text-decoration: none; }
.title-page { page-break-after: always; text-align: center; padding-top: 32%; }
.title-page .t { font-family: "DejaVu Sans", sans-serif; font-size: 30pt;
                 font-weight: 700; color: #0b2545; line-height: 1.1; }
.title-page .s { font-family: "DejaVu Sans", sans-serif; font-size: 13pt;
                 color: #1d3b6b; margin-top: 1.2em; }
.title-page .m { font-size: 10pt; color: #555; margin-top: 3.5em; }
"""

doc = f"""<!DOCTYPE html><html><head><meta charset="utf-8">
<style>{css}</style></head><body>
<div class="title-page">
  <div class="t">{title}</div>
  <div class="s">{subtitle}</div>
  <div class="m">A corrected edition built on verified mathematics<br>
  Generated {date}<br>
  Provenance, status tags, and the Appendix B ledger are integral to the text.</div>
</div>
{html_body}
</body></html>"""

HTML(string=doc, base_url=".").write_pdf(OUT)
print("wrote", OUT)
