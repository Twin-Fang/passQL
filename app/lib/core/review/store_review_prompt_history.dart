import '../storage/device_preferences.dart';
import '../storage/storage_keys.dart';

/// 스토어 평가 요청 기록 6개: 첫 학습 완료 시각, 마지막 학습 완료 시각, 학습한 날 수, 학습 완료 횟수,
/// 마지막 요청 시각, 마지막 요청 앱 버전 (시각은 epoch 밀리초, 기기 단위)
class StoreReviewPromptHistory {
  const StoreReviewPromptHistory({
    this.firstStudyCompletedAtEpochMilliseconds,
    this.lastStudyCompletedAtEpochMilliseconds,
    this.studyDayCount = 0,
    this.completedStudyCount = 0,
    this.lastRequestedAtEpochMilliseconds,
    this.lastRequestedAppVersion,
  });

  /// 기록 시작 시각 (첫 학습 완료, 첫날 판정 기준)
  final int? firstStudyCompletedAtEpochMilliseconds;
  final int? lastStudyCompletedAtEpochMilliseconds;

  /// 학습을 완료한 서로 다른 날 수 (기기 현지 날짜)
  final int studyDayCount;

  /// 오늘의 세트·모의고사를 끝낸 누적 횟수 (결과 좋고 나쁨 무관)
  final int completedStudyCount;
  final int? lastRequestedAtEpochMilliseconds;

  /// 마지막으로 요청한 앱 버전 (x.y.z)
  final String? lastRequestedAppVersion;

  /// 학습 완료 1회 반영: 횟수 +1, 처음이거나 날짜가 바뀌었으면 학습한 날 +1
  StoreReviewPromptHistory recordStudyCompletedAt(DateTime now) {
    final lastCompletedAt = lastStudyCompletedAtEpochMilliseconds;
    final isNewStudyDay =
        lastCompletedAt == null ||
        !isSameLocalDay(
          DateTime.fromMillisecondsSinceEpoch(lastCompletedAt),
          now,
        );
    return StoreReviewPromptHistory(
      firstStudyCompletedAtEpochMilliseconds:
          firstStudyCompletedAtEpochMilliseconds ?? now.millisecondsSinceEpoch,
      lastStudyCompletedAtEpochMilliseconds: now.millisecondsSinceEpoch,
      studyDayCount: isNewStudyDay ? studyDayCount + 1 : studyDayCount,
      completedStudyCount: completedStudyCount + 1,
      lastRequestedAtEpochMilliseconds: lastRequestedAtEpochMilliseconds,
      lastRequestedAppVersion: lastRequestedAppVersion,
    );
  }

  /// 평가 요청 1회 반영 (요청 시각·앱 버전)
  StoreReviewPromptHistory recordRequestedAt(DateTime now, String appVersion) =>
      StoreReviewPromptHistory(
        firstStudyCompletedAtEpochMilliseconds:
            firstStudyCompletedAtEpochMilliseconds,
        lastStudyCompletedAtEpochMilliseconds:
            lastStudyCompletedAtEpochMilliseconds,
        studyDayCount: studyDayCount,
        completedStudyCount: completedStudyCount,
        lastRequestedAtEpochMilliseconds: now.millisecondsSinceEpoch,
        lastRequestedAppVersion: appVersion,
      );

  /// 두 시각이 기기 현지 날짜로 같은 날인지
  static bool isSameLocalDay(DateTime first, DateTime second) {
    final firstLocal = first.toLocal();
    final secondLocal = second.toLocal();
    return firstLocal.year == secondLocal.year &&
        firstLocal.month == secondLocal.month &&
        firstLocal.day == secondLocal.day;
  }
}

/// 평가 요청 기록 저장소 포트 (판정·기록 갱신과 저장 방식 분리)
abstract interface class StoreReviewPromptHistoryStore {
  Future<StoreReviewPromptHistory> read();
  Future<void> write(StoreReviewPromptHistory history);
}

/// SharedPreferences 저장소 (계정과 무관한 기기 단위 기록, 앱 삭제 시 초기화)
class SharedPreferencesStoreReviewPromptHistoryStore
    implements StoreReviewPromptHistoryStore {
  const SharedPreferencesStoreReviewPromptHistoryStore();

  @override
  Future<StoreReviewPromptHistory> read() async => StoreReviewPromptHistory(
    firstStudyCompletedAtEpochMilliseconds: await DevicePreferences.readInt(
      StorageKeys.storeReviewFirstStudyCompletedAt,
    ),
    lastStudyCompletedAtEpochMilliseconds: await DevicePreferences.readInt(
      StorageKeys.storeReviewLastStudyCompletedAt,
    ),
    studyDayCount:
        await DevicePreferences.readInt(StorageKeys.storeReviewStudyDayCount) ??
        0,
    completedStudyCount:
        await DevicePreferences.readInt(
          StorageKeys.storeReviewCompletedStudyCount,
        ) ??
        0,
    lastRequestedAtEpochMilliseconds: await DevicePreferences.readInt(
      StorageKeys.storeReviewLastRequestedAt,
    ),
    lastRequestedAppVersion: await DevicePreferences.readString(
      StorageKeys.storeReviewLastRequestedAppVersion,
    ),
  );

  @override
  Future<void> write(StoreReviewPromptHistory history) async {
    // null = 아직 기록 없음 > 쓰지 않음
    final firstCompletedAt = history.firstStudyCompletedAtEpochMilliseconds;
    final lastCompletedAt = history.lastStudyCompletedAtEpochMilliseconds;
    final lastRequestedAt = history.lastRequestedAtEpochMilliseconds;
    final lastRequestedAppVersion = history.lastRequestedAppVersion;
    if (firstCompletedAt != null) {
      await DevicePreferences.writeInt(
        StorageKeys.storeReviewFirstStudyCompletedAt,
        firstCompletedAt,
      );
    }
    if (lastCompletedAt != null) {
      await DevicePreferences.writeInt(
        StorageKeys.storeReviewLastStudyCompletedAt,
        lastCompletedAt,
      );
    }
    if (lastRequestedAt != null) {
      await DevicePreferences.writeInt(
        StorageKeys.storeReviewLastRequestedAt,
        lastRequestedAt,
      );
    }
    if (lastRequestedAppVersion != null) {
      await DevicePreferences.writeString(
        StorageKeys.storeReviewLastRequestedAppVersion,
        lastRequestedAppVersion,
      );
    }
    await DevicePreferences.writeInt(
      StorageKeys.storeReviewStudyDayCount,
      history.studyDayCount,
    );
    await DevicePreferences.writeInt(
      StorageKeys.storeReviewCompletedStudyCount,
      history.completedStudyCount,
    );
  }
}
