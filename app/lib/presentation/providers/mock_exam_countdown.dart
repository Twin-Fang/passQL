/// 모의고사 남은 시간: 서버가 준 남은 초 + 받은 뒤 흐른 단조 시간 (기기 시각을 바꿔도 영향 없음)
/// [elapsedSinceSync] 는 Stopwatch 처럼 기기 시각과 무관한 경과 시간
class MockExamCountdown {
  MockExamCountdown({
    required this.remainingSecondsAtSync,
    required this.elapsedSinceSync,
  });

  final int remainingSecondsAtSync;
  final Duration Function() elapsedSinceSync;

  /// 지금 남은 초 (0 이상)
  int get remainingSeconds {
    final remaining = remainingSecondsAtSync - elapsedSinceSync().inSeconds;
    return remaining < 0 ? 0 : remaining;
  }

  bool get isTimeUp => remainingSeconds == 0;

  /// 0초를 지난 시간 (초, 자동 제출을 서버 마감 뒤로 미루는 판정용)
  int get secondsPastDeadline {
    final overdue = elapsedSinceSync().inSeconds - remainingSecondsAtSync;
    return overdue < 0 ? 0 : overdue;
  }
}

/// 남은 초 > 'mm:ss' (1시간 이상이면 'h:mm:ss')
String formatMockExamRemaining(int remainingSeconds) {
  final hours = remainingSeconds ~/ 3600;
  final minutes = (remainingSeconds % 3600) ~/ 60;
  final seconds = remainingSeconds % 60;
  final minuteText = minutes.toString().padLeft(2, '0');
  final secondText = seconds.toString().padLeft(2, '0');
  return hours > 0
      ? '$hours:$minuteText:$secondText'
      : '$minuteText:$secondText';
}

/// 남은 시간 경고 단계: 넉넉, 10분 이하 주의, 5분 이하 임박
enum MockExamTimeLevel { relaxed, caution, urgent }

// 주의 시작 (초, 10분)
const int mockExamCautionSeconds = 600;
// 임박 시작 (초, 5분)
const int mockExamUrgentSeconds = 300;

MockExamTimeLevel mockExamTimeLevelOf(int remainingSeconds) {
  if (remainingSeconds <= mockExamUrgentSeconds) {
    return MockExamTimeLevel.urgent;
  }
  if (remainingSeconds <= mockExamCautionSeconds) {
    return MockExamTimeLevel.caution;
  }
  return MockExamTimeLevel.relaxed;
}

/// 스크린리더 알림 시점 (남은 분: 30·10·5·1분)
const List<int> mockExamAnnounceMinutes = [30, 10, 5, 1];

/// 자동 제출 지연 (초): 기기 0초는 서버 마감보다 통신 시간만큼 이르므로 마감 뒤에 도착하게
const int mockExamAutoSubmitDelaySeconds = 2;
