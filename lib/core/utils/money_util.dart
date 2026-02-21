import 'package:intl/intl.dart';

/// 金额工具类
class MoneyUtil {
  static final NumberFormat _currencyFormat = NumberFormat('#,##0.00');
  static final NumberFormat _compactFormat = NumberFormat.compact();
  static final NumberFormat _intFormat = NumberFormat('#,##0');

  /// 将分转换为元（double）
  static double fenToYuan(int fen) {
    return fen / 100.0;
  }

  /// 将元转换为分（int）
  static int yuanToFen(double yuan) {
    return (yuan * 100).round();
  }

  /// 格式化金额为货币格式 ¥1,234.56
  static String formatMoney(int fen, {bool showSymbol = true}) {
    final yuan = fenToYuan(fen);
    final formatted = _currencyFormat.format(yuan);
    return showSymbol ? '¥$formatted' : formatted;
  }

  /// 格式化金额，不保留小数（当小数部分为0时）
  static String formatMoneySmart(int fen, {bool showSymbol = true}) {
    final yuan = fenToYuan(fen);
    if (yuan == yuan.roundToDouble()) {
      final formatted = _intFormat.format(yuan.toInt());
      return showSymbol ? '¥$formatted' : formatted;
    } else {
      final formatted = _currencyFormat.format(yuan);
      return showSymbol ? '¥$formatted' : formatted;
    }
  }

  /// 格式化大数字为简短形式（如 1.2万）
  static String formatCompact(int fen) {
    final yuan = fenToYuan(fen);
    if (yuan >= 10000) {
      return '${_compactFormat.format(yuan / 10000)}万';
    }
    return _currencyFormat.format(yuan);
  }

  /// 格式化金额为仅显示整数部分
  static String formatInt(int fen, {bool showSymbol = true}) {
    final yuan = fenToYuan(fen).toInt();
    final formatted = _intFormat.format(yuan);
    return showSymbol ? '¥$formatted' : formatted;
  }

  /// 获取金额的颜色（收入绿色，支出红色）
  static int getAmountColor(int fen, {bool isIncome = false}) {
    if (fen == 0) return 0xFF999999;
    return isIncome ? 0xFF4CAF50 : 0xFFFF6B6B;
  }

  /// 格式化输入金额为显示字符串（用于记账输入）
  /// 自动处理最后两位为小数
  static String formatInputAmount(String input) {
    if (input.isEmpty) return '0.00';

    // 移除前导零
    input = input.replaceFirst(RegExp(r'^0+'), '');
    if (input.isEmpty) return '0.00';

    // 处理长度
    if (input.length == 1) {
      return '0.0$input';
    } else if (input.length == 2) {
      return '0.$input';
    } else {
      final integerPart = input.substring(0, input.length - 2);
      final decimalPart = input.substring(input.length - 2);
      return '$integerPart.$decimalPart';
    }
  }

  /// 解析输入字符串为分
  static int parseInputToFen(String input) {
    if (input.isEmpty) return 0;

    try {
      // 移除小数点，作为整数处理
      final cleanInput = input.replaceAll('.', '');
      return int.parse(cleanInput);
    } catch (e) {
      return 0;
    }
  }

  /// 格式化百分比
  static String formatPercent(double value, {int decimals = 1}) {
    final format = NumberFormat.decimalPattern()
      ..minimumFractionDigits = decimals
      ..maximumFractionDigits = decimals;
    return '${format.format(value)}%';
  }

  /// 计算环比百分比
  static double? calculateMoM(int current, int previous) {
    if (previous == 0) return null;
    return ((current - previous) / previous) * 100;
  }

  /// 格式化环比显示
  static String formatMoM(double? percent) {
    if (percent == null) return '-';
    final sign = percent >= 0 ? '+' : '';
    return '$sign${percent.toStringAsFixed(1)}%';
  }
}
