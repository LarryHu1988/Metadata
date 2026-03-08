# App Review Notes Draft

## English

PDF Librarian is a macOS app for organizing book and academic paper PDFs.

How the app works:

- The app only accesses files or folders explicitly selected by the user through the standard macOS open panel.
- The app can search public metadata sources to find book or paper information, including Google Books, Open Library, Douban web search, and the Library of Congress.
- The app writes Dublin Core metadata into the selected PDF after the user reviews and confirms the final field values.
- The app can rename the selected PDF after the user confirms the final file name.

Permissions explanation:

- File access is required so the app can read the user-selected PDFs and write metadata back into those same files.
- Network access is required only to query public metadata sources requested by the user.

Important notes for review:

- No user account, login, subscription, or in-app purchase is required.
- The app does not provide user-generated content sharing or social features.
- The app does not use advertising SDKs or tracking SDKs.

## 中文

PDF Librarian 是一款用于整理书籍和学术文献 PDF 的 macOS 应用。

工作方式说明：

- 应用只会访问用户通过系统文件选择面板明确选中的文件或文件夹。
- 应用可在用户发起操作后，联网查询公开元数据来源，包括 Google Books、Open Library、豆瓣网页检索和 Library of Congress。
- 应用会在用户确认最终字段值后，将 Dublin Core 元数据写入所选 PDF。
- 应用会在用户确认最终文件名后，对所选 PDF 执行重命名。

权限说明：

- 文件权限用于读取用户选中的 PDF，并将元数据写回这些文件。
- 网络权限仅用于查询用户主动请求的公开元数据来源。

补充说明：

- 应用不需要用户登录或注册。
- 应用没有广告 SDK、跟踪 SDK、社交分享或用户社区内容。
