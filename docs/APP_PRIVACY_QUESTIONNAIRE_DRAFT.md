# App Privacy 问卷草稿

以下内容是基于当前代码实现的工程判断草稿，不是法律意见。提交前你应以 Apple 当时页面的定义和你自己的运营方式再核对一遍。

## 当前代码层面已确认的情况

- 没有登录、注册、账号体系
- 没有广告 SDK
- 没有分析 SDK
- 没有崩溃上报 SDK
- 没有设备指纹、IDFA、跟踪逻辑
- 没有位置、通讯录、照片库、麦克风、相机访问
- 只访问用户显式选择的文件或文件夹
- 会向公开元数据来源发起网络请求，查询关键词可能来自：
  - 文件名
  - 内容提取出的标题提示
  - ISBN
  - DOI

## 保守填写建议

如果你希望首次审核尽量稳妥，可以按较保守的方式填写：

### 是否收集任何数据？

建议选择：

- `Yes, we collect data from this app`

原因：

- App 会把用户选择文件中提取出的查询关键词发送到第三方公开元数据服务
- 尽管当前代码没有账号和跟踪，但这些查询内容确实会离开设备

### 建议申报的数据类型

可考虑申报：

- `User Content`
- 更接近的描述可选 `Other User Content`

用途建议：

- `App Functionality`

是否与用户身份关联：

- `No`

是否用于跟踪：

- `No`

## 更激进的填写方式

如果你严格按照 Apple 的“收集”定义理解，并认定这些查询词只是一次性实时请求，不构成被你或合作方持续访问的数据收集，那么也可能选择：

- `No, we do not collect data`

但这条路径风险更高，因为审核人员可能会把联网查询理解为数据离开设备。首次上架更建议使用上面的保守方案。

## 你在页面上应避免勾选的内容

基于当前代码，通常不应勾选：

- Contact Info
- Health & Fitness
- Financial Info
- Location
- Sensitive Info
- Contacts
- Browsing History
- Search History
- Identifiers
- Purchases
- Diagnostics
- Usage Data

除非你后续新增了：

- 登录系统
- 统计分析
- 崩溃上报
- 订阅或内购
- 自建服务器日志分析

## 后续如果有这些变更，必须重做隐私申报

- 接入 Firebase / Sentry / Mixpanel / Amplitude
- 增加用户账号
- 增加同步功能
- 增加云端存储
- 增加支付、订阅或试用
