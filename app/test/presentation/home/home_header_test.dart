import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:passql_app/core/utils/word_wrap.dart';
import 'package:passql_app/data/models/home/greeting_response.dart';
import 'package:passql_app/presentation/design/design.dart';
import 'package:passql_app/presentation/pages/home/home_page.dart';
import 'package:passql_app/presentation/providers/home_providers.dart';
import 'package:passql_app/presentation/widgets/home/greeting_section.dart';

import '../../helpers/pump_app.dart';
import '../tab_pages_test.dart' show homeData;

/// 홈 상단 (#530): 로고·종 한 줄 상단 바 + 아래 인사 문구는 잘림·말줄임 없이 여러 줄
void main() {
  // 실제 잘렸던 문구 (줄바꿈 없는 한 줄 인사)
  const reportedGreeting = GreetingResponse(
    nickname: '새찬',
    message: '오늘도 한 문제씩, 합격에 가까워지고 있어요',
    messageType: 'ENCOURAGE',
  );
  // 서버 시간대 인사 중 긴 첫 줄 + 본문
  const longTimeGreeting = GreetingResponse(
    nickname: '공부하는새찬',
    message: '{nickname}님, 늦은 시간에도 공부 중이시네요!\n오늘도 SQL 한 문제 풀어볼까요?',
    messageType: 'DEFAULT',
  );

  // 화면 크기 3종: 320 폭(가장 좁음), SE(375x667), Pro Max(440x956)
  const screenSizes = {
    '320 폭': Size(320, 568),
    'SE': Size(375, 667),
    'Pro Max': Size(440, 956),
  };
  // 글자 배율: 기본, 앱 상한(1.4) 이상으로 요청한 큰 글자
  const textScaleFactors = [1.0, 2.0];

  Future<void> pumpHome(
    WidgetTester tester, {
    required GreetingResponse greeting,
    required Size size,
    required double textScaleFactor,
    ThemeData? theme,
  }) async {
    tester.view.physicalSize = size;
    tester.view.devicePixelRatio = 1;
    tester.platformDispatcher.textScaleFactorTestValue = textScaleFactor;
    addTearDown(tester.view.reset);
    addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          homeDataProvider.overrideWith(
            (ref) async => HomeData(
              greeting: greeting,
              progress: homeData.progress,
              dailySet: homeData.dailySet,
              recommendations: homeData.recommendations,
              examSchedule: homeData.examSchedule,
              heatmap: homeData.heatmap,
            ),
          ),
        ],
        child: MaterialApp(
          theme: theme ?? PassqlTheme.light,
          builder: PassqlTextScaleLimit.wrap,
          home: const HomePage(),
        ),
      ),
    );
    await tester.pump();
    await pumpUntilMotionDone(tester);
  }

  for (final greeting in [reportedGreeting, longTimeGreeting]) {
    for (final sizeEntry in screenSizes.entries) {
      for (final textScaleFactor in textScaleFactors) {
        testWidgets(
          '${sizeEntry.key} x$textScaleFactor "${GreetingSection.resolveMessage(greeting)}": '
          '로고·종 같은 줄, 인사 말줄임·넘침 없음',
          (tester) async {
            await pumpHome(
              tester,
              greeting: greeting,
              size: sizeEntry.value,
              textScaleFactor: textScaleFactor,
            );
            expect(tester.takeException(), isNull);

            // 상단 바: 로고 왼쪽, 종 오른쪽, 세로 중심 같음
            final logo = find.byType(PassqlLogo);
            final bell = find.byType(PassqlNotificationBellButton);
            expect(logo, findsOneWidget);
            expect(bell, findsOneWidget);
            final logoRect = tester.getRect(logo);
            final bellRect = tester.getRect(bell);
            expect(logoRect.center.dy, closeTo(bellRect.center.dy, 0.5));
            expect(logoRect.right, lessThan(bellRect.left));
            expect(logoRect.left, PassqlSpacing.md);

            // 인사: 줄 제한·말줄임 없음, 상단 바 아래, 화면 폭 안
            final headline = find.text(
              keepWordsTogether(GreetingSection.resolveMessage(greeting)),
            );
            expect(headline, findsOneWidget);
            final headlineText = tester.widget<Text>(headline);
            expect(headlineText.maxLines, isNull);
            expect(headlineText.overflow, isNull);
            final headlineRect = tester.getRect(headline);
            expect(headlineRect.top, greaterThanOrEqualTo(bellRect.bottom));
            expect(
              headlineRect.right,
              lessThanOrEqualTo(sizeEntry.value.width - PassqlSpacing.md),
            );
          },
        );
      }
    }
  }

  testWidgets('다크: 상단 바·인사 예외 없음', (tester) async {
    await pumpHome(
      tester,
      greeting: reportedGreeting,
      size: screenSizes['320 폭']!,
      textScaleFactor: 1.0,
      theme: PassqlTheme.dark,
    );
    expect(tester.takeException(), isNull);
    expect(find.byType(PassqlLogo), findsOneWidget);
  });
}
