# ARB Excel Converter
[![pub package](https://img.shields.io/pub/v/arb_excel_converter.svg)](https://pub.dev/packages/arb_excel_converter)

For reading, creating and updating ARB files from XLSX files and vice versa.

## Install

```bash
pub global activate arb_excel_converter
```

## Usage

```bash
pub global run arb_excel_converter

arb_excel_converter [OPTIONS] path/to/file/name

OPTIONS
-n, --new      New translation sheet
-a, --arb      Export to ARB files
-e, --excel    Import ARB files to sheet
```

Generates ARB files from a XLSX file.

```bash
pub global run arb_excel_converter -a app.xlsx
```

Creates a XLSX file from ARB files.

```bash
pub global run arb_excel_converter -e app_en.arb
```
