import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'daily_set_providers.dart';
import 'home_providers.dart';
import 'settings_providers.dart';
import 'stats_providers.dart';

/// 로그아웃하거나 다른 계정으로 로그인했을 때, 이전 사용자의 데이터가 남아 보이지 않게 한다.
///
/// 홈, 통계, 설정, 순위처럼 회원별로 달라지는 캐시를 모두 비운다.
/// 새 회원별 Provider 를 만들면 여기에 한 줄 추가한다.
void resetUserScopedProviders(void Function(ProviderOrFamily provider) invalidate) {
  invalidate(homeDataProvider);
  invalidate(statsDataProvider);
  invalidate(settingsDataProvider);
  invalidate(nicknameNotifierProvider);
  invalidate(choiceModeProvider);
  invalidate(dailySetTodayProvider);
  invalidate(leaderboardProvider);
}
