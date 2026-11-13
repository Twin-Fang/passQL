import 'dart:async';

import 'package:flutter/widgets.dart';

import '../../../core/monitoring/app_analytics.dart';
import '../../design/design.dart';
import 'daily_limit_reward_view.dart';

/// 제출·진입 단계에서 한도로 막혔을 때 같은 화면을 시트로 (#963): 광고 보상·구매로 풀리면 true
/// 세트 풀러 가기 > 시트를 닫고 호출 화면에서 세트 열기 (풀이 흐름 안이면 교체, 홈·문제 탭이면 쌓기)
/// 광고 확인 중에 그냥 닫으면 그 확인 결과로 판정
Future<bool> showDailyLimitRewardSheet(BuildContext context) async {
  unawaited(AppAnalytics.current.logDailyLimitSheetOpened());
  Future<bool>? pendingAdBonus;
  var shouldOpenDailySet = false;
  final isUnlocked = await showPassqlSheet<bool>(
    context,
    builder: (sheetContext) => DailyLimitRewardView(
      onUnlocked: () => _closeSheetWith(sheetContext, isUnlocked: true),
      onOpenDailySet: () {
        shouldOpenDailySet = true;
        _closeSheetWith(sheetContext, isUnlocked: false);
      },
      onAdBonusAttemptStarted: (isBonusGranted) =>
          pendingAdBonus = isBonusGranted,
    ),
  );
  if (isUnlocked != null) {
    if (shouldOpenDailySet && context.mounted) {
      openDailySetFromDailyLimit(context);
    }
    return isUnlocked;
  }
  return await pendingAdBonus?.catchError((Object _) => false) ?? false;
}

/// 시트가 맨 위일 때만 닫기 (이미 닫히는 중이면 pop 이 아래 화면을 닫음)
void _closeSheetWith(BuildContext sheetContext, {required bool isUnlocked}) {
  if (ModalRoute.of(sheetContext)?.isCurrent != true) return;
  Navigator.of(sheetContext).pop(isUnlocked);
}
