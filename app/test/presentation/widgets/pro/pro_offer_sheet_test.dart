import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:passql_app/core/billing/pro_purchase_port.dart';
import 'package:passql_app/data/models/member/member_plan_response.dart';
import 'package:passql_app/presentation/design/design.dart';
import 'package:passql_app/presentation/providers/plan_providers.dart';
import 'package:passql_app/presentation/widgets/pro/pro_offer_sheet.dart';

/// 가격을 바로 돌려주는 가짜 결제 포트 (결제·복원은 쓰지 않음)
class _FakePurchasePort implements ProPurchasePort {
  @override
  Future<Map<String, PassPrice>> loadPassPrices(List<String> productIds) async =>
      const {
        'pro_pass_3m': PassPrice(displayPrice: '9,900원', rawPrice: 9900),
        'pro_pass_1m': PassPrice(displayPrice: '4,400원', rawPrice: 4400),
      };

  @override
  Future<ProPurchaseOutcome> purchasePass(String productId) async =>
      ProPurchaseOutcome.cancelled;

  @override
  Future<ProPurchaseOutcome> restorePurchases() async =>
      ProPurchaseOutcome.cancelled;
}

final _freePlan = MemberPlanResponse(
  isBillingEnabled: true,
  dailyFreeLimit: 10,
  todayRandomSolvedCount: 3,
  passOptions: [
    PassOption(
      productId: 'pro_pass_3m',
      durationDays: 90,
      expiresAtIfPurchased: DateTime(2027, 1, 26),
    ),
    PassOption(
      productId: 'pro_pass_1m',
      durationDays: 30,
      expiresAtIfPurchased: DateTime(2026, 11, 27),
    ),
  ],
);

Future<void> _openSheet(WidgetTester tester, {int? focusedBenefitIndex}) async {
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        knownPlanProvider.overrideWith((ref) => _freePlan),
        proPurchasePortProvider.overrideWithValue(_FakePurchasePort()),
      ],
      child: MaterialApp(
        theme: PassqlTheme.light,
        // 반복 효과(빛줄기·홀로그램)를 멈춰 pumpAndSettle 이 끝나게 한다
        builder: (context, child) => MediaQuery(
          data: MediaQuery.of(context).copyWith(disableAnimations: true),
          child: child!,
        ),
        home: Consumer(
          builder: (context, ref, _) => Scaffold(
            body: TextButton(
              onPressed: () => showProOfferSheet(
                context,
                ref,
                focusedBenefitIndex: focusedBenefitIndex,
              ),
              child: const Text('열기'),
            ),
          ),
        ),
      ),
    ),
  );
  await tester.tap(find.text('열기'));
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('혜택 아이콘으로 열면 그 혜택 강조 줄이 보인다', (tester) async {
    await _openSheet(tester, focusedBenefitIndex: 1);
    expect(find.byKey(const Key('pro-offer-focused-benefit')), findsOneWidget);
    expect(
      find.descendant(
        of: find.byKey(const Key('pro-offer-focused-benefit')),
        matching: find.text('SQL 직접 실행'),
      ),
      findsOneWidget,
    );
  });

  testWidgets('인자 없이 열면 강조 줄이 없다', (tester) async {
    await _openSheet(tester);
    expect(find.byKey(const Key('pro-offer-focused-benefit')), findsNothing);
  });

  testWidgets('1개월을 고르면 3개월 권유 줄이 나온다', (tester) async {
    await _openSheet(tester);
    expect(find.textContaining('3개월로 바꾸면'), findsNothing);
    // 구매 버튼이 아래에 고정돼 있어 칸을 스크롤로 먼저 보이게 한다
    await tester.ensureVisible(find.text('1개월'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('1개월'));
    await tester.pumpAndSettle();
    expect(find.textContaining('3,300원 아껴요'), findsOneWidget);
  });
}
