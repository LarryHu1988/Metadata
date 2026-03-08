# Mac App Store 提交清单（PDF Librarian）

## 一、代码仓库内已准备

- [x] App Logo 设计稿（1024x1024 PNG）
  - `docs/assets/PDFLibrarian-logo-1024.png`
- [x] AppIcon 资产目录（macOS 全尺寸）
  - `Sources/PDFLibrarian/Assets.xcassets/AppIcon.appiconset`
- [x] `.icns` 图标（用于本地脚本打包）
  - `Sources/PDFLibrarian/Resources/AppIcon.icns`
- [x] 图标自动生成脚本
  - `scripts/generate_app_logo.swift`
  - `scripts/generate_app_icons.sh`
- [x] 打包脚本已接入图标
  - `scripts/package_app.sh`
  - `scripts/build_release_assets.sh`
- [x] Xcode Target 已接入资源和 AppIcon 编译
  - `project.yml`
  - `PDFLibrarian.xcodeproj/project.pbxproj`
- [x] App Sandbox entitlements 已配置
  - `Sources/PDFLibrarian/PDFLibrarian.entitlements`
  - 已启用：
    - `com.apple.security.app-sandbox`
    - `com.apple.security.files.user-selected.read-write`
    - `com.apple.security.network.client`
- [x] Info.plist 已补充 App Store 常用字段
  - `LSApplicationCategoryType=public.app-category.productivity`
  - `ITSAppUsesNonExemptEncryption=false`

## 二、你在 App Store Connect 仍需准备

- [ ] App 记录创建（Bundle ID 与当前工程配置一致）
- [ ] 价格与上架地区
- [ ] 年龄分级问卷
- [ ] 隐私问卷（若不收集用户数据，按实际填“不收集”）
- [ ] 出口合规（已在 plist 标注 `ITSAppUsesNonExemptEncryption=false`，仍需在 ASC 页面确认）
- [ ] 截图（macOS 尺寸，建议至少准备 16:10 与 16:9 两套）
- [ ] 审核备注（说明联网来源、文件读写方式、为何需要网络权限）

## 三、提交前本地操作建议

1. 生成最新图标资源（可重复执行）
   - `./scripts/generate_app_icons.sh`
2. 用 Xcode `Archive`（Release）导出 `Mac App Store` 包
3. 在 Organizer 里 `Validate App` 再 `Distribute App`

## 四、可直接复用的文案

- 上架文案草稿：
  - `docs/APP_STORE_LISTING.md`
