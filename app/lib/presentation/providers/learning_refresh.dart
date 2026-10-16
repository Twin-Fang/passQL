import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'daily_set_providers.dart';
import 'home_providers.dart';
import 'stats_providers.dart';
import 'wrong_questions_provider.dart';

/// 풀이 결과가 학습 현황에 반영되도록 풀이로 바뀌는 캐시만 비운다.
///
/// 대상 3개: 홈 학습 현황(진행 현황·히트맵·오늘의 세트 상태), 통계(진행 현황·토픽 분석), 설정 오답 개수
/// 인사말·시험 일정·추천·AI 코멘트는 풀이와 무관해 그대로 둔다 (#497)
/// 풀이를 끝내는 모든 흐름이 이 함수를 쓴다.
///
/// `ref.invalidate`(위젯/Provider 공통)나 `container.invalidate` 를 그대로 넘긴다.
void refreshLearningData(void Function(ProviderOrFamily provider) invalidate) {
  invalidate(homeLearningStatusProvider);
  invalidate(statsDataProvider);
  invalidate(wrongQuestionTotalCountProvider);
}

/// 날짜가 바뀌면 다시 받아야 하는 데이터: 홈 전체(인사말 포함)·통계 > 오늘의 세트 상태·순위
void refreshDateDependentData(
  void Function(ProviderOrFamily provider) invalidate,
) {
  invalidateHomeData(invalidate);
  invalidate(statsDataProvider);
  invalidate(dailySetTodayProvider);
  invalidate(leaderboardProvider);
}
