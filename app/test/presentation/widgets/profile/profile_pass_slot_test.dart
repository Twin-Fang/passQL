import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:passql_app/data/models/member/member_plan_response.dart';
import 'package:passql_app/presentation/design/design.dart';
import 'package:passql_app/presentation/providers/home_providers.dart';
import 'package:passql_app/presentation/providers/plan_providers.dart';
import 'package:passql_app/presentation/providers/pro_ui_providers.dart';
import 'package:passql_app/presentation/widgets/profile/profile_pass_slot.dart';
import 'package:shared_preferences/shared_preferences.dart';

final _proPlan = MemberPlanResponse(
  isBillingEnabled: true,
  plan: MemberPlanType.pro,
  dailyFreeLimit: 10,
  proExpiresAt: DateTime(2026, 12, 31),
);

void main() {
  testWidgets('구매 직후 연출이 끝나도 이번 화면에서는 펼친 탑승권을 유지한다', (tester) async {
    // 접힘 저장값은 기본(접힘), 구매 연출 대기 중
    SharedPreferences.setMockInitialValues({'profile_pass_reveal_pending': true});
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          knownPlanProvider.overrideWith((ref) => _proPlan),
          shouldShowProUiProvider.overrideWith((ref) => false),
          shouldShowProBadgeProvider.overrideWith((ref) => true),
          examScheduleProvider.overrideWith((ref) async => null),
        ],
        child: MaterialApp(
          theme: PassqlTheme.light,
          // 동작 줄이기: 연출을 바로 끝내고 대기 표시를 지우는 경로
          builder: (context, child) => MediaQuery(
            data: MediaQuery.of(context).copyWith(disableAnimations: true),
            child: child!,
          ),
          home: const Scaffold(body: ProfilePassSlot(nickname: '새찬')),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('접기 ⌃'), findsOneWidget);
    expect(find.bySemanticsLabel(RegExp('펼치기')), findsNothing);
  });
}
