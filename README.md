# quarto-ukraine-academic

Ukrainian academic documents in PDF and DOCX with [Quarto](https://quarto.org/) following [DSTU formatting guidelines](https://github.com/myshevchuk/dstu-csl/blob/master/dstu-8302-2015.csl).

Install into an existing project:

```bash
quarto add sinnrrr/quarto-ukraine-academic
```

Create from the starter template:

```bash
quarto use template sinnrrr/quarto-ukraine-academic
```

Minimal usage:

```yaml
project:
  type: book

title: "Назва роботи"
author: "Ім'я Прізвище"
date: "2026"

format:
  ukraine-academic-pdf: default
  ukraine-academic-docx: default

ukraine-academic:
  document-type: thesis
  institution-lines:
    - "ПРИВАТНИЙ НАВЧАЛЬНИЙ ЗАКЛАД"
    - "«УНІВЕРСИТЕТ"
    - "ПРИКЛАДНИХ ДИВ І НЕСПОДІВАНИХ ВІДКРИТТІВ»"
  faculty: "Інститут"
  department: "Кафедра"
  work-type: "КВАЛІФІКАЦІЙНА РОБОТА БАКАЛАВРА"
  student-group: "ТУ-00-00"
  author-short: "Ім'я П.П."
  supervisor-role: "Керівник: к.т.н., доцент"
  supervisor-name: "Прізвище І.І."
  reviewer-role: "Рецензент: к.т.н., доцент"
  reviewer-name: "Прізвище І.І."
  department-head-role: "к.т.н., доцент"
  department-head-name: "Прізвище І.І."
  city: "Київ"
  year: "2026"
```
