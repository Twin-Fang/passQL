import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'daily_set_providers.dart';
import 'home_providers.dart';
import 'stats_providers.dart';

/// 풀이 결과가 학습 현황(홈의 히트맵/준비도/추천, 통계)에 반영되도록 캐시를 비운다.
///
/// 이 데이터는 한 번 불러오면 앱이 살아 있는 동안 캐시로 남아서, 문제를 풀고
/// 돌아와도 예전 값이 보이는 문제가 있었다. 풀이를 끝내는 모든 흐름이 이 함수를 쓴다.
/// 새 화면에서 학습 현황을 보여주게 되면 여기에 한 줄만 추가하면 된다.
///
/// `ref.invalidate`(위젯/Provider 공통)나 `container.invalidate` 를 그대로 넘긴다.
void refreshLearningData(void Function(ProviderOrFamily provider) invalidate) {
  invalidate(homeDataProvider);
  invalidate(statsDataProvider);
}

/// 날짜가 바뀌면 다시 받아야 하는 데이터: 학습 현황(홈 인사말·오늘의 세트 카드 포함) > 오늘의 세트 상태·순위
void refreshDateDependentData(
  void Function(ProviderOrFamily provider) invalidate,
) {
  refreshLearningData(invalidate);
  invalidate(dailySetTodayProvider);
  invalidate(leaderboardProvider);
}
