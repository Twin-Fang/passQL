import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/diagnostics/app_diagnostics_collector.dart';
import '../../core/error/app_exception.dart';
import '../../core/error/error_code.dart';
import '../../core/logging/app_logger.dart';
import '../../core/monitoring/app_analytics.dart';
import '../../core/network/api_call.dart';
import '../../core/push/push_messaging_client.dart';
import '../../core/validation/feedback_validator.dart';
import '../../data/image/webp_image_compressor.dart';
import '../../data/sources/api_providers.dart';
import 'auth_provider.dart';
import 'plan_providers.dart';
import 'settings_providers.dart';
import 'theme_mode_provider.dart';

/// 진단 정보 수집기: 현재 세션·구독·화면 모드·선택지 모드·푸시 포트로 조립
final appDiagnosticsCollectorProvider =
    Provider.autoDispose<AppDiagnosticsCollector>((ref) {
      final session = ref.watch(authProvider).valueOrNull;
      return AppDiagnosticsCollector(
        memberUuid: session?.memberUuid,
        authProvider: session?.authProvider?.serverValue,
        isPro: ref.watch(isProProvider),
        themeMode: ref.watch(themeModeProvider).name,
        choiceMode: ref.watch(choiceModeProvider).valueOrNull?.serverValue,
        pushMessagingClient: PushMessagingClient.current,
      );
    });

// 로그 파트 파일명 (서버 키 app-log.txt.gz 와 같은 이름)
const _logFileName = 'app-log.txt.gz';

/// 의견 전송: 검증 > multipart 조립(본문, 사진, 진단 정보, 로그) > 전송 > 분석 이벤트
class FeedbackSubmitter {
  FeedbackSubmitter(this._ref);

  final Ref _ref;

  /// 서버가 거절하거나 네트워크가 실패하면 [AppException] 을 던진다.
  Future<void> submit({
    required String rawContent,
    required List<CompressedWebpImage> images,
    required bool shouldIncludeDiagnostics,
    required Map<String, Object?>? diagnostics,
  }) async {
    // 본문 검증 (공백 제거, 1~500자)
    final content = FeedbackValidator.normalize(rawContent);
    if (!FeedbackValidator.isValid(content)) {
      throw const AppException(
        code: ErrorCode.validation,
        message: '내용을 1자 이상 500자 이하로 입력해 주세요.',
      );
    }
    final formData = await _buildFormData(
      content: content,
      images: images,
      shouldIncludeDiagnostics: shouldIncludeDiagnostics,
      diagnostics: diagnostics,
    );
    await callApiThrowingAppException(
      _ref.read(feedbackApiProvider).submit(formData),
    );
    _ref.read(appAnalyticsProvider).logFeedbackSent();
  }

  Future<FormData> _buildFormData({
    required String content,
    required List<CompressedWebpImage> images,
    required bool shouldIncludeDiagnostics,
    required Map<String, Object?>? diagnostics,
  }) async {
    // 진단 정보 + 로그는 체크했을 때만 (flush 후 읽음, 로그 없으면 파트 생략)
    Uint8List? gzippedLog;
    if (shouldIncludeDiagnostics) {
      await AppLogger.flush();
      gzippedLog = await AppLogger.readGzippedLog();
    }
    return buildFeedbackFormData(
      content: content,
      images: images,
      diagnostics: shouldIncludeDiagnostics ? diagnostics : null,
      gzippedLog: gzippedLog,
    );
  }
}

/// 의견 multipart 조립: request > images × n > diagnostics > log (없는 파트는 생략)
/// 모든 파트에 파일명을 둠 (서버가 파일명 있는 파트만 MultipartFile 로 인식)
FormData buildFeedbackFormData({
  required String content,
  required List<CompressedWebpImage> images,
  Map<String, Object?>? diagnostics,
  Uint8List? gzippedLog,
}) {
  MultipartFile jsonPart(Map<String, Object?> json, String filename) =>
      MultipartFile.fromString(
        jsonEncode(json),
        filename: filename,
        contentType: DioMediaType('application', 'json'),
      );
  final formData = FormData();
  formData.files.add(
    MapEntry(
      'request',
      jsonPart(<String, Object?>{'content': content}, 'request.json'),
    ),
  );
  for (var index = 0; index < images.length; index++) {
    formData.files.add(
      MapEntry(
        'images',
        MultipartFile.fromBytes(
          images[index].bytes,
          filename: '$index.webp',
          contentType: DioMediaType('image', 'webp'),
        ),
      ),
    );
  }
  if (diagnostics != null) {
    formData.files.add(
      MapEntry('diagnostics', jsonPart(diagnostics, 'diagnostics.json')),
    );
  }
  if (gzippedLog != null) {
    formData.files.add(
      MapEntry(
        'log',
        MultipartFile.fromBytes(
          gzippedLog,
          filename: _logFileName,
          contentType: DioMediaType('application', 'gzip'),
        ),
      ),
    );
  }
  return formData;
}

final feedbackSubmitterProvider = Provider<FeedbackSubmitter>(
  FeedbackSubmitter.new,
);
