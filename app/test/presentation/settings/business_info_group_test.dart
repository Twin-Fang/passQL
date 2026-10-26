import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:passql_app/data/models/meta/app_config.dart';
import 'package:passql_app/presentation/design/design.dart';
import 'package:passql_app/presentation/providers/app_config_providers.dart';
import 'package:passql_app/presentation/widgets/settings/business_info_group.dart';

/// 사업자 정보 표기 (#658): 서버 값 표시, 빈 줄·상호 없음·오프라인 숨김, 라이트·다크
const BusinessInfo _kollylabBusinessInfo = BusinessInfo(
  companyName: '콜리랩(KOLLYLAB)',
  representativeName: '서새찬',
  registrationNumber: '331-37-01670',
  contactEmail: 'chan4760@naver.com',
);

Future<void> _pumpGroup(
  WidgetTester tester, {
  required AppConfig? appConfig,
  ThemeData? theme,
}) async {
  await tester.pumpWidget(
    ProviderScope(
      overrides: [appConfigProvider.overrideWith((ref) async => appConfig)],
      child: MaterialApp(
        theme: theme ?? PassqlTheme.light,
        home: const Scaffold(
          body: SingleChildScrollView(child: BusinessInfoGroup()),
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  test('통신판매업 신고번호가 비면 그 줄만 빠지고 순서 유지', () {
    final labels = toBusinessInfoLines(
      _kollylabBusinessInfo,
    ).map((line) => line.label).toList();

    expect(labels, ['상호', '대표자', '사업자등록번호', '문의']);
  });

  test('신고번호가 들어오면 표시, 상호가 없으면 전체 숨김', () {
    final withSalesNumber = _kollylabBusinessInfo.copyWith(
      mailOrderSalesNumber: '2026-서울-0000',
    );
    expect(
      toBusinessInfoLines(withSalesNumber).map((line) => line.label),
      contains('통신판매업 신고번호'),
    );
    expect(
      toBusinessInfoLines(_kollylabBusinessInfo.copyWith(companyName: '  ')),
      isEmpty,
    );
  });

  test('구버전 서버 응답(businessInfo 없음)은 빈 값 > 숨김', () {
    final appConfig = AppConfig.fromJson(const {'notices': []});
    expect(toBusinessInfoLines(appConfig.businessInfo), isEmpty);
  });

  for (final (themeName, theme) in [
    ('라이트', PassqlTheme.light),
    ('다크', PassqlTheme.dark),
  ]) {
    testWidgets('$themeName: 서버 사업자 정보를 묶음으로 그린다', (tester) async {
      await _pumpGroup(
        tester,
        appConfig: const AppConfig(businessInfo: _kollylabBusinessInfo),
        theme: theme,
      );

      expect(tester.takeException(), isNull);
      expect(find.text('사업자 정보'), findsOneWidget);
      expect(find.text('콜리랩(KOLLYLAB)'), findsOneWidget);
      expect(find.text('331-37-01670'), findsOneWidget);
      expect(find.text('chan4760@naver.com'), findsOneWidget);
      expect(find.text('통신판매업 신고번호'), findsNothing);
    });
  }

  testWidgets('설정 조회 실패(오프라인)면 아무것도 그리지 않는다', (tester) async {
    await _pumpGroup(tester, appConfig: null);

    expect(find.text('사업자 정보'), findsNothing);
    expect(find.byType(PassqlGroupedSection), findsNothing);
  });
}
