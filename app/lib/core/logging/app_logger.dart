import 'dart:async';
import 'dart:typed_data';

import 'app_log_file_store.dart';
import 'app_log_masker.dart';

/// 앱 로그 진입점: 마스킹 > 메모리 버퍼 > 주기 flush 로 파일 기록
/// start 전 호출은 무시 (초기화 순서 안전), UI 의존 없음
abstract final class AppLogger {
  // 버퍼 비우기 주기 (2초)
  static const Duration _flushInterval = Duration(seconds: 2);
  // 오류 스택 최대 줄 수
  static const int _maxStackLines = 20;
  // 기록 1건 최대 길이 (2KB)
  static const int _maxMessageLength = 2048;
  static const String _truncatedSuffix = '…(truncated)';

  static AppLogFileStore? _store;
  static Timer? _flushTimer;
  static final List<String> _bufferedLines = [];
  static Future<void> _pendingFlush = Future.value();

  static Future<void> start(AppLogFileStore store) async {
    _flushTimer?.cancel();
    _store = store;
    _flushTimer = Timer.periodic(_flushInterval, (_) => flush());
  }

  static void info(String tag, String message) => _record('I', tag, message);

  static void warn(String tag, String message) => _record('W', tag, message);

  /// 오류 + 스택 최대 20줄, 기록 직후 flush (비정상 종료 대비)
  static void error(String tag, Object error, StackTrace? stackTrace) {
    final stackLines = stackTrace
        ?.toString()
        .trimRight()
        .split('\n')
        .take(_maxStackLines);
    final message = [error.toString(), ...?stackLines].join('\n');
    _record('E', tag, message);
    flush();
  }

  /// 버퍼 > 파일 (직렬화: 이전 flush 끝난 뒤 실행)
  static Future<void> flush() {
    final store = _store;
    if (store == null || _bufferedLines.isEmpty) return _pendingFlush;
    final lines = List<String>.of(_bufferedLines);
    _bufferedLines.clear();
    _pendingFlush = _pendingFlush.then((_) async {
      try {
        await store.append(lines);
      } catch (_) {
        // 로그 기록 실패가 앱 동작에 영향 주지 않도록 삼킴
      }
    });
    return _pendingFlush;
  }

  static Future<Uint8List?> readGzippedLog() async {
    final store = _store;
    if (store == null) return null;
    await flush();
    return store.readAllGzipped();
  }

  static Future<int> currentLogBytes() async {
    final store = _store;
    if (store == null) return 0;
    await flush();
    return store.totalBytes();
  }

  static Future<void> clear() async {
    final store = _store;
    if (store == null) return;
    _bufferedLines.clear();
    await _pendingFlush;
    await store.clear();
  }

  static void _record(String levelCode, String tag, String message) {
    if (_store == null) return;
    final cappedMessage = message.length > _maxMessageLength
        ? '${message.substring(0, _maxMessageLength)}$_truncatedSuffix'
        : message;
    final line =
        '${_formatTimestamp(DateTime.now())} $levelCode [$tag] $cappedMessage';
    _bufferedLines.add(AppLogMasker.mask(line));
  }

  // ISO8601 + 로컬 오프셋 (2026-10-27T09:00:00.000+09:00)
  static String _formatTimestamp(DateTime moment) {
    final offset = moment.timeZoneOffset;
    final sign = offset.isNegative ? '-' : '+';
    final hours = offset.inHours.abs().toString().padLeft(2, '0');
    final minutes = (offset.inMinutes.abs() % 60).toString().padLeft(2, '0');
    final local = moment.toIso8601String();
    return '$local$sign$hours:$minutes';
  }
}
