import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../core/theme/meizu_theme.dart';
import '../../../services/kimi_service.dart';
import '../../../services/voice_service.dart';

/// 语音记账按钮
/// 按住说话，松开后自动识别并解析
class VoiceButton extends StatefulWidget {
  final Function(ParseResult result) onResult;

  const VoiceButton({
    super.key,
    required this.onResult,
  });

  @override
  State<VoiceButton> createState() => _VoiceButtonState();
}

class _VoiceButtonState extends State<VoiceButton>
    with SingleTickerProviderStateMixin {
  final VoiceService _voiceService = VoiceService();
  late AnimationController _animationController;
  bool _isPressed = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );

    // 监听识别状态
    _voiceService.stateStream.listen((state) {
      if (state == VoiceRecognitionState.success) {
        _showSuccessFeedback();
      } else if (state == VoiceRecognitionState.error) {
        _showErrorFeedback();
      }
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    _voiceService.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<VoiceRecognitionState>(
      stream: _voiceService.stateStream,
      initialData: VoiceRecognitionState.idle,
      builder: (context, snapshot) {
        final state = snapshot.data!;

        return GestureDetector(
          onTapDown: (_) => _onTapDown(),
          onTapUp: (_) => _onTapUp(),
          onTapCancel: () => _onTapCancel(),
          child: AnimatedContainer(
            duration: MeizuTheme.animationFast,
            transform: Matrix4.identity()
              ..scale(_isPressed ? 1.1 : 1.0),
            child: Container(
              width: 200,
              height: 56,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: state == VoiceRecognitionState.listening
                      ? [MeizuTheme.expenseRed, MeizuTheme.expenseRed.withOpacity(0.8)]
                      : [MeizuTheme.meizuBlue, MeizuTheme.meizuBlue.withOpacity(0.8)],
                ),
                borderRadius: BorderRadius.circular(MeizuTheme.radiusCircular),
                boxShadow: [
                  BoxShadow(
                    color: (state == VoiceRecognitionState.listening
                            ? MeizuTheme.expenseRed
                            : MeizuTheme.meizuBlue)
                        .withOpacity(0.3),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildIcon(state),
                  const SizedBox(width: MeizuTheme.spaceSmall),
                  Text(
                    _getButtonText(state),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildIcon(VoiceRecognitionState state) {
    switch (state) {
      case VoiceRecognitionState.listening:
        return _buildWaveAnimation();
      case VoiceRecognitionState.processing:
        return const SizedBox(
          width: 20,
          height: 20,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            valueColor: AlwaysStoppedAnimation(Colors.white),
          ),
        );
      case VoiceRecognitionState.success:
        return const Icon(Icons.check, color: Colors.white);
      case VoiceRecognitionState.error:
        return const Icon(Icons.error_outline, color: Colors.white);
      default:
        return const Icon(Icons.mic, color: Colors.white);
    }
  }

  Widget _buildWaveAnimation() {
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return Stack(
          alignment: Alignment.center,
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.3),
                shape: BoxShape.circle,
              ),
            ),
            Container(
              width: 30 + _animationController.value * 10,
              height: 30 + _animationController.value * 10,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
            ),
            const Icon(Icons.mic, color: Colors.white),
          ],
        );
      },
    );
  }

  String _getButtonText(VoiceRecognitionState state) {
    switch (state) {
      case VoiceRecognitionState.listening:
        return '正在听...';
      case VoiceRecognitionState.processing:
        return '解析中...';
      case VoiceRecognitionState.success:
        return '识别成功';
      case VoiceRecognitionState.error:
        return '请重试';
      default:
        return '按住说话记账';
    }
  }

  void _onTapDown() {
    setState(() => _isPressed = true);
    HapticFeedback.mediumImpact();
    _animationController.repeat(reverse: true);
    _voiceService.startRecognition().then((result) {
      if (result != null && result.isValid) {
        widget.onResult(result);
      }
    });
  }

  void _onTapUp() {
    setState(() => _isPressed = false);
    _animationController.stop();
    _voiceService.stopRecognition();
  }

  void _onTapCancel() {
    setState(() => _isPressed = false);
    _animationController.stop();
    _voiceService.cancelRecognition();
  }

  void _showSuccessFeedback() {
    HapticFeedback.lightImpact();
    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) {
        _voiceService.cancelRecognition();
      }
    });
  }

  void _showErrorFeedback() {
    HapticFeedback.vibrate();
    Future.delayed(const Duration(milliseconds: 1000), () {
      if (mounted) {
        _voiceService.cancelRecognition();
      }
    });
  }
}

/// 语音结果预览对话框
class VoiceResultPreview extends StatelessWidget {
  final ParseResult result;
  final VoidCallback onConfirm;
  final VoidCallback onCancel;

  const VoiceResultPreview({
    super.key,
    required this.result,
    required this.onConfirm,
    required this.onCancel,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.all(MeizuTheme.spaceMedium),
      padding: const EdgeInsets.all(MeizuTheme.spaceLarge),
      decoration: BoxDecoration(
        color: isDark ? MeizuTheme.cardDark : MeizuTheme.cardWhite,
        borderRadius: BorderRadius.circular(MeizuTheme.radiusXLarge),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // 识别文本
          Text(
            '"${result.rawText}"',
            style: const TextStyle(
              fontSize: 16,
              fontStyle: FontStyle.italic,
              color: MeizuTheme.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: MeizuTheme.spaceLarge),
          // 解析结果
          Container(
            padding: const EdgeInsets.all(MeizuTheme.spaceMedium),
            decoration: BoxDecoration(
              color: MeizuTheme.background,
              borderRadius: BorderRadius.circular(MeizuTheme.radiusMedium),
            ),
            child: Column(
              children: [
                _buildResultRow('金额', '¥${result.amount?.toStringAsFixed(2)}'),
                const SizedBox(height: MeizuTheme.spaceSmall),
                _buildResultRow('分类', result.category ?? '其他'),
                const SizedBox(height: MeizuTheme.spaceSmall),
                _buildResultRow(
                  '类型',
                  result.type.name == 'income' ? '收入' : '支出',
                ),
              ],
            ),
          ),
          const SizedBox(height: MeizuTheme.spaceLarge),
          // 置信度
          Text(
            '置信度: ${(result.confidence * 100).toStringAsFixed(0)}%',
            style: const TextStyle(
              fontSize: 12,
              color: MeizuTheme.textTertiary,
            ),
          ),
          const SizedBox(height: MeizuTheme.spaceLarge),
          // 按钮
          Row(
            children: [
              Expanded(
                child: TextButton(
                  onPressed: onCancel,
                  child: const Text('取消'),
                ),
              ),
              const SizedBox(width: MeizuTheme.spaceMedium),
              Expanded(
                child: ElevatedButton(
                  onPressed: onConfirm,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: MeizuTheme.meizuBlue,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(MeizuTheme.radiusMedium),
                    ),
                  ),
                  child: const Text('确认记账'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildResultRow(String label, String? value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            color: MeizuTheme.textSecondary,
          ),
        ),
        Text(
          value ?? '-',
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: MeizuTheme.textPrimary,
          ),
        ),
      ],
    );
  }
}
