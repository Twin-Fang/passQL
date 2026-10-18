import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:passql_app/data/models/meta/app_config.dart';
import 'package:passql_app/data/sources/api_providers.dart';
import 'package:passql_app/presentation/design/design.dart';
import 'package:passql_app/presentation/pages/notice/notice_detail_page.dart';
import 'package:passql_app/presentation/pages/notice/notice_list_page.dart';
import 'package:passql_app/router/app_routes.dart';

import '../../helpers/fakes/fake_meta_api.dart';

/// 공지 상세·목록 핵심 흐름 (#529): 배지·제목·게시일·마크다운 본문·링크, 없는 공지, 목록 행 > 상세 > 목록 (라이트·다크)
void main() {
  final importantNotice = AppNotice(
    noticeUuid: 'notice-1',
    title: '제58회 SQLD 대비 문제 업데이트 안내',
    body:
        '윈도우 함수 문제 **20개**가 추가됐어요.\n\n- 문제 탭에서 바로 풀 수 있어요\n- 자세히: [업데이트 안내](https://passql.example/update)',
    isImportant: true,
    publishedAt: DateTime(2026, 10, 18, 9),
  );
  final normalNotice = AppNotice(
    noticeUuid: 'notice-2',
    title: '10월 16일 새벽 서버 점검',
    body: '02:00 ~ 04:00 동안 점검해요.',
    publishedAt: DateTime(2026, 3, 5, 9),
  );

  /// 공지 목록 > 상세를 실제 라우트 패턴으로 묶은 앱
  Future<void> pumpNoticeApp(
    WidgetTester tester, {
    required ThemeData theme,
    required FakeMetaApi api,
    required String initialLocation,
  }) async {
    final router = GoRouter(
      initialLocation: initialLocation,
      routes: [
        GoRoute(
          path: AppRoutes.notices,
          builder: (_, _) => const NoticeListPage(),
        ),
        GoRoute(
          path: AppRoutes.noticeDetailPattern,
          builder: (_, state) => NoticeDetailPage(
            noticeUuid: state.pathParameters[AppRoutes.noticeUuidParameter]!,
          ),
        ),
      ],
    );
    await tester.pumpWidget(
      ProviderScope(
        overrides: [metaApiProvider.overrideWithValue(api)],
        child: MaterialApp.router(theme: theme, routerConfig: router),
      ),
    );
    await tester.pumpAndSettle();
  }

  /// 화면의 RichText 전체 글자 (굵게·링크 조각 포함)
  String allRichText(WidgetTester tester) => tester
      .widgetList<RichText>(find.byType(RichText))
      .map((richText) => richText.text.toPlainText())
      .join('\n');

  for (final (themeName, theme) in [
    ('라이트', PassqlTheme.light),
    ('다크', PassqlTheme.dark),
  ]) {
    testWidgets('상세: 중요 배지 > 제목 > 게시일 > 마크다운 본문·링크 ($themeName)', (tester) async {
      await pumpNoticeApp(
        tester,
        theme: theme,
        api: FakeMetaApi(notices: [importantNotice]),
        initialLocation: AppRoutes.noticeDetail('notice-1'),
      );

      expect(find.text('공지사항'), findsOneWidget);
      expect(find.text('중요'), findsOneWidget);
      expect(find.text(importantNotice.title), findsOneWidget);
      expect(find.text('2026.10.18'), findsOneWidget);
      // 표기 기호는 지워지고 굵게·목록·링크 이름만 보임
      final bodyText = allRichText(tester);
      expect(bodyText, contains('윈도우 함수 문제 20개가 추가됐어요.'));
      expect(bodyText, isNot(contains('**')));
      expect(bodyText, contains('업데이트 안내'));
      expect(bodyText, isNot(contains('https://passql.example/update')));
      expect(find.text('•'), findsNWidgets(2));
      // 링크 조각에 탭 인식기
      final linkSpan = _findSpan(tester, '업데이트 안내');
      expect(linkSpan?.recognizer, isNotNull);
      expect(find.text('다른 공지 보기'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('상세: 없는 공지면 안내 ($themeName)', (tester) async {
      await pumpNoticeApp(
        tester,
        theme: theme,
        api: FakeMetaApi(notices: const []),
        initialLocation: AppRoutes.noticeDetail('missing'),
      );
      expect(find.text('공지를 찾을 수 없어요'), findsOneWidget);
    });

    testWidgets('목록: 배지·제목·미리보기·게시일, 행 탭 > 상세 > 다른 공지 보기 > 목록 ($themeName)', (tester) async {
      await pumpNoticeApp(
        tester,
        theme: theme,
        api: FakeMetaApi(notices: [importantNotice, normalNotice]),
        initialLocation: AppRoutes.notices,
      );

      expect(find.text('중요'), findsOneWidget);
      expect(find.text('2026.10.18'), findsOneWidget);
      expect(find.text('2026.03.05'), findsOneWidget);
      // 미리보기는 마크다운 표기 제거
      expect(
        find.text('윈도우 함수 문제 20개가 추가됐어요. 문제 탭에서 바로 풀 수 있어요 자세히: 업데이트 안내'),
        findsOneWidget,
      );

      await tester.tap(find.text(normalNotice.title));
      await tester.pumpAndSettle();
      expect(find.text('02:00 ~ 04:00 동안 점검해요.'), findsOneWidget);

      // 목록에서 왔으면 다른 공지 보기 = 되돌아가기
      await tester.tap(find.text('다른 공지 보기'));
      await tester.pumpAndSettle();
      expect(find.text(importantNotice.title), findsOneWidget);
      expect(find.text('다른 공지 보기'), findsNothing);
    });
  }
}

/// 화면 RichText 안에서 글자가 [text] 인 조각 찾기
TextSpan? _findSpan(WidgetTester tester, String text) {
  TextSpan? found;
  for (final richText in tester.widgetList<RichText>(find.byType(RichText))) {
    richText.text.visitChildren((span) {
      if (span is TextSpan && span.text == text) found = span;
      return found == null;
    });
  }
  return found;
}
