import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:passql_app/core/billing/pro_purchase_port.dart';
import 'package:passql_app/data/models/member/member_plan_response.dart';
import 'package:passql_app/presentation/design/design.dart';
import 'package:passql_app/presentation/flows/random_practice_flow.dart';
import 'package:passql_app/presentation/providers/plan_providers.dart';
import 'package:passql_app/presentation/widgets/home/random_practice_card.dart';
import 'package:passql_app/presentation/widgets/pro/pro_access_feedback.dart';

import '../../../helpers/text_finders.dart';

/// 등급 고정 (다시 받아도 같은 값)
class _FixedPlanNotifier extends PlanNotifier {
  _FixedPlanNotifier(this._plan);

  final MemberPlanResponse _plan;

  @override
  Future<MemberPlanResponse> build() async => _plan;

  @override
  Future<void> refresh() async {}
}

Widget _cardApp(int todayRandomSolvedCount) => ProviderScope(
  overrides: [
    targetPlatformProvider.overrideWithValue(TargetPlatform.android),
    debugPlanOverrideProvider.overrideWithValue(null),
    planProvider.overrideWith(
      () => _FixedPlanNotifier(
        MemberPlanResponse(
          isBillingEnabled: true,
          todayRandomSolvedCount: todayRandomSolvedCount,
          dailyFreeLimit: 10,
        ),
      ),
    ),
    proPurchasePortProvider.overrideWithValue(
      const UnavailableProPurchasePort(),
    ),
  ],
  child: MaterialApp(
    theme: PassqlTheme.light,
    home: const Scaffold(body: RandomPracticeCard()),
  ),
);

void main() {
  testWidgets('belowLimit_showsUsageAndInvitesEntry', (tester) async {
    await tester.pumpWidget(_cardApp(9));
    await tester.pumpAndSettle();

    expect(find.text('오늘 랜덤 9 / 10'), findsOneWidget);
    expect(find.text(RandomPracticeFlow.summary), findsOneWidget);
    expect(find.byIcon(CupertinoIcons.chevron_forward), findsOneWidget);
  });

  testWidgets('limitReached_showsResetNoticeAndOpensSheetOnTap', (
    tester,
  ) async {
    await tester.pumpWidget(_cardApp(10));
    await tester.pumpAndSettle();

    // 10/10: 진입 권유 대신 다시 열리는 때, 화살표 없음
    expect(find.text('오늘 랜덤 10 / 10'), findsOneWidget);
    expect(find.text(freeDailyLimitResetNotice), findsOneWidget);
    expect(find.text(RandomPracticeFlow.summary), findsNothing);
    expect(find.byIcon(CupertinoIcons.chevron_forward), findsNothing);

    // 탭 > 풀이 진입 없이 프로 안내 시트 + 한도 이유 줄
    await tester.tap(find.byType(RandomPracticeCard));
    await tester.pumpAndSettle();
    expect(find.text('이미 구매했나요? 복원하기'), findsOneWidget);
    expect(
      findTextContainingIgnoringWordJoiners(freeDailyLimitReason),
      findsOneWidget,
    );
  });
}
