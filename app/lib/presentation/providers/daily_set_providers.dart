import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/network/api_providers.dart';
import '../../data/models/daily_set/daily_set_models.dart';

/// 오늘의 세트 상태(완료 여부, 정답 수). 결과 화면을 직접 열었을 때 쓴다.
final dailySetTodayProvider = FutureProvider.autoDispose<DailySetTodayResponse>(
  (ref) => ref.read(dailySetApiProvider).getToday(),
);

/// 오늘의 순위.
final leaderboardProvider = FutureProvider.autoDispose<LeaderboardResponse>(
  (ref) => ref.read(dailySetApiProvider).getLeaderboard(),
);
