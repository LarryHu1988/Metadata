# MetadataOrganizerApp (macOS)

面向书籍 PDF / 文献 PDF 的元数据处理工具。

## 固定流程

1. 选择单个 PDF 或文件夹（递归扫描 PDF）
2. 根据文件名与 PDF 内容提示联网检索元数据
3. 确认后写入元数据
4. 再询问是否按规则重命名

## 数据源链路（按顺序）

- ISBN -> Open Library（主）
- Google Books（补充）
- LoC / WorldCat（校验）

## WorldCat 官方 API

程序已直接接入 OCLC WorldCat 官方 API：
- Token：`https://oauth.oclc.org/token`
- 检索：`https://americas.discovery.api.oclc.org/worldcat/search/v2/brief-bibs`

在界面里填写：
- `WorldCat API Key`
- `WorldCat API Secret`
- `Scope`（默认 `wcapi`）

如果未填写 Key/Secret，会自动跳过 WorldCat 官方校验并写入日志。

## 命名规则

重命名采用：

`书名_作者_出版社_出版年_语言.pdf`

示例：

`Clean_Code_Robert_C_Martin_Prentice_Hall_2008_en.pdf`

## 运行

```bash
swift run
```

## 打包为可双击 .app

```bash
./scripts/package_app.sh
```

输出：`dist/MetadataOrganizerApp.app`
