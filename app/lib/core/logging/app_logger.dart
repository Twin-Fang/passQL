import 'dart:async';
import 'dart:collection';
import 'dart:typed_data';

import '../config/app_build_flavor.dart';
import 'app_log_entry.dart';
import 'app_log_file_store.dart';
import 'app_log_masker.dart';

/// 앱 로그 진입점: 마스킹 > 메모리 버퍼 > 주기 flush 로 파일 기록 (+ 개발 빌드 최근 기록 200건)
/// start 전 호출은 무시 (초기화 순서 안전), UI 의존 없음
abstract final class AppLogger {
  // 버퍼 비우기 주기 (2초)
  static const Duration _flushInterval = Duration(seconds: 2);
  // 오류 스택 최대 줄 수
  static const int _maxStackLines = 20;
  // 기록 1건 최대 길이 (2KB)
  static const int _maxMessageLength = 2048;
  static const String _truncatedSuffix = '…(truncated)';
  // 개발자 도구 로그 보기용 최근 기록 개수 (#819, 넘치면 오래된 것부터 버림)
  static const int recentEntryCapacity = 200;

  static AppLogFileStore? _store;
  static Timer? _flushTimer;
  static final List<String> _bufferedLines = [];
  static final Queue<AppLogEntry> _recentEntries = ListQueue<AppLogEntry>();
  static Future<void> _pendingFlush = Future.value();

  static Future<void> start(AppLogFileStore store) async {
    _flushTimer?.cancel();
    _store = store;
    _flushTimer = Timer.periodic(_flushInterval, (_) => flush());
  }

  static void info(String tag, String message) =>
      _record(AppLogEntry.infoLevelCode, tag, message);

  static void warn(String tag, String message) =>
      _record(AppLogEntry.warnLevelCode, tag, message);

  /// 최근 기록 (오래된 것 > 최신 순, 개발 빌드만 쌓임)
  static List<AppLogEntry> get recentEntries =>
      List.unmodifiable(_recentEntries);

  /// 오류 + 스택 최대 20줄, 기록 직후 flush (비정상 종료 대비)
  static void error(String tag, Object error, StackTrace? stackTrace) {
    final stackLines = stackTrace
        ?.toString()
        .trimRight()
        .split('\n')
        .take(_maxStackLines);
    final message = [error.toString(), ...?stackLines].join('\n');
    _record(AppLogEntry.errorLevelCode, tag, message);
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
    _recentEntries.clear();
    try {
      await _pendingFlush;
      await store.clear();
    } catch (_) {
      // 로그 삭제 실패가 로그아웃·탈퇴를 막지 않도록 삼킴
    }
  }

  static void _record(String levelCode, String tag, String message) {
    if (_store == null) return;
    // 마스킹 먼저 (자르기 경계에 걸린 비밀값이 패턴을 피하지 않게) > 2KB 제한
    final maskedMessage = AppLogMasker.mask(message);
    final cappedMessage = maskedMessage.length > _maxMessageLength
        ? '${maskedMessage.substring(0, _maxMessageLength)}$_truncatedSuffix'
        : maskedMessage;
    final entry = AppLogEntry(
      recordedAt: DateTime.now(),
      levelCode: levelCode,
      tag: tag,
      message: cappedMessage,
    );
    _bufferedLines.add(entry.toLine());
    // 스토어 빌드는 상수 false > 최근 기록 없음
    if (AppBuildFlavor.canUseDevTools) _rememberRecent(entry);
  }

  /// 최근 기록 보관 (상한 넘으면 가장 오래된 것 제거)
  static void _rememberRecent(AppLogEntry entry) {
    _recentEntries.addLast(entry);
    if (_recentEntries.length > recentEntryCapacity) {
      _recentEntries.removeFirst();
    }
  }
}
