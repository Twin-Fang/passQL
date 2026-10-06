import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:passql_app/core/network/api_providers.dart';
import 'package:passql_app/data/models/report/report_models.dart';
import 'package:passql_app/data/sources/report_api.dart';
import 'package:passql_app/presentation/widgets/report/report_button.dart';

import '../../helpers/pump_app.dart';

/// 서버 대신 동작을 정해 둘 수 있는 가짜 신고 API.
class _FakeReportApi implements ReportApiClient {
  _FakeReportApi({this.reported = false, this.submitError});

  bool reported;
  DioException? submitError;
  final requests = <ReportRequest>[];
  int statusCalls = 0;

  @override
  Future<void> submitReport(String questionUuid, ReportRequest body) async {
    if (submitError != null) throw submitError!;
    requests.add(body);
    reported = true;
  }

  @override
  Future<ReportStatusResponse> getReportStatus(String questionUuid, String submissionUuid) async {
    statusCalls++;
    return ReportStatusResponse(reported: reported);
  }
}

DioException _serverError(int status, String code, String message) {
  final opts = RequestOptions(path: '/x');
  return DioException(
    requestOptions: opts,
    type: DioExceptionType.badResponse,
    response: Response(
      requestOptions: opts,
      statusCode: status,
      data: {'errorCode': code, 'message': message},
    ),
  );
}

Future<void> _open(WidgetTester tester, _FakeReportApi api) async {
  await pumpApp(
    tester,
    ProviderScope(
      overrides: [reportApiProvider.overrideWithValue(api)],
      child: const MaterialApp(
        home: Scaffold(
          body: ReportButton(
            questionUuid: 'q-1',
            submissionUuid: 'sub-1',
            choiceSetUuid: 'cs-1',
          ),
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('이미 신고한 제출은 신고 완료로 표시하고 누를 수 없다', (tester) async {
    await _open(tester, _FakeReportApi(reported: true));

    expect(find.text('신고 완료'), findsOneWidget);
    // TextButton.icon 은 내부 하위 타입이라 타입 일치 대신 술어로 찾는다.
    final button = tester.widget<TextButton>(find.byWidgetPredicate((w) => w is TextButton));
    expect(button.onPressed, isNull);
  });

  testWidgets('사유를 고르면 신고할 수 있고, 접수 후 신고 완료로 바뀐다', (tester) async {
    final api = _FakeReportApi();
    await _open(tester, api);

    await tester.tap(find.text('문제 신고'));
    await tester.pumpAndSettle();
    ElevatedButton submit() => tester.widget<ElevatedButton>(find.byType(ElevatedButton));
    expect(submit().onPressed, isNull); // 사유 선택 전

    await tester.tap(find.text('정답이 잘못된 것 같아요'));
    await tester.pump();
    expect(submit().onPressed, isNotNull);
    await tester.tap(find.text('신고하기'));
    await tester.pumpAndSettle();

    expect(api.requests, hasLength(1));
    expect(api.requests.single.submissionUuid, 'sub-1');
    expect(api.requests.single.choiceSetUuid, 'cs-1');
    expect(api.requests.single.categories, [ReportCategory.wrongAnswer]);
    expect(api.requests.single.detail, isNull);
    expect(find.text('신고 완료'), findsOneWidget);
    expect(find.text('신고가 접수됐어요. 확인 후 반영할게요'), findsOneWidget);
  });

  testWidgets('기타를 고르면 상세 내용 입력이 나타나고, 내용이 있어야 신고할 수 있다', (tester) async {
    // 상세 입력창이 열리면 시트가 길어지므로 화면을 키워 버튼이 보이게 한다.
    await tester.binding.setSurfaceSize(const Size(400, 1000));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    final api = _FakeReportApi();
    await _open(tester, api);
    await tester.tap(find.text('문제 신고'));
    await tester.pumpAndSettle();

    expect(find.byType(TextField), findsNothing);
    await tester.tap(find.text('기타'));
    await tester.pump();
    expect(find.byType(TextField), findsOneWidget);
    expect(tester.widget<ElevatedButton>(find.byType(ElevatedButton)).onPressed, isNull);

    await tester.enterText(find.byType(TextField), '  보기에 오타가 있어요  ');
    await tester.pump();
    await tester.tap(find.text('신고하기'));
    await tester.pumpAndSettle();

    expect(api.requests.single.categories, [ReportCategory.etc]);
    expect(api.requests.single.detail, '보기에 오타가 있어요');
  });

  testWidgets('전송에 실패하면 사유를 보여주고 시트를 유지한다', (tester) async {
    final api = _FakeReportApi(
      submitError: DioException(
        requestOptions: RequestOptions(path: '/x'),
        type: DioExceptionType.connectionError,
      ),
    );
    await _open(tester, api);
    await tester.tap(find.text('문제 신고'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('문제 내용이 이상해요'));
    await tester.pump();
    await tester.tap(find.text('신고하기'));
    await tester.pumpAndSettle();

    expect(find.text('네트워크 연결을 확인해 주세요.'), findsOneWidget);
    expect(find.text('신고하기'), findsOneWidget); // 시트 유지
  });

  testWidgets('이미 신고된 제출(409)은 성공으로 처리해 신고 완료로 바꾼다', (tester) async {
    final api = _FakeReportApi(
      submitError: _serverError(409, 'REPORT_ALREADY_EXISTS', '이미 신고한 제출입니다.'),
    );
    await _open(tester, api);
    await tester.tap(find.text('문제 신고'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('선택지가 이상해요'));
    await tester.pump();

    // 서버에는 이미 신고가 있으므로 상태 조회는 '신고됨'을 돌려준다.
    api.reported = true;
    await tester.tap(find.text('신고하기'));
    await tester.pumpAndSettle();

    expect(find.text('신고 완료'), findsOneWidget);
    expect(find.text('신고하기'), findsNothing);
  });
}
