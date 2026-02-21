import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../core/constants/app_config.dart';
import '../models/bill_model.dart';

/// Kimi AI 服务
/// 提供语音识别和账单解析功能
class KimiService {
  static final KimiService _instance = KimiService._internal();
  factory KimiService() => _instance;
  KimiService._internal();

  /// 解析语音文本为账单信息
  ///
  /// [text] 语音转文字结果
  /// 返回解析后的账单信息，解析失败返回 null
  Future<ParseResult?> parseBillFromText(String text) async {
    try {
      final response = await http.post(
        Uri.parse('${AppConfig.kimiBaseUrl}/chat/completions'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${AppConfig.kimiApiKey}',
        },
        body: jsonEncode({
          'model': AppConfig.kimiModel,
          'messages': [
            {
              'role': 'system',
              'content': '''你是一个记账助手，需要从用户的自然语言描述中提取账单信息。

请解析以下内容并返回 JSON 格式：
{
  "amount": 金额（数字，单位元，精确到小数点后2位）,
  "type": "expense" 或 "income",
  "category": "分类名称（餐饮/交通/购物/娱乐/居住/医疗/教育/工资/奖金/理财/兼职/其他）",
  "note": "备注信息（可选）",
  "confidence": 置信度（0-1之间的数字）
}

规则：
1. 金额识别："三十五块" -> 35.00，"一百二十三元" -> 123.00，"15块5" -> 15.50
2. 分类识别：根据关键词判断，如"吃饭"->餐饮，"打车"->交通，"发工资"->工资
3. 类型判断：支出关键词（买了、花了、付了）-> expense，收入关键词（发了、赚了、收到）-> income
4. 时间解析：如果提到昨天、前天，在 note 中标注
5. 如果无法确定某个字段，使用 null
6. 置信度低于 0.6 时，category 设为 null'''
            },
            {
              'role': 'user',
              'content': '请解析："$text"',
            }
          ],
          'temperature': 0.3,
          'max_tokens': 500,
        }),
      ).timeout(AppConfig.apiTimeout);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final content = data['choices'][0]['message']['content'] as String;

        // 提取 JSON 部分
        final jsonMatch = RegExp(r'\{[\s\S]*\}').firstMatch(content);
        if (jsonMatch != null) {
          final jsonStr = jsonMatch.group(0)!;
          final result = jsonDecode(jsonStr);

          return ParseResult(
            amount: result['amount']?.toDouble(),
            type: result['type'] == 'income' ? BillType.income : BillType.expense,
            category: result['category']?.toString(),
            note: result['note']?.toString(),
            confidence: result['confidence']?.toDouble() ?? 0.0,
            rawText: text,
          );
        }
      }

      return null;
    } catch (e) {
      print('Kimi API 调用失败: $e');
      return null;
    }
  }

  /// 使用本地规则引擎快速解析（离线可用）
  /// 作为 Kimi API 的备用方案
  ParseResult parseWithLocalRules(String text) {
    // 金额提取
    final amount = _extractAmount(text);

    // 分类识别
    final categoryResult = _matchCategory(text);

    // 类型判断
    final type = _detectType(text, categoryResult['isIncome'] as bool);

    return ParseResult(
      amount: amount,
      type: type,
      category: categoryResult['category'] as String?,
      note: text,
      confidence: amount != null ? 0.8 : 0.3,
      rawText: text,
    );
  }

  /// 提取金额
  double? _extractAmount(String text) {
    // 匹配 "35", "35块", "35元", "35.5", "35块5", "三十五"
    final patterns = [
      RegExp(r'(\d+)块5'),      // 35块5 -> 35.5
      RegExp(r'(\d+)块(\d+)'), // 35块5 -> 35.5
      RegExp(r'(\d+\.\d+)'),   // 35.5
      RegExp(r'(\d+)'),         // 35
    ];

    for (final pattern in patterns) {
      final match = pattern.firstMatch(text);
      if (match != null) {
        if (match.groupCount >= 2) {
          final integer = match.group(1);
          final decimal = match.group(2);
          return double.parse('$integer.$decimal');
        } else {
          return double.tryParse(match.group(1)!);
        }
      }
    }

    return null;
  }

  /// 匹配分类
  Map<String, dynamic> _matchCategory(String text) {
    for (final category in AppConfig.defaultCategories) {
      final keywords = category['keywords'] as List<String>;
      for (final keyword in keywords) {
        if (text.contains(keyword)) {
          return {
            'category': category['name'],
            'type': category['type'],
            'isIncome': (category['type'] as int) == 1,
          };
        }
      }
    }

    // 默认返回
    return {
      'category': null,
      'type': 0,
      'isIncome': false,
    };
  }

  /// 检测类型
  BillType _detectType(String text, bool isIncomeCategory) {
    final expenseKeywords = ['花了', '付了', '买了', '支出', '消费', '花费'];
    final incomeKeywords = ['发了', '赚了', '收到', '工资', '奖金', '收入', '赚'];

    for (final keyword in incomeKeywords) {
      if (text.contains(keyword)) return BillType.income;
    }

    for (final keyword in expenseKeywords) {
      if (text.contains(keyword)) return BillType.expense;
    }

    return isIncomeCategory ? BillType.income : BillType.expense;
  }
}

/// 解析结果
class ParseResult {
  final double? amount;
  final BillType type;
  final String? category;
  final String? note;
  final double confidence;
  final String rawText;

  ParseResult({
    this.amount,
    required this.type,
    this.category,
    this.note,
    required this.confidence,
    required this.rawText,
  });

  bool get isValid => amount != null && amount! > 0 && category != null;

  @override
  String toString() {
    return 'ParseResult(amount: $amount, type: $type, category: $category, confidence: $confidence)';
  }
}
