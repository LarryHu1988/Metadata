# PDF Librarian

PDF Librarian is a macOS app for organizing book and academic paper PDFs. It searches public metadata sources, lets you review and edit Dublin Core fields, writes confirmed metadata back into PDF files, and renames files with a consistent library rule.

Official public release: `V1.0.0`

Download:

- [GitHub Releases](https://github.com/LarryHu1988/PDFLibrarian/releases)

## 中文

### 产品说明

PDF Librarian 是一款面向 macOS 的 PDF 元数据整理工具，适合书籍、论文和参考资料归档。

### 核心功能

- 基于文件名和 PDF 内容提示检索元数据
- 聚合 `Google Books`、`Open Library`、`豆瓣网页搜索`、`Library of Congress`
- 按 `ISBN -> DOI -> 标题+作者` 去重并合并字段
- 写入前可手动编辑 Dublin Core 字段
- 按确认后的字段值写回 PDF 元数据
- 根据最新写入的元数据生成建议文件名
- 重命名时允许用户再次手动修改最终文件名
- 支持 `日光 / 月光` 两种界面外观
- 支持多语言界面

### 典型流程

1. 选择 PDF 文件或文件夹
2. 联网检索并合并候选元数据
3. 编辑并确认写入 Dublin Core 字段
4. 确认或修改最终文件名后执行重命名

### 默认写入字段

`dc:title`、`dc:creator`、`dc:publisher`、`dc:date`、`dc:language`、`dc:type`、`dc:format`、`dc:identifier`、`dc:subject`

### 从源码构建

```bash
swift build
./scripts/package_app.sh
./scripts/build_release_assets.sh
```

构建产物位于 `dist/`。

## English

### Overview

PDF Librarian is a macOS desktop app for cleaning up and standardizing metadata in book and academic paper PDFs.

### Features

- Metadata lookup from filename and extracted PDF hints
- Multi-source search across `Google Books`, `Open Library`, `Douban web search`, and `Library of Congress`
- Deduplication and merge flow using `ISBN -> DOI -> title + author`
- Editable Dublin Core values before writing
- Metadata writing uses the final confirmed field values
- Rename suggestions are generated from the latest written metadata
- Users can edit the final file name before rename
- `Daylight / Moonlight` appearance modes
- Multi-language UI

### Workflow

1. Select a PDF file or folder
2. Search and merge metadata candidates
3. Review, edit, and confirm Dublin Core values
4. Confirm or edit the final file name and rename the PDF

### Default Dublin Core Fields

`dc:title`, `dc:creator`, `dc:publisher`, `dc:date`, `dc:language`, `dc:type`, `dc:format`, `dc:identifier`, `dc:subject`

### Build From Source

```bash
swift build
./scripts/package_app.sh
./scripts/build_release_assets.sh
```

Build artifacts are generated in `dist/`.
