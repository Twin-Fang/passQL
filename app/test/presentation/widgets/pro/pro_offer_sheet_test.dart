import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:passql_app/core/billing/pro_purchase_port.dart';
import 'package:passql_app/data/models/member/member_plan_response.dart';
import 'package:passql_app/presentation/design/design.dart';
import 'package:passql_app/presentation/providers/plan_providers.dart';
import 'package:passql_app/presentation/widgets/pro/locked_preview_samples.dart';
import 'package:passql_app/presentation/widgets/pro/pro_info_sheet.dart';
import 'package:passql_app/presentation/widgets/pro/pro_offer_sheet.dart';

import '../../../helpers/text_finders.dart';

/// 가격·동작 결과를 정해 주는 가짜 결제 포트
class _FakeProPurchasePort implements ProPurchasePort {
  _FakeProPurchasePort({this.price, this.purchaseOutcome});

  final String? price;
  final ProPurchaseOutcome? purchaseOutcome;
  int purchaseCallCount = 0;

  @override
  Future<String?> loadExamPassPrice() async => price;

  @override
  Future<ProPurchaseOutcome> purchaseExamPass() async {
    purchaseCallCount++;
    return purchaseOutcome ?? ProPurchaseOutcome.cancelled;
  }

  @override
  Future<ProPurchaseOutcome> restorePurchases() async =>
      ProPurchaseOutcome.nothingToRestore;
}

final _knownPlan = MemberPlanResponse(
  isBillingEnabled: true,
  dailyFreeLimit: 10,
  purchasableUntil: DateTime(2026, 11, 22),
);

/// 시트를 여는 버튼 하나만 있는 화면
Widget _app({
  required ProPurchasePort port,
  ThemeData? theme,
  String? reason,
  VoidCallback? onOpened,
  bool isInfoSheet = false,
}) {
  return ProviderScope(
    overrides: [
      proPurchasePortProvider.overrideWithValue(port),
      knownPlanProvider.overrideWith((ref) => _knownPlan),
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
    (widget) => widget is PassqlButton && widget.label.startsWith('회차 패스'),
  ),
);

void main() {
  testWidgets('offerSheet_showsReasonLine', (tester) async {
    await tester.pumpWidget(
      _app(
        port: _FakeProPurchasePort(price: '₩4,900'),
        reason: '오늘 무료 10문제를 다 풀었어요',
      ),
    );
    await tester.tap(find.text('열기'));
    await tester.pumpAndSettle();

    expect(
      findTextContainingIgnoringWordJoiners('오늘 무료 10문제를 다 풀었어요'),
      findsOneWidget,
    );
    expect(find.text('회차 패스'), findsWidgets);
    expect(
      findTextContainingIgnoringWordJoiners(
        '다음 SQLD 시험일(2026.11.22)까지 · 자동 결제 없음',
      ),
      findsOneWidget,
    );
    expect(_buyButton(tester).label, '회차 패스 ₩4,900');
    expect(_buyButton(tester).onPressed, isNotNull);
    expect(find.text('이미 구매했나요? 복원하기'), findsOneWidget);
    // 개념 학습 행은 숨김
    expect(find.text('개념 학습'), findsNothing);
  });

  testWidgets('offerSheet_secondCallWhileOpen_ignored', (tester) async {
    late WidgetRef capturedRef;
    late BuildContext capturedContext;
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          proPurchasePortProvider.overrideWithValue(
            _FakeProPurchasePort(price: '₩4,900'),
          ),
          knownPlanProvider.overrideWith((ref) => _knownPlan),
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
    expect(find.text('회차 패스로 열기'), findsOneWidget);
    final previewRect = tester.getRect(find.byType(PassqlLockedPreview));

    // 모서리 > 흐린 항목 > 알약 버튼 순서로 눌러도 모두 onUnlock
    await tester.tapAt(previewRect.topLeft + const Offset(8, 8));
    await tester.tap(find.byType(TextButton), warnIfMissed: false);
    await tester.tap(find.text('회차 패스로 열기'));
    await tester.pump();

    expect(unlockCount, 3);
    expect(innerTapCount, 0);
  });

  testWidgets('offerSheet_productUnavailable_disablesBuyButton', (
    tester,
  ) async {
    final port = _FakeProPurchasePort(price: null);
    await tester.pumpWidget(_app(port: port));
    await tester.tap(find.text('열기'));
    await tester.pumpAndSettle();

    expect(_buyButton(tester).onPressed, isNull);
    expect(find.text('지금은 구매할 수 없어요'), findsOneWidget);
    expect(port.purchaseCallCount, 0);
  });

  testWidgets('offerSheet_purchasePending_showsPendingToast', (tester) async {
    final port = _FakeProPurchasePort(
      price: '₩4,900',
      purchaseOutcome: ProPurchaseOutcome.pending,
    );
    await tester.pumpWidget(_app(port: port));
    await tester.tap(find.text('열기'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('회차 패스 ₩4,900'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));

    expect(port.purchaseCallCount, 1);
    expect(find.text('결제가 확인되면 열려요'), findsOneWidget);
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
          port: _FakeProPurchasePort(price: '₩4,900'),
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
        _app(
          port: _FakeProPurchasePort(price: '₩4,900'),
          theme: theme,
          isInfoSheet: true,
        ),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.text('열기'));
      await tester.pumpAndSettle();
      expect(find.text('회차 패스 이용 중'), findsOneWidget);
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
