import 'package:intl/intl.dart';

/// 日期工具类
class DateUtil {
  static final DateFormat _dateFormat = DateFormat('yyyy-MM-dd');
  static final DateFormat _timeFormat = DateFormat('HH:mm');
  static final DateFormat _dateTimeFormat = DateFormat('yyyy-MM-dd HH:mm');
  static final DateFormat _monthFormat = DateFormat('yyyy年M月');
  static final DateFormat _dayFormat = DateFormat('M月d日');
  static final DateFormat _weekdayFormat = DateFormat('EEEE', 'zh_CN');

  /// 格式化日期 yyyy-MM-dd
  static String formatDate(DateTime date) {
    return _dateFormat.format(date);
  }

  /// 格式化时间 HH:mm
  static String formatTime(DateTime date) {
    return _timeFormat.format(date);
  }

  /// 格式化日期时间 yyyy-MM-dd HH:mm
  static String formatDateTime(DateTime date) {
    return _dateTimeFormat.format(date);
  }

  /// 格式化为月份 yyyy年M月
  static String formatMonth(DateTime date) {
    return _monthFormat.format(date);
  }

  /// 格式化为月日 M月d日
  static String formatDay(DateTime date) {
    return _dayFormat.format(date);
  }

  /// 获取星期几
  static String getWeekday(DateTime date) {
    return _weekdayFormat.format(date);
  }

  /// 获取简洁的星期几（周一、周二...）
  static String getShortWeekday(DateTime date) {
    final weekdays = ['', '周一', '周二', '周三', '周四', '周五', '周六', '周日'];
    return weekdays[date.weekday];
  }

  /// 获取今天的开始时间
  static DateTime getStartOfDay(DateTime date) {
    return DateTime(date.year, date.month, date.day);
  }

  /// 获取今天的结束时间
  static DateTime getEndOfDay(DateTime date) {
    return DateTime(date.year, date.month, date.day, 23, 59, 59, 999);
  }

  /// 获取本周的开始（周一）
  static DateTime getStartOfWeek(DateTime date) {
    return date.subtract(Duration(days: date.weekday - 1));
  }

  /// 获取本周的结束（周日）
  static DateTime getEndOfWeek(DateTime date) {
    return date.add(Duration(days: 7 - date.weekday));
  }

  /// 获取本月的开始
  static DateTime getStartOfMonth(int year, int month) {
    return DateTime(year, month, 1);
  }

  /// 获取本月的结束
  static DateTime getEndOfMonth(int year, int month) {
    return DateTime(year, month + 1, 0, 23, 59, 59, 999);
  }

  /// 获取某月的天数
  static int getDaysInMonth(int year, int month) {
    return DateTime(year, month + 1, 0).day;
  }

  /// 获取相对时间描述
  static String getRelativeTime(DateTime date) {
    final now = DateTime.now();
    final today = getStartOfDay(now);
    final yesterday = today.subtract(const Duration(days: 1));
    final dateStart = getStartOfDay(date);

    if (dateStart == today) {
      return '今天';
    } else if (dateStart == yesterday) {
      return '昨天';
    } else if (now.difference(date).inDays < 7) {
      return getShortWeekday(date);
    } else {
      return formatDay(date);
    }
  }

  /// 获取日期间的间隔天数
  static int daysBetween(DateTime from, DateTime to) {
    from = getStartOfDay(from);
    to = getStartOfDay(to);
    return (to.difference(from).inHours / 24).round();
  }

  /// 获取某月所有日期列表
  static List<DateTime> getDaysInMonthList(int year, int month) {
    final daysCount = getDaysInMonth(year, month);
    return List.generate(
      daysCount,
      (index) => DateTime(year, month, index + 1),
    );
  }

  /// 判断两个日期是否为同一天
  static bool isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  /// 判断是否为今天
  static bool isToday(DateTime date) {
    return isSameDay(date, DateTime.now());
  }
}
