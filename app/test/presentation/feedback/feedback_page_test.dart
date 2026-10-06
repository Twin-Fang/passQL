import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:passql_app/core/network/api_providers.dart';
import 'package:passql_app/data/models/feedback/feedback_models.dart';
import 'package:passql_app/data/sources/feedback_api.dart';
import 'package:passql_app/presentation/pages/feedback/feedback_page.dart';

import '../../helpers/pump_app.dart';

/// 서버 대신 목록과 실패를 정해 둘 수 있는 가짜 건의 API.
class _FakeFeedbackApi implements FeedbackApiClient {
  _FakeFeedbackApi({List<FeedbackItem>? items, this.submitError, this.listError})
    : items = items ?? [];

  final List<FeedbackItem> items;
  DioException? submitError;
  DioException? listError;
  final submitted = <String>[];

  @override
  Future<void> submit(FeedbackSubmitRequest body) async {
    if (submitError != null) throw submitError!;
    submitted.add(body.content);
    items.add(
      FeedbackItem(
        feedbackUuid: 'f-${items.length}',
        content: body.content,
        createdAt: DateTime(2026, 10, 2, 16, items.length),
      ),
    );
  }

  @override
  Future<FeedbackListResponse> getMyFeedbacks() async {
    if (listError != null) throw listError!;
    return FeedbackListResponse(items: List.of(items));
  }
}

FeedbackItem _item(String uuid, String content, FeedbackStatus status, int minute) =>
    FeedbackItem(
      feedbackUuid: uuid,
      content: content,
      status: status,
      createdAt: DateTime(2026, 10, 2, 9, minute),
    );

Future<void> _open(WidgetTester tester, _FakeFeedbackApi api) async {
  await pumpApp(
    tester,
    ProviderScope(
      overrides: [feedbackApiProvider.overrideWithValue(api)],
      child: const MaterialApp(home: FeedbackPage()),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('보낸 건의가 없으면 안내 문구를 보여준다', (tester) async {
    await _open(tester, _FakeFeedbackApi());
    expect(find.textContaining('아직 보낸 건의가 없어요'), findsOneWidget);
  });

  testWidgets('건의를 오래된 순으로 보여주고 처리 상태를 함께 표시한다', (tester) async {
    final api = _FakeFeedbackApi(
      items: [
        _item('b', '두 번째', FeedbackStatus.applied, 30),
        _item('a', '첫 번째', FeedbackStatus.pending, 10),
      ],
    );
    await _open(tester, api);

    final first = tester.getTopLeft(find.text('첫 번째')).dy;
    final second = tester.getTopLeft(find.text('두 번째')).dy;
    expect(first, lessThan(second));
    expect(find.text('대기'), findsOneWidget);
    expect(find.text('반영됨'), findsOneWidget);
    expect(find.text('10월 2일 09:10'), findsOneWidget);
  });

  testWidgets('내용이 없으면 보낼 수 없고, 500자를 넘으면 글자 수를 경고한다', (tester) async {
    await _open(tester, _FakeFeedbackApi());
    IconButton send() => tester.widget<IconButton>(find.byType(IconButton));

    expect(send().onPressed, isNull);

    await tester.enterText(find.byType(TextField), '   ');
    await tester.pump();
    expect(send().onPressed, isNull);

    await tester.enterText(find.byType(TextField), '가' * 501);
    await tester.pump();
    expect(send().onPressed, isNull);
    expect(find.text('501/500'), findsOneWidget);

    await tester.enterText(find.byType(TextField), '좋아요');
    await tester.pump();
    expect(send().onPressed, isNotNull);
  });

  testWidgets('보내면 앞뒤 공백을 제거해 전송하고 입력을 비우며 목록에 나타난다', (tester) async {
    final api = _FakeFeedbackApi();
    await _open(tester, api);

    await tester.enterText(find.byType(TextField), '  다크모드 부탁해요  ');
    await tester.pump();
    await tester.tap(find.byType(IconButton));
    await tester.pumpAndSettle();

    expect(api.submitted, ['다크모드 부탁해요']);
    expect(find.text('다크모드 부탁해요'), findsOneWidget); // 말풍선
    expect(tester.widget<TextField>(find.byType(TextField)).controller!.text, isEmpty);
  });

  testWidgets('전송에 실패하면 사유를 보여주고 입력은 그대로 둔다', (tester) async {
    final api = _FakeFeedbackApi(
      submitError: DioException(
        requestOptions: RequestOptions(path: '/feedback'),
        type: DioExceptionType.connectionError,
      ),
    );
    await _open(tester, api);

    await tester.enterText(find.byType(TextField), '쓰던 내용');
    await tester.pump();
    await tester.tap(find.byType(IconButton));
    await tester.pumpAndSettle();

    expect(find.text('네트워크 연결을 확인해 주세요.'), findsOneWidget);
    expect(tester.widget<TextField>(find.byType(TextField)).controller!.text, '쓰던 내용');
  });

  testWidgets('목록을 못 불러오면 사유와 다시 시도를 보여준다', (tester) async {
    final api = _FakeFeedbackApi(
      listError: DioException(
        requestOptions: RequestOptions(path: '/feedback/me'),
        type: DioExceptionType.connectionTimeout,
      ),
    );
    await _open(tester, api);

    expect(find.text('응답이 늦어지고 있어요. 잠시 후 다시 시도해 주세요.'), findsOneWidget);
    expect(find.text('다시 시도'), findsOneWidget);
  });
}
