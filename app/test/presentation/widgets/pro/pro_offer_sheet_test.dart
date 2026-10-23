import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:passql_app/core/billing/pro_purchase_port.dart';
import 'package:passql_app/core/utils/date_format.dart';
import 'package:passql_app/data/models/member/member_plan_response.dart';
import 'package:passql_app/presentation/design/design.dart';
import 'package:passql_app/presentation/providers/plan_providers.dart';
import 'package:passql_app/presentation/widgets/pro/locked_preview_samples.dart';
import 'package:passql_app/presentation/widgets/pro/pro_info_sheet.dart';
import 'package:passql_app/presentation/widgets/pro/pro_offer_sheet.dart';

import '../../../helpers/text_finders.dart';

// 이용권 상품 ID 2종 (서버 passOptions 고정값)
const String _threeMonthPassId = 'pro_pass_3m';
const String _oneMonthPassId = 'pro_pass_1m';

/// 스토어 가격 9,900원(3개월) · 4,400원(1개월) > 25% 할인 · 월 3,300원
const Map<String, PassPrice> _storePrices = {
  _threeMonthPassId: PassPrice(displayPrice: '₩9,900', rawPrice: 9900),
  _oneMonthPassId: PassPrice(displayPrice: '₩4,400', rawPrice: 4400),
};

/// 가격·동작 결과를 정해 주는 가짜 결제 포트
class _FakeProPurchasePort implements ProPurchasePort {
  _FakeProPurchasePort({
    this.prices = _storePrices,
    this.purchaseOutcome,
    this.purchaseGate,
  });

  final Map<String, PassPrice> prices;
  final ProPurchaseOutcome? purchaseOutcome;

  /// 있으면 결제가 이 신호가 올 때까지 끝나지 않음 (결제 도중 시트 닫기 재현)
  final Completer<void>? purchaseGate;
  final List<String> purchasedProductIds = [];
  int get purchaseCallCount => purchasedProductIds.length;

  @override
  Future<Map<String, PassPrice>> loadPassPrices(
    List<String> productIds,
  ) async => {
    for (final productId in productIds) productId: ?prices[productId],
  };

  @override
  Future<ProPurchaseOutcome> purchasePass(String productId) async {
    purchasedProductIds.add(productId);
    await purchaseGate?.future;
    return purchaseOutcome ?? ProPurchaseOutcome.cancelled;
  }

  @override
  Future<ProPurchaseOutcome> restorePurchases() async =>
      ProPurchaseOutcome.nothingToRestore;
}

/// 등급 다시 받기 호출 횟수만 세는 가짜 등급 상태
int _planRefreshCount = 0;

class _FakePlanNotifier extends PlanNotifier {
  @override
  Future<MemberPlanResponse> build() async => _freePlan;

  @override
  Future<void> refresh() async => _planRefreshCount++;
}

// 지금 사면 될 만료일 (3개월 먼저, 서버 순서)
final _threeMonthExpiry = DateTime(2027, 1, 21, 12);
final _oneMonthExpiry = DateTime(2026, 11, 22, 12);

final _freePlan = MemberPlanResponse(
  isBillingEnabled: true,
  dailyFreeLimit: 10,
  passOptions: [
    PassOption(
      productId: _threeMonthPassId,
      durationDays: 90,
      expiresAtIfPurchased: _threeMonthExpiry,
    ),
    PassOption(
      productId: _oneMonthPassId,
      durationDays: 30,
      expiresAtIfPurchased: _oneMonthExpiry,
    ),
  ],
);

/// 시트를 여는 버튼 하나만 있는 화면
Widget _app({
  required ProPurchasePort port,
  ThemeData? theme,
  String? reason,
  VoidCallback? onOpened,
  bool isInfoSheet = false,
  MemberPlanResponse? plan,
}) {
  return ProviderScope(
    overrides: [
      proPurchasePortProvider.overrideWithValue(port),
      knownPlanProvider.overrideWith((ref) => plan ?? _freePlan),
      planProvider.overrideWith(_FakePlanNotifier.new),
    ],
    child: MaterialApp(
      theme: theme ?? PassqlTheme.light,
      home: Scaffold(
        body: Consumer(
          builder: (context, ref, _) => TextButton(
            onPressed: () {
              onOpened?.call();
              if (isInfoSheet) {
                showProInfoSheet(context, proExpiresAt: DateTime(2026, 11, 22));
              } else {
                showProOfferSheet(context, ref, reason: reason);
              }
            },
            child: const Text('열기'),
          ),
        ),
      ),
    ),
  );
}

