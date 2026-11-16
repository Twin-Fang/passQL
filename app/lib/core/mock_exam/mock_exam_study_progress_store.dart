import '../storage/device_preferences.dart';
import '../storage/storage_keys.dart';

/// 모의고사 학습 모드 기기 진도 (#1084): 회차별 푼 문항 정답 여부, 끝낸 회차 목록
/// 기기 단위 저장 (다른 기기·재설치는 처음부터)
abstract final class MockExamStudyProgressStore {
  // 정답 여부 문자 2개: 정답, 오답
  static const String _correctMark = '1';
  static const String _wrongMark = '0';
  // 끝낸 회차 uuid 구분자
  static const String _roundUuidDelimiter = ',';

  /// 회차 진도 > 앞에서부터 푼 문항 정답 여부 (없으면 빈 목록)
  static Future<List<bool>> readCorrectness(String roundUuid) async {
    final savedMarks = await DevicePreferences.readString(
      _progressKey(roundUuid),
    );
    if (savedMarks == null) return const [];
    return [for (final mark in savedMarks.split('')) mark == _correctMark];
  }

  /// 풀이마다 진도 저장 (지금까지 푼 문항 정답 여부 전체)
  static Future<void> saveCorrectness(
    String roundUuid,
    List<bool> correctness,
  ) => DevicePreferences.writeString(
    _progressKey(roundUuid),
    correctness
        .map((isCorrect) => isCorrect ? _correctMark : _wrongMark)
        .join(),
  );

  /// 50문항 끝: 진도 지움(다음엔 처음부터) > 끝낸 회차 목록에 추가
  static Future<void> markCompleted(String roundUuid) async {
    await DevicePreferences.remove(_progressKey(roundUuid));
    final completedRoundUuids = await readCompletedRoundUuids();
    if (completedRoundUuids.contains(roundUuid)) return;
    await DevicePreferences.writeString(
      StorageKeys.mockExamStudyCompletedRoundUuids,
      {...completedRoundUuids, roundUuid}.join(_roundUuidDelimiter),
    );
  }

  /// 학습 모드로 끝낸 회차 uuid 목록
  static Future<Set<String>> readCompletedRoundUuids() async {
    final saved = await DevicePreferences.readString(
      StorageKeys.mockExamStudyCompletedRoundUuids,
    );
    if (saved == null || saved.isEmpty) return const {};
    return saved.split(_roundUuidDelimiter).toSet();
  }

  static String _progressKey(String roundUuid) =>
      '${StorageKeys.mockExamStudyProgressPrefix}$roundUuid';
}
