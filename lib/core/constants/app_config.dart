/// 应用配置
/// 包含 API Key 和其他常量配置
class AppConfig {
  // Kimi API 配置
  static const String kimiApiKey = 'sk-ttiNDgoZqi6nAXnyBzJn7A1yhpxSgde6rfMJ2oYo5Ln6HU5O';
  static const String kimiBaseUrl = 'https://api.moonshot.cn/v1';
  static const String kimiModel = 'moonshot-v1-8k';

  // API 超时配置
  static const Duration apiTimeout = Duration(seconds: 30);
  static const Duration apiConnectTimeout = Duration(seconds: 10);

  // 语音识别配置
  static const Duration maxRecordingDuration = Duration(seconds: 30);
  static const String recordingLocaleId = 'zh_CN';

  // 本地存储配置
  static const String prefsKeyFirstLaunch = 'first_launch';
  static const String prefsKeyPinCode = 'pin_code';
  static const String prefsKeyUseBiometric = 'use_biometric';
  static const String prefsKeyDeviceName = 'device_name';
  static const String prefsKeyDeviceId = 'device_id';
  static const String prefsKeyPairedDevices = 'paired_devices';

  // 同步配置
  static const int syncPort = 8765;
  static const String mdnsServiceType = '_lightaccount._tcp';

  // 默认分类（当数据库为空时使用）
  static const List<Map<String, dynamic>> defaultCategories = [
    // 支出分类
    {'id': 'cat_dining', 'name': '餐饮', 'icon': '🍔', 'color': 0xFFFF6B6B, 'type': 0, 'keywords': ['吃饭', '餐厅', '外卖', '食堂', '火锅', '烧烤', '早餐', '午餐', '晚餐']},
    {'id': 'cat_transport', 'name': '交通', 'icon': '🚗', 'color': 0xFF4ECDC4, 'type': 0, 'keywords': ['打车', '地铁', '公交', '高铁', '飞机', '加油', '停车费', '滴滴', '出租车']},
    {'id': 'cat_shopping', 'name': '购物', 'icon': '🛍️', 'color': 0xFF95E1D3, 'type': 0, 'keywords': ['买东西', '超市', '淘宝', '京东', '拼多多', '买衣服', '买鞋', '购物']},
    {'id': 'cat_entertainment', 'name': '娱乐', 'icon': '🎮', 'color': 0xFFF38181, 'type': 0, 'keywords': ['看电影', '游戏', 'KTV', '唱歌', '打牌', '麻将', '娱乐']},
    {'id': 'cat_housing', 'name': '居住', 'icon': '🏠', 'color': 0xFFAA96DA, 'type': 0, 'keywords': ['房租', '水电', '物业费', '煤气', '宽带', '维修']},
    {'id': 'cat_medical', 'name': '医疗', 'icon': '💊', 'color': 0xFFFCBAD3, 'type': 0, 'keywords': ['医院', '看病', '买药', '体检', '挂号']},
    {'id': 'cat_education', 'name': '教育', 'icon': '📚', 'color': 0xFFFFD93D, 'type': 0, 'keywords': ['学费', '买书', '课程', '培训', '考试']},
    {'id': 'cat_other_expense', 'name': '其他', 'icon': '📦', 'color': 0xFFCCCCCC, 'type': 0, 'keywords': []},
    // 收入分类
    {'id': 'cat_salary', 'name': '工资', 'icon': '💰', 'color': 0xFF4CAF50, 'type': 1, 'keywords': ['工资', '薪水', '发钱']},
    {'id': 'cat_bonus', 'name': '奖金', 'icon': '🧧', 'color': 0xFF8BC34A, 'type': 1, 'keywords': ['奖金', '红包', '奖励']},
    {'id': 'cat_investment', 'name': '理财', 'icon': '📈', 'color': 0xFFCDDC39, 'type': 1, 'keywords': ['理财', '股票', '基金', '利息', '收益']},
    {'id': 'cat_parttime', 'name': '兼职', 'icon': '💼', 'color': 0xFFFFEB3B, 'type': 1, 'keywords': ['兼职', '副业', '外快']},
    {'id': 'cat_other_income', 'name': '其他', 'icon': '💵', 'color': 0xFFCCCCCC, 'type': 1, 'keywords': []},
  ];
}