PassqlButton _buyButton(WidgetTester tester) => tester.widget<PassqlButton>(
  find.byWidgetPredicate(
    (widget) => widget is PassqlButton && widget.label.contains('이용권'),
  ),
);

/// 시트(BottomSheet) 안에서만 찾는 글자 (토스트는 시트 밖이라 걸리지 않음)
Finder _inSheet(String text) =>
    find.descendant(of: find.byType(BottomSheet), matching: find.text(text));

void main() {
  setUp(() => _planRefreshCount = 0);

  testWidgets('offerSheet_showsReasonLine', (tester) async {
    await tester.pumpWidget(
      _app(port: _FakeProPurchasePort(), reason: '오늘 무료 10문제를 다 풀었어요'),
    );
    await tester.tap(find.text('열기'));
    await tester.pumpAndSettle();

    expect(
      findTextContainingIgnoringWordJoiners('오늘 무료 10문제를 다 풀었어요'),
      findsOneWidget,
    );
    expect(find.text('이용권'), findsWidgets);
    // 무료: 기본 선택(3개월) 만료일까지
    expect(
      findTextContainingIgnoringWordJoiners('2027.01.21까지 · 자동 결제 없음'),
      findsOneWidget,
    );
    expect(_buyButton(tester).label, '3개월 이용권 ₩9,900');
    expect(_buyButton(tester).onPressed, isNotNull);
    expect(find.text('이미 구매했나요? 복원하기'), findsOneWidget);
    // 개념 학습 행은 숨김
    expect(find.text('개념 학습'), findsNothing);
  });

  testWidgets('offerSheet_defaultsToThreeMonth_withDiscountBadge', (
    tester,
  ) async {
    final port = _FakeProPurchasePort(
      purchaseOutcome: ProPurchaseOutcome.pending,
    );
    await tester.pumpWidget(_app(port: port));
    await tester.tap(find.text('열기'));
    await tester.pumpAndSettle();

    expect(find.text('3개월 이용권'), findsOneWidget);
    expect(find.text('1개월 이용권'), findsOneWidget);
    // 할인 배지는 3개월 칸에만 (1 - 9900/(3×4400) = 25%, 9900/3 = 3,300원)
    expect(find.text('25% 할인 · 월 3,300원'), findsOneWidget);
    expect(find.text('₩9,900'), findsOneWidget);
    expect(find.text('₩4,400'), findsOneWidget);

    // 1개월 칸 고르기 > 버튼·미리보기 바뀜 > 그 상품으로 결제
    await tester.tap(find.text('1개월 이용권'));
    await tester.pumpAndSettle();
    expect(_buyButton(tester).label, '1개월 이용권 ₩4,400');
    expect(
      findTextContainingIgnoringWordJoiners('2026.11.22까지 · 자동 결제 없음'),
      findsOneWidget,
    );
    await tester.tap(find.text('1개월 이용권 ₩4,400'));
    await tester.pumpAndSettle();
    expect(port.purchasedProductIds, [_oneMonthPassId]);
  });

  testWidgets('offerSheet_activePro_previewsExtendedExpiry', (tester) async {
    final currentExpiry = DateTime.now().add(const Duration(days: 10));
    await tester.pumpWidget(
      _app(
        port: _FakeProPurchasePort(),
        plan: _freePlan.copyWith(
          plan: MemberPlanType.pro,
          proExpiresAt: currentExpiry,
        ),
      ),
    );
    await tester.tap(find.text('열기'));
    await tester.pumpAndSettle();

    expect(
      findTextContainingIgnoringWordJoiners(
        '만료일 ${formatDottedDate(currentExpiry)} > 2027.01.21 · 자동 결제 없음',
      ),
      findsOneWidget,
    );
  });

  testWidgets('offerSheet_missingBasePrice_hidesDiscountBadge', (tester) async {
    await tester.pumpWidget(
      _app(
        port: _FakeProPurchasePort(
          prices: {_threeMonthPassId: _storePrices[_threeMonthPassId]!},
        ),
      ),
    );
    await tester.tap(find.text('열기'));
    await tester.pumpAndSettle();

    expect(findTextContainingIgnoringWordJoiners('% 할인'), findsNothing);
    expect(_buyButton(tester).onPressed, isNotNull);
  });

  testWidgets('offerSheet_secondCallWhileOpen_ignored', (tester) async {
    late WidgetRef capturedRef;
    late BuildContext capturedContext;
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          proPurchasePortProvider.overrideWithValue(_FakeProPurchasePort()),
          knownPlanProvider.overrideWith((ref) => _freePlan),
        ],
        child: MaterialApp(
          theme: PassqlTheme.light,
          home: Consumer(
            builder: (context, ref, _) {
              capturedRef = ref;
              capturedContext = context;
              return const Scaffold();
            },
          ),
        ),
      ),
    );

    unawaited(showProOfferSheet(capturedContext, capturedRef));
    unawaited(showProOfferSheet(capturedContext, capturedRef));
    await tester.pumpAndSettle();

    expect(find.text('이미 구매했나요? 복원하기'), findsOneWidget);
    // 시트 한 장만 열렸으므로 한 번 닫으면 사라짐
    Navigator.of(capturedContext, rootNavigator: true).pop();
    await tester.pumpAndSettle();
    expect(find.text('이미 구매했나요? 복원하기'), findsNothing);
  });

  testWidgets('lockedPreview_tapAnywhere_callsOnUnlock', (tester) async {
    var unlockCount = 0;
    var innerTapCount = 0;
    await tester.pumpWidget(
      MaterialApp(
        theme: PassqlTheme.light,
        home: Scaffold(
          body: Center(
            child: SizedBox(
              width: 320,
              child: PassqlLockedPreview(
                caption: '보기별 해설 · 함정 · 시험 팁',
                onUnlock: () => unlockCount++,
                preview: TextButton(
                  onPressed: () => innerTapCount++,
                  child: const SizedBox(width: 300, height: 160),
                ),
              ),
            ),
          ),
        ),
      ),
    );

    expect(
      findTextContainingIgnoringWordJoiners('보기별 해설 · 함정 · 시험 팁'),
      findsOneWidget,
    );
    expect(find.text('이용권으로 열기'), findsOneWidget);
    final previewRect = tester.getRect(find.byType(PassqlLockedPreview));

    // 모서리 > 흐린 항목 > 알약 버튼 순서로 눌러도 모두 onUnlock
    await tester.tapAt(previewRect.topLeft + const Offset(8, 8));
    await tester.tap(find.byType(TextButton), warnIfMissed: false);
    await tester.tap(find.text('이용권으로 열기'));
    await tester.pump();

    expect(unlockCount, 3);
    expect(innerTapCount, 0);
  });

  testWidgets('offerSheet_productUnavailable_disablesBuyButton', (
    tester,
  ) async {
    final port = _FakeProPurchasePort(prices: const {});
    await tester.pumpWidget(_app(port: port));
    await tester.tap(find.text('열기'));
    await tester.pumpAndSettle();

    expect(_buyButton(tester).onPressed, isNull);
    expect(find.text('지금은 구매할 수 없어요'), findsOneWidget);
    expect(port.purchaseCallCount, 0);
  });

  testWidgets('offerSheet_purchasePending_showsInlineLineInsideSheet', (
    tester,
  ) async {
    final port = _FakeProPurchasePort(
      purchaseOutcome: ProPurchaseOutcome.pending,
    );
    await tester.pumpWidget(_app(port: port));
    await tester.tap(find.text('열기'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('3개월 이용권 ₩9,900'));
    await tester.pumpAndSettle();

    // 토스트는 시트에 가려지므로 시트 안 한 줄로 안내하고 시트는 열려 있음
    expect(port.purchaseCallCount, 1);
    expect(_inSheet('결제가 확인되면 열려요'), findsOneWidget);
    expect(find.byType(SnackBar), findsNothing);
    expect(_buyButton(tester).onPressed, isNotNull);
  });

  testWidgets('offerSheet_purchaseSuccess_closesSheetThenToasts', (
    tester,
  ) async {
    final port = _FakeProPurchasePort(
      purchaseOutcome: ProPurchaseOutcome.success,
    );
    await tester.pumpWidget(_app(port: port));
    await tester.tap(find.text('열기'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('3개월 이용권 ₩9,900'));
    await tester.pumpAndSettle();

    expect(_planRefreshCount, 1);
    expect(find.byType(BottomSheet), findsNothing);
    expect(find.text('이용권이 열렸어요'), findsOneWidget);
  });

  testWidgets('offerSheet_dismissedMidPurchase_stillRefreshesPlan', (
    tester,
  ) async {
    final gate = Completer<void>();
    final port = _FakeProPurchasePort(
      purchaseOutcome: ProPurchaseOutcome.success,
      purchaseGate: gate,
    );
    await tester.pumpWidget(_app(port: port));
    await tester.tap(find.text('열기'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('3개월 이용권 ₩9,900'));
    await tester.pump();

    // 결제 창이 떠 있는 동안 시트를 바깥 탭으로 닫음
    await tester.tapAt(const Offset(10, 10));
    await tester.pumpAndSettle();
    expect(find.byType(BottomSheet), findsNothing);

    gate.complete();
    await tester.pumpAndSettle();

    expect(_planRefreshCount, 1);
    expect(tester.takeException(), isNull);
  });

  testWidgets('offerSheet_afterBarrierDismiss_opensAgain', (tester) async {
    await tester.pumpWidget(_app(port: _FakeProPurchasePort()));
    await tester.tap(find.text('열기'));
    await tester.pumpAndSettle();
    expect(find.byType(BottomSheet), findsOneWidget);

    // 바깥 탭으로 닫은 뒤에도 가드가 풀려 다시 열림
    await tester.tapAt(const Offset(10, 10));
    await tester.pumpAndSettle();
    expect(find.byType(BottomSheet), findsNothing);

    await tester.tap(find.text('열기'));
    await tester.pumpAndSettle();
    expect(find.byType(BottomSheet), findsOneWidget);
  });

  testWidgets('infoSheet_nothingToRestore_showsInlineLineInsideSheet', (
    tester,
  ) async {
    await tester.pumpWidget(
      _app(port: _FakeProPurchasePort(), isInfoSheet: true),
    );
    await tester.tap(find.text('열기'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('구매 복원'));
    await tester.pumpAndSettle();

    expect(_inSheet('복원할 구매가 없어요'), findsOneWidget);
    expect(find.byType(BottomSheet), findsOneWidget);
  });

  testWidgets('comparisonTable_marksHaveSemanticLabels', (tester) async {
    final handle = tester.ensureSemantics();
    await tester.pumpWidget(_app(port: _FakeProPurchasePort()));
    await tester.tap(find.text('열기'));
    await tester.pumpAndSettle();

    expect(find.bySemanticsLabel('포함'), findsWidgets);
    expect(find.bySemanticsLabel('제공 안 함'), findsWidgets);
    handle.dispose();
  });

  for (final isDark in [false, true]) {
    final modeName = isDark ? 'dark' : 'light';

    testWidgets('proComponents_${modeName}_noOverflow', (tester) async {
      await tester.binding.setSurfaceSize(const Size(320, 640));
      addTearDown(() => tester.binding.setSurfaceSize(null));
      final theme = isDark ? PassqlTheme.dark : PassqlTheme.light;

      // 안내 시트
      await tester.pumpWidget(
        _app(
          port: _FakeProPurchasePort(),
          theme: theme,
          reason: '오늘 무료 10문제를 다 풀었어요',
        ),
      );
      await tester.tap(find.text('열기'));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      Navigator.of(tester.element(find.text('이미 구매했나요? 복원하기'))).pop();
      await tester.pumpAndSettle();

      // 이용권 정보 시트
      await tester.pumpWidget(
        _app(port: _FakeProPurchasePort(), theme: theme, isInfoSheet: true),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.text('열기'));
      await tester.pumpAndSettle();
      expect(find.text('이용권 사용 중'), findsOneWidget);
      expect(find.text('구매일'), findsNothing);
      expect(find.text('주문 번호'), findsNothing);
      expect(tester.takeException(), isNull);

      // 잠금 미리보기 6종 + 칩 2종
      final samples = <(String, Widget)>[
        ('해설', const ExplanationLockedSample()),
        ('실행 결과', const ExecutionResultLockedSample()),
        ('풀기 방식', const PracticeModesLockedSample()),
        ('통계', const StatsLockedSample()),
        ('출제 경향', const ExamTrendLockedSample()),
        ('실전 모드 설정', const RealModeSettingLockedSample()),
      ];
      for (final (caption, sample) in samples) {
        await tester.pumpWidget(
          MaterialApp(
            theme: theme,
            home: Scaffold(
              body: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(PassqlSpacing.md),
                  child: Column(
                    children: [
                      const Row(
                        children: [
                          PassqlPlanChip(isPro: false),
                          PassqlPlanChip(isPro: true),
                        ],
                      ),
                      PassqlLockedPreview(
                        caption: caption,
                        onUnlock: () {},
                        preview: sample,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
        expect(tester.takeException(), isNull, reason: caption);
      }
    });
  }
}
