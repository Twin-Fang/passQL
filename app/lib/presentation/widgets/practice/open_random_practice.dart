import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../router/app_routes.dart';
import '../../providers/plan_providers.dart';
import '../pro/pro_access_feedback.dart';
import '../pro/pro_offer_sheet.dart';

/// 랜덤 풀기 진입 (홈 줄·문제 탭 행 공통): 한도 남음 > 풀이, 한도 소진 > 등급 갱신 > 여전히 소진이면 안내 시트
/// 시트에서 광고 보너스·구매로 한도가 풀렸으면 이어서 풀이 진입 (#808)
/// [shouldReplaceCurrentRoute]: 지금 화면 자리를 풀이로 교체 (랜덤 요약의 계속 풀기, #963)
Future<void> openRandomPractice(
  BuildContext context,
  WidgetRef ref, {
  bool shouldReplaceCurrentRoute = false,
}) async {
  final isDailyLimitReached =
      ref.read(shouldShowProUiProvider) &&
      ref.read(knownPlanProvider)?.isDailyFreeLimitReached == true;
  if (!isDailyLimitReached) {
    _pushRandomPractice(context, shouldReplaceCurrentRoute);
    return;
  }
  // 날짜 변경·구매 반영을 위해 등급 다시 받기
  await ref.read(planProvider.notifier).refresh();
  if (!context.mounted) return;
  final isStillLimited =
      ref.read(shouldShowProUiProvider) &&
      ref.read(knownPlanProvider)?.isDailyFreeLimitReached == true;
  if (isStillLimited) {
    final sheetOutcome = await showProOfferSheet(
      context,
      ref,
      reason: freeDailyLimitSheetReason,
      isDailyLimitEntry: true,
    );
    if (!context.mounted || sheetOutcome == ProOfferSheetOutcome.dismissed) {
      return;
    }
  }
  _pushRandomPractice(context, shouldReplaceCurrentRoute);
}

void _pushRandomPractice(BuildContext context, bool shouldReplaceCurrentRoute) {
  if (shouldReplaceCurrentRoute) {
    context.pushReplacement(AppRoutes.randomPractice);
  } else {
    context.push(AppRoutes.randomPractice);
  }
}
