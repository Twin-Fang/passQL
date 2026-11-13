import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/config/app_build_flavor.dart';
import '../../core/utils/app_clock.dart';
import '../../data/models/exam/exam_schedule_response.dart';

/// 시험일 흉내 5종 (#819): 시험 일정의 날짜만 바꿔 D-day 줄·이용권 문구 확인 (서버 일정 그대로)
enum DevExamDdaySimulation {
  none('끄기 (서버값)', null),
  twoWeeksLeft('D-14', 14),
  oneDayLeft('D-1', 1),
  examDay('시험 당일 (D-Day)', 0),
  examOver('시험 끝남 (D+1)', -1);

  const DevExamDdaySimulation(this.label, this.daysUntilExam);

  /// 개발자 도구 표시 이름
  final String label;

  /// 오늘(앱 시각)부터 시험일까지 일수 (null = 흉내 없음)
  final int? daysUntilExam;
}

final devExamDdaySimulationProvider =
    NotifierProvider<DevExamDdaySimulationNotifier, DevExamDdaySimulation>(
      DevExamDdaySimulationNotifier.new,
    );

class DevExamDdaySimulationNotifier extends Notifier<DevExamDdaySimulation> {
  @override
  DevExamDdaySimulation build() => DevExamDdaySimulation.none;

  /// 흉내 바꾸기 (운영 빌드는 무시)
  void select(DevExamDdaySimulation simulation) {
    if (!AppBuildFlavor.canUseDevTools) return;
    state = simulation;
  }
}

/// 잠금화면 강제 켜기 (#990): 서버 스위치가 꺼져도 설정 행·소개·홈 카드를 보이게 (출제 API·크레딧은 서버 그대로)
final devLockScreenForcedProvider =
    NotifierProvider<DevLockScreenForcedNotifier, bool>(
      DevLockScreenForcedNotifier.new,
    );

class DevLockScreenForcedNotifier extends Notifier<bool> {
  @override
  bool build() => false;

  /// 켜고 끄기 (운영 빌드는 무시)
  void toggle() {
    if (!AppBuildFlavor.canUseDevTools) return;
    state = !state;
  }
}

// 선택한 시험이 없을 때 흉내 일정 값 (서버에 없는 가짜 일정)
const String _simulatedExamScheduleUuid = 'dev-simulated-exam';
const String _simulatedCertType = 'SQLD';
const int _simulatedRound = 0;

/// 서버 시험 일정 > 시험일 흉내 반영 (일정이 없으면 가짜 SQLD 일정, 흉내 끔이면 원본 그대로)
ExamScheduleResponse? applyDevExamDdayOverride(
  ExamScheduleResponse? serverSchedule, {
  required DevExamDdaySimulation simulation,
  required DateTime today,
}) {
  final daysUntilExam = simulation.daysUntilExam;
  if (daysUntilExam == null) return serverSchedule;
  final examDate = DateTime(today.year, today.month, today.day + daysUntilExam);
  // 시험일 문자열 형식: yyyy-MM-dd (서버 examDate 와 같은 모양)
  final examDateText = examDate.toIso8601String().substring(0, 10);
  return serverSchedule?.copyWith(examDate: examDateText) ??
      ExamScheduleResponse(
        examScheduleUuid: _simulatedExamScheduleUuid,
        certType: _simulatedCertType,
        round: _simulatedRound,
        examDate: examDateText,
        isSelected: true,
      );
}

/// 날짜 넘기기 흉내 (#819): 앞으로 넘긴 일수. 원본은 AppClock, 이 Provider 는 화면 갱신용 거울
final devShiftedDayCountProvider =
    NotifierProvider<DevShiftedDayCountNotifier, int>(
      DevShiftedDayCountNotifier.new,
    );

class DevShiftedDayCountNotifier extends Notifier<int> {
  @override
  int build() => AppClock.devShiftedDayCount;

  /// 하루 넘기기 (자정 지남 흉내, 운영 빌드는 무시)
  void shiftOneDay() => _apply(AppClock.devShiftedDayCount + 1);

  /// 원래 날짜로
  void reset() => _apply(0);

  void _apply(int dayCount) {
    if (!AppBuildFlavor.canUseDevTools) return;
    AppClock.setDevShiftedDayCount(dayCount);
    state = AppClock.devShiftedDayCount;
  }
}
