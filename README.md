# 轻账 - 魅族风格本地记账应用

一款极简设计的本地记账应用，采用魅族美学设计风格。

## 📱 下载安装

### 直接下载 APK

| 版本 | 下载链接 | 说明 |
|------|---------|------|
| Debug | [app-debug.apk](#) | 开发测试版本 |
| Release | [app-release.apk](#) | 正式版本（推荐） |

**最低要求**: Android 6.0 (API 23) 及以上

### 从源码构建

查看 [BUILD_APK_GUIDE.md](../BUILD_APK_GUIDE.md) 获取详细构建说明。

快速构建：
```bash
# Windows
..\build_apk.bat

# macOS/Linux
../build_apk.sh
```

## ✨ 特性

- **魅族风格设计**：大面积留白、圆角、克制配色
- **本地存储**：数据保存在本地，保护隐私
- **语音记账**：AI 语音识别，一句话完成记账
- **快速记账**：3步完成记账
- **多视图统计**：日/周/月视图切换
- **局域网同步**：设备间安全同步数据（开发中）

## 🎙️ 语音记账

按住首页底部的"按住说话记账"按钮，说出账单内容：

| 你说 | 识别结果 |
|------|---------|
| "中午吃饭花了三十五块" | 餐饮 -¥35.00 |
| "打车去公司25块钱" | 交通 -¥25.00 |
| "发工资一万" | 工资 +¥10000.00 |

## 📸 截图

（待添加）

## 🚀 已实现功能

### Phase 1 - 基础框架 ✅
- [x] 项目结构和配置文件
- [x] 魅族主题系统
- [x] SQLite 数据库层
- [x] 数据模型（账单、分类）
- [x] 首页 UI（日期导航、金额卡片、账单列表）
- [x] 记账流程（手动输入）

### Phase 2 - AI 功能 ✅
- [x] Kimi API 集成
- [x] 语音记账界面
- [x] AI 账单解析
- [x] 结果预览确认

### Phase 3 - 增强功能（进行中）
- [ ] 分类管理
- [ ] 统计图表
- [ ] 应用锁
- [ ] 局域网同步

### Phase 4 - 优化发布
- [ ] 动画优化
- [ ] 性能优化
- [ ] 应用商店发布

## 🛠️ 开发环境

- Flutter 3.19.0
- Dart 3.x
- Android SDK 34

## 📂 项目结构

```
lib/
├── main.dart                 # 应用入口
├── app.dart                  # MaterialApp 配置
├── core/
│   ├── constants/           # 配置常量
│   │   └── app_config.dart  # API Key 等
│   ├── theme/               # 主题配置
│   └── utils/               # 工具类
├── data/
│   └── database/            # 数据库层
├── models/
│   └── bill_model.dart      # 数据模型
├── providers/               # Riverpod 状态管理
├── services/                # 服务层
│   ├── kimi_service.dart    # Kimi AI 服务
│   └── voice_service.dart   # 语音服务
├── screens/                 # 页面
└── widgets/                 # 通用组件
```

## 🔧 本地开发

```bash
# 1. 克隆项目
git clone <repo-url>
cd light_account

# 2. 安装依赖
flutter pub get

# 3. 配置 API Key（可选，默认已配置）
# 编辑 lib/core/constants/app_config.dart

# 4. 运行应用
flutter run
```

## 🤝 贡献

欢迎提交 Issue 和 PR！

## 📄 许可证

MIT License

## 🙏 致谢

- [Kimi AI](https://www.moonshot.cn/) - 语音识别与解析
- [Flutter](https://flutter.dev/) - 跨平台框架
