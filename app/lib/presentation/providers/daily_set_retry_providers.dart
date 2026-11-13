import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/utils/app_clock.dart';
import 'session_reset.dart';

/// 오늘의 세트 다시 풀기에서 맞힌 문제 기록 (#1035): 날짜 + 문제 uuid 묶음
/// 세트 점수·순위·보너스는 바꾸지 않고, 결과 화면 표시(맞힘)와 남은 오답 수에만 씀
class DailySetRetryRecord {
  const DailySetRetryRecord({
    required this.dateKey,
    required this.correctQuestionUuids,
  });

  /// 기록한 날짜 (yyyy-MM-dd, 날이 바뀌면 지난 기록은 무시)
  final String dateKey;

  /// 다시 풀어 맞힌 문제 uuid
  final Set<String> correctQuestionUuids;

  static const DailySetRetryRecord empty = DailySetRetryRecord(
    dateKey: '',
    correctQuestionUuids: {},
  );
}

/// 앱 시각 기준 오늘 날짜 키 (yyyy-MM-dd)
String todayDateKey() {
  final now = AppClock.now();
  final month = now.month.toString().padLeft(2, '0');
  final day = now.day.toString().padLeft(2, '0');
  return '${now.year}-$month-$day';
}

/// 다시 풀기 맞힘 기록 (회원이 바뀌면 비움, 앱 실행 동안만 메모리에 둠)
class DailySetRetryNotifier extends Notifier<DailySetRetryRecord> {
  @override
  DailySetRetryRecord build() {
    ref.watch(currentMemberUuidProvider);
    return DailySetRetryRecord.empty;
  }

  /// 다시 풀기 결과 반영: 맞힌 문제 추가, 다시 틀린 문제 제외 (날이 바뀌었으면 새로 시작)
  void recordResults(Map<String, bool> isCorrectByQuestionUuid) {
    final today = todayDateKey();
    final correctQuestionUuids = state.dateKey == today
        ? {...state.correctQuestionUuids}
        : <String>{};
    for (final entry in isCorrectByQuestionUuid.entries) {
      if (entry.value) {
        correctQuestionUuids.add(entry.key);
      } else {
        correctQuestionUuids.remove(entry.key);
      }
    }
    state = DailySetRetryRecord(
      dateKey: today,
      correctQuestionUuids: correctQuestionUuids,
    );
  }
}

final dailySetRetryProvider =
    NotifierProvider<DailySetRetryNotifier, DailySetRetryRecord>(
      DailySetRetryNotifier.new,
    );

/// 오늘 다시 풀어 맞힌 문제 uuid (지난 날 기록이면 빈 묶음)
final dailySetRetriedCorrectUuidsProvider = Provider<Set<String>>((ref) {
  final record = ref.watch(dailySetRetryProvider);
  return record.dateKey == todayDateKey()
      ? record.correctQuestionUuids
      : const {};
});
