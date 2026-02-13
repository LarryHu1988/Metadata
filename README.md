# MetadataOrganizerApp (macOS)

面向书籍 PDF / 文献 PDF 的元数据处理工具。

## 固定流程

1. 选择单个 PDF 或文件夹（递归扫描 PDF）
2. 根据文件名与 PDF 内容提示联网检索元数据
3. 确认后写入 Dublin Core 元数据
4. 再询问是否按规则重命名

## 数据源方案

- Open Library API
- Google Books API
- 豆瓣网页搜索
- Library of Congress API

系统会并行查询多源结果，并按以下规则处理：

- 去重键：`ISBN -> DOI -> 标题+作者`
- 字段合并：标题、作者、出版社、出版年、语言、标识符取最优非空值
- 来源合并：候选卡片显示合并后的来源列表与置信度

说明：系统仅使用以上四个数据源。

## 命名规则

重命名采用：

`书名_作者_出版社_出版年_语言.pdf`

字段规则：

- 字段之间使用 `_` 分隔
- 每个字段内部若有空格，替换为 `.`

示例：

`Clean.Code_Robert.C.Martin_Prentice.Hall_2008_en.pdf`

## 元数据标准

写入采用 Dublin Core 字段（以 `dc:` 前缀保存）：

- `dc:title`
- `dc:creator`
- `dc:publisher`
- `dc:date`
- `dc:language`
- `dc:type`
- `dc:format`
- `dc:identifier`
- `dc:source`
- `dc:subject`
- `dc:relation`
- `dc:description`

字段可在界面中勾选，默认选中：

- `dc:title`
- `dc:creator`
- `dc:publisher`
- `dc:date`
- `dc:language`
- `dc:type`
- `dc:format`
- `dc:identifier`
- `dc:subject`

## 运行

```bash
swift run
```

## 打包为可双击 .app

```bash
./scripts/package_app.sh
```

输出：`dist/MetadataOrganizerApp.app`
