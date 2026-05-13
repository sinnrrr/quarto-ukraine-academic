# quarto-ukraine-academic

Local Quarto custom format for Ukrainian academic documents.

Current scope:
- shared academic page/layout conventions for PDF and DOCX
- thesis-style front matter driven by YAML metadata

Current format names:
- `ukraine-academic-pdf`
- `ukraine-academic-docx`

Current metadata contract:

```yaml
format:
  ukraine-academic-pdf: default
  ukraine-academic-docx: default

ukraine-academic:
  document-type: thesis
```

Planned public direction:
- keep common formatting under `ukraine-academic-*`
- support multiple document profiles through metadata
- extend beyond the current thesis profile with additional title-page variants
