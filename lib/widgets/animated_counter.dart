import 'package:flutter/material.dart';
import '../core/theme/meizu_theme.dart';
import '../core/utils/money_util.dart';

/// 动画数字计数器
/// 金额变化时数字滚动动画
class AnimatedCounter extends StatefulWidget {
  final int value;
  final Duration duration;
  final TextStyle? style;
  final bool showSymbol;
  final String? prefix;

  const AnimatedCounter({
    super.key,
    required this.value,
    this.duration = MeizuTheme.animationSlow,
    this.style,
    this.showSymbol = true,
    this.prefix,
  });

  @override
  State<AnimatedCounter> createState() => _AnimatedCounterState();
}

class _AnimatedCounterState extends State<AnimatedCounter>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  int _previousValue = 0;

  @override
  void initState() {
    super.initState();
    _previousValue = widget.value;
    _controller = AnimationController(
      duration: widget.duration,
      vsync: this,
    );
    _animation = CurvedAnimation(
      parent: _controller,
      curve: MeizuTheme.curveEaseOut,
    );
  }

  @override
  void didUpdateWidget(AnimatedCounter oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.value != widget.value) {
      _previousValue = oldWidget.value;
      _controller.reset();
      _controller.forward();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        final currentValue = _previousValue + (widget.value - _previousValue) * _animation.value;
        return Text(
          '${widget.prefix ?? ''}${MoneyUtil.formatMoney(currentValue.toInt(), showSymbol: widget.showSymbol)}',
          style: widget.style ?? MeizuTextStyles.amount,
        );
      },
    );
  }
}

/// 简单的数字滚动动画（用于单个数字）
class AnimatedDigit extends StatelessWidget {
  final int digit;
  final TextStyle? style;
  final Duration duration;

  const AnimatedDigit({
    super.key,
    required this.digit,
    this.style,
    this.duration = MeizuTheme.animationNormal,
  });

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<int>(
      tween: IntTween(begin: 0, end: digit),
      duration: duration,
      curve: MeizuTheme.curveEaseOut,
      builder: (context, value, child) {
        return Text(
          '$value',
          style: style,
        );
      },
    );
  }
}

/// 带增长指示器的金额显示
class AmountWithTrend extends StatelessWidget {
  final int amount;
  final double? percentChange;
  final bool showTrend;
  final TextStyle? style;

  const AmountWithTrend({
    super.key,
    required this.amount,
    this.percentChange,
    this.showTrend = true,
    this.style,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        AnimatedCounter(
          value: amount.abs(),
          style: style ?? MeizuTextStyles.amount,
        ),
        if (showTrend && percentChange != null) ...[
          const SizedBox(width: MeizuTheme.spaceSmall),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: MeizuTheme.spaceSmall,
              vertical: 2,
            ),
            decoration: BoxDecoration(
              color: percentChange! >= 0
                  ? MeizuTheme.incomeGreen.withOpacity(0.1)
                  : MeizuTheme.expenseRed.withOpacity(0.1),
              borderRadius: BorderRadius.circular(MeizuTheme.radiusSmall),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  percentChange! >= 0 ? Icons.trending_up : Icons.trending_down,
                  size: 12,
                  color: percentChange! >= 0 ? MeizuTheme.incomeGreen : MeizuTheme.expenseRed,
                ),
                const SizedBox(width: 2),
                Text(
                  '${percentChange!.abs().toStringAsFixed(1)}%',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: percentChange! >= 0 ? MeizuTheme.incomeGreen : MeizuTheme.expenseRed,
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }
}
