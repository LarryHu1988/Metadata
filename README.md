# PDF Librarian 📚 (macOS)

A desktop app for managing metadata of book/paper PDFs.

## 中文介绍 🇨🇳

### ✨ 核心功能
- 🔎 基于文件名与 PDF 内容提示，联网检索书籍/文献元数据
- 🌐 多源聚合：Google Books API、Open Library API、豆瓣网页搜索、Library of Congress
- 🧩 字段去重与合并：按 `ISBN -> DOI -> 标题+作者` 去重并合并字段
- 🏷️ 支持 Dublin Core 字段选择写入，并可在写入前手动编辑字段值
- 🧼 写入前清空旧 PDF 内嵌元数据并清空 xattr，再写入新值
- 📝 按标准规则重命名：`书名_作者_出版社_出版年_语言.pdf`
- 🎨 支持界面外观切换：`日光 / 月光`
- 🗣️ 支持多语言界面（前十大语言）

### 🚀 下载安装（GitHub Release）
1. 打开 [Releases 页面](https://github.com/LarryHu1988/Metadata/releases)
2. 下载 `PDFLibrarian-1.0.3.dmg`（推荐）或 `PDFLibrarian-1.0.3.zip`
3. 若是 DMG：打开后将 `PDF Librarian.app` 拖到 `Applications`，即安装完成
4. 若是 ZIP：解压后将 `.app` 拖到 `Applications`

首次打开如遇到系统安全提示：
- 在 Finder 中右键 `PDF Librarian.app` -> `打开`
- 或在 `系统设置 -> 隐私与安全性` 中允许打开

若弹窗提示：`Apple 无法验证“PDF Librarian.app”是否包含可能危害 Mac 安全或泄漏隐私的恶意软件`

请按以下步骤解除：
1. 先关闭提示框，把 `PDF Librarian.app` 拖到 `Applications`
2. 打开 `系统设置 -> 隐私与安全性`
3. 在底部“安全性”区域找到被拦截提示，点击 `仍要打开`
4. 再次打开 App，出现确认框时点击 `打开`

### 🧭 固定工作流
1. 选择 PDF 文件或文件夹（递归扫描 PDF）
2. 联网检索并合并候选元数据
3. 选择/编辑 Dublin Core 字段后确认写入
4. 询问是否按规则重命名

### 🏷️ 默认勾选写入字段
`dc:title`、`dc:creator`、`dc:publisher`、`dc:date`、`dc:language`、`dc:type`、`dc:format`、`dc:identifier`、`dc:subject`

### 🛠️ 开发与打包
```bash
swift build
./scripts/package_app.sh
./scripts/build_release_assets.sh
```

输出目录：`dist/`

---

## English 🇺🇸

### ✨ Features
- 🔎 Online metadata lookup from filename + extracted PDF hints
- 🌐 Multi-source aggregation: Google Books API, Open Library API, Douban web search, Library of Congress
- 🧩 Dedup + merge pipeline using `ISBN -> DOI -> title+author`
- 🏷️ Selectable Dublin Core fields with editable values before writing
- 🧼 Clears old embedded PDF metadata and xattrs before writing new values
- 📝 Standard rename rule: `title_author_publisher_year_language.pdf`
- 🎨 Appearance modes: `Daylight / Moonlight`
- 🗣️ Multi-language UI support

### 🚀 Install from GitHub Releases
1. Open the [Releases page](https://github.com/LarryHu1988/Metadata/releases)
2. Download `PDFLibrarian-1.0.3.dmg` (recommended) or `PDFLibrarian-1.0.3.zip`
3. For DMG: open it and drag `PDF Librarian.app` to `Applications`
4. For ZIP: unzip and drag the app into `Applications`

If macOS blocks first launch:
- Right-click the app in Finder and choose `Open`
- Or allow it in `System Settings -> Privacy & Security`

If you see the warning:
`Apple cannot verify “PDF Librarian.app” is free of malware that may harm your Mac or compromise your privacy`

Use these steps:
1. Close the alert and move `PDF Librarian.app` to `Applications`
2. Open `System Settings -> Privacy & Security`
3. In the Security section, find the blocked app message and click `Open Anyway`
4. Launch the app again and click `Open` in the confirmation dialog

### 🧭 Workflow
1. Select a PDF file/folder
2. Search & merge online metadata candidates
3. Select/edit Dublin Core fields and confirm write
4. Confirm optional rule-based rename

### 🛠️ Build
```bash
swift build
./scripts/package_app.sh
./scripts/build_release_assets.sh
```

Artifacts are generated in `dist/`.
