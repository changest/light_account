import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import '../core/constants/app_config.dart';
import 'kimi_service.dart';

/// 语音识别状态
enum VoiceRecognitionState {
  idle,       // 空闲
  listening,  // 正在监听
  processing, // 处理中
  success,    // 成功
  error,      // 错误
}

/// 语音服务
/// 管理语音识别流程
class VoiceService {
  static final VoiceService _instance = VoiceService._internal();
  factory VoiceService() => _instance;
  VoiceService._internal();

  final _kimiService = KimiService();

  // 状态流
  final _stateController = StreamController<VoiceRecognitionState>.broadcast();
  Stream<VoiceRecognitionState> get stateStream => _stateController.stream;

  // 识别结果流
  final _resultController = StreamController<ParseResult?>.broadcast();
  Stream<ParseResult?> get resultStream => _resultController.stream;

  VoiceRecognitionState _currentState = VoiceRecognitionState.idle;
  VoiceRecognitionState get currentState => _currentState;

  String? _lastRecognizedText;
  String? get lastRecognizedText => _lastRecognizedText;

  /// 开始语音识别
  ///
  /// 返回识别结果，失败返回 null
  Future<ParseResult?> startRecognition() async {
    _updateState(VoiceRecognitionState.listening);

    try {
      // 模拟语音识别（实际项目中应使用 speech_to_text 插件）
      // 这里为了演示，返回一个模拟结果
      await Future.delayed(const Duration(seconds: 2));

      // 实际实现应该使用 speech_to_text
      // await _speechToText.listen(
      //   onResult: (result) {
      //     _lastRecognizedText = result.recognizedWords;
      //   },
      //   localeId: AppConfig.recordingLocaleId,
      // );

      // 模拟识别结果
      _lastRecognizedText = '中午吃饭花了三十五块';

      _updateState(VoiceRecognitionState.processing);

      // 使用 Kimi API 解析
      final result = await _parseWithKimi(_lastRecognizedText!);

      if (result != null) {
        _updateState(VoiceRecognitionState.success);
        _resultController.add(result);
        return result;
      } else {
        _updateState(VoiceRecognitionState.error);
        return null;
      }
    } catch (e) {
      _updateState(VoiceRecognitionState.error);
      return null;
    }
  }

  /// 停止语音识别
  void stopRecognition() {
    // 停止录音
    _updateState(VoiceRecognitionState.idle);
  }

  /// 取消语音识别
  void cancelRecognition() {
    _lastRecognizedText = null;
    _updateState(VoiceRecognitionState.idle);
  }

  /// 使用 Kimi 解析
  Future<ParseResult?> _parseWithKimi(String text) async {
    // 先尝试本地规则解析
    final localResult = _kimiService.parseWithLocalRules(text);

    // 如果本地解析成功，直接返回
    if (localResult.isValid && localResult.confidence > 0.7) {
      return localResult;
    }

    // 否则调用 Kimi API
    final kimiResult = await _kimiService.parseBillFromText(text);

    // 合并结果，优先使用 Kimi 的结果
    if (kimiResult != null && kimiResult.isValid) {
      return kimiResult;
    }

    // 如果 Kimi 失败但本地有结果，返回本地结果
    if (localResult.amount != null) {
      return localResult;
    }

    return null;
  }

  /// 更新状态
  void _updateState(VoiceRecognitionState state) {
    _currentState = state;
    _stateController.add(state);
  }

  /// 释放资源
  void dispose() {
    _stateController.close();
    _resultController.close();
  }
}

/// 语音账单结果
class VoiceBillResult {
  final String recognizedText;
  final double? amount;
  final String? category;
  final bool isIncome;
  final double confidence;

  VoiceBillResult({
    required this.recognizedText,
    this.amount,
    this.category,
    this.isIncome = false,
    this.confidence = 0.0,
  });

  bool get isValid => amount != null && amount! > 0 && category != null;
}
