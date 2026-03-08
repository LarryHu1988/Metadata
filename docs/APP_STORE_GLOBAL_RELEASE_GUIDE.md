# PDF Librarian 全球上架操作指南

适用平台：`macOS`
当前 App Store 使用的 Bundle ID：已在工程配置中定义
建议商店版本号：`1.0.0`

## 1. 先完成账号前置条件

在 App Store Connect 检查以下项目是否完成：

- `Business` 中最新的 `Paid Apps Agreement` 已接受
- 税务信息已填写
- 银行收款账户已填写

如果 `Paid Apps Agreement` 没签，App 只能免费，不能设定收费价格。

## 2. 创建 App Store Connect 里的 App 记录

路径：`App Store Connect -> Apps -> + -> New App`

填写建议：

- Platform: `macOS`
- Name: `PDF Librarian`
- Primary Language: `English (U.S.)`
- Bundle ID: 使用工程当前配置中的显式 Bundle ID
- SKU: `pdflibrarian-macos`
- User Access: `Full Access`

## 3. 配置基础信息

进入 App 详情页后，先填写：

- Category: `Productivity`
- Age Rating: 按问卷实际填写
- Privacy Policy URL: 需要公网可访问
- Support URL: 需要公网可访问
- Marketing URL: 可选，没有也可以

本仓库已准备可作为 URL 内容源的文档：

- `docs/PRIVACY_POLICY.md`
- `docs/SUPPORT.md`

## 4. 设置价格和全球可用地区

路径：`Pricing and Availability`

### 价格设置建议

你的目标是中国区卖 `19.9 元`，同时上架全球。最稳的做法：

- Base Country or Region 选 `China mainland`
- 在 Price 里选择显示为 `CNY 19.90` 的 price point
- 其他国家或地区先使用 Apple 自动换算价格

原因：

- Apple 不会自动改动基准地区价格
- 其他 174 个 storefront 会按汇率、税率和当地定价习惯自动换算

如果你在价格下拉里没有看到 `CNY 19.90`，说明该金额不在 Apple 当前 price point 列表里，此时不能手输，只能选择最接近的可用价位。

### 全球可用地区设置

在 `App Availability` 里选择：

- `All Countries or Regions`

这样会覆盖当前全部 `175` 个国家或地区，也会自动包含未来 Apple 新增的 storefront。

## 5. 准备商店文案

优先填写英文，再补简体中文。

本仓库已有上架文案草稿：

- `docs/APP_STORE_LISTING.md`

建议至少配置：

- English (U.S.)
- Simplified Chinese

如果后续想做全球转化优化，再补：

- Japanese
- German
- French

## 6. 准备截图

路径：版本页 -> `App Previews and Screenshots`

要求：

- 每个语言至少上传 `1` 张，最多 `10` 张
- 格式支持：`.png` `.jpg` `.jpeg`
- 可以只上传最高分辨率的 macOS 截图，Apple 会自动缩放到较小展示位

建议你先准备英文版 5 张，再补中文版 5 张。

推荐截图主题：

- 首页与四步流程总览
- 联网检索候选结果
- 第三步元数据可编辑写入
- 第四步可编辑重命名
- 多语言和外观切换

## 7. 在 Xcode 归档并上传审核包

不要上传 `zip/dmg` 到 App Store Connect。商店审核只接受通过 Xcode / Transporter 上传的构建。

推荐流程：

1. 用 Xcode 打开 `PDFLibrarian.xcodeproj`
2. 选择 `Any Mac` 或本机目标
3. Scheme 选择 `PDFLibrarian`
4. 菜单执行 `Product -> Archive`
5. Archive 完成后，在 Organizer 中点击 `Distribute App`
6. 选择 `App Store Connect`
7. 选择 `Upload`
8. 按默认选项继续，完成上传

上传完成后，等待 Apple 处理 build。处理结束后，这个 build 才会出现在版本页可选列表里。

## 8. 关联 build 到版本

路径：macOS 版本页 -> `Build`

操作：

- 选择刚处理完成的 `1.0.0` build

注意：

- 一个版本一次只能关联一个 build
- 提交审核前可以反复更换 build

## 9. 填写审核信息

需要填写：

- Contact Name
- Email
- Phone Number
- Review Notes

本仓库已准备审核备注草稿：

- `docs/APP_REVIEW_NOTES.md`

## 10. 填写 App Privacy

路径：`App Information -> App Privacy`

本仓库已准备隐私问卷草稿：

- `docs/APP_PRIVACY_QUESTIONNAIRE_DRAFT.md`

注意：

- App Privacy 是按整个 App 级别填写，不是只按 macOS
- 如果你以后接入分析 SDK、崩溃上报 SDK、账号系统，这份内容要重新更新

## 11. 选择上架发布时间

路径：版本页 -> `App Store Version Release`

建议：

- 首次全球上架，选择 `Manually release this version`

原因：

- 这样即使审核通过，也不会立刻在全球 175 区同步上线
- 你可以先确认价格、截图、地区和元数据都正确，再手动点发布

## 12. 提交审核

版本页右上角：

1. `Add for Review`
2. `Submit for Review`

提交后通常会经历这些状态：

- `Ready for Review`
- `Waiting for Review`
- `In Review`
- `Pending Developer Release` 或 `Ready for Distribution`

## 13. 审核通过后手动发布

如果你选择的是手动发布：

- 状态变成 `Pending Developer Release` 后
- 点击 `Release This Version`

全球可见通常会在数小时到 24 小时内逐步完成。

## 14. 首次上架后建议立即检查

建议重点检查这些 storefront：

- China mainland
- United States
- Japan
- Germany
- France
- United Kingdom
- Hong Kong
- Taiwan

检查内容：

- 售价是否符合预期
- 图标是否正确
- 第一张截图是否最能表达产品
- 英文文案是否自然
- 中国区价格是否仍保持 `19.90`
