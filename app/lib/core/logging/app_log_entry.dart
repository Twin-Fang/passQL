import '../utils/date_format.dart';

/// 앱 로그 1건: 시각, 등급 코드, 태그, 마스킹된 내용
/// 파일 한 줄 형식: "{ISO 시각} {등급} [{태그}] {내용}"
class AppLogEntry {
  const AppLogEntry({
    required this.recordedAt,
    required this.levelCode,
    required this.tag,
    required this.message,
  });

  // 등급 코드 3종: I 정보, W 경고, E 오류
  static const String infoLevelCode = 'I';
  static const String warnLevelCode = 'W';
  static const String errorLevelCode = 'E';

  // API 호출 로그 태그 (AppLogInterceptor 기록, 개발자 도구 네트워크 오류 목록 기준)
  static const String apiTag = 'api';

  final DateTime recordedAt;
  final String levelCode;
  final String tag;
  final String message;

  /// API 호출 실패 기록인가 (인터셉터 onError 경고)
  bool get isApiFailure => levelCode == warnLevelCode && tag == apiTag;

  /// 파일·복사용 한 줄
  String toLine() =>
      '${formatIso8601WithOffset(recordedAt)} $levelCode [$tag] $message';
}
