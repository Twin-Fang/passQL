import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:passql_app/data/models/home/recommendations_request.dart';
import 'package:passql_app/data/models/member/choice_generation_mode.dart';
import 'package:passql_app/data/models/member/choice_mode_models.dart';
import 'package:passql_app/data/models/member/nickname_models.dart';
import 'package:passql_app/data/models/question/submit_request.dart';
import 'package:passql_app/data/models/feedback/feedback_models.dart';
import 'package:passql_app/data/sources/feedback_api.dart';
import 'package:passql_app/data/models/report/report_models.dart';
import 'package:passql_app/data/models/daily_set/daily_set_models.dart';
import 'package:passql_app/data/sources/daily_set_api.dart';
import 'package:passql_app/data/sources/member_api.dart';
import 'package:passql_app/data/sources/report_api.dart';
import 'package:passql_app/data/sources/progress_api.dart';
import 'package:passql_app/data/sources/question_api.dart';

/// 서버 계약(요청 형태)을 고정하는 테스트.
/// 응답 파싱이 아니라 "어떤 요청이 나가는가"만 본다.
class _Capture implements HttpClientAdapter {
  RequestOptions? last;

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    last = options;
    return ResponseBody.fromString(
      jsonEncode({}),
      200,
      headers: {
        Headers.contentTypeHeader: ['application/json'],
      },
    );
  }

  @override
  void close({bool force = false}) {}
}

void main() {
  late _Capture capture;
  late Dio dio;

  setUp(() {
    capture = _Capture();
    dio = Dio(BaseOptions(baseUrl: 'https://test'))..httpClientAdapter = capture;
  });

  // 응답 모델 파싱 실패는 이 테스트의 관심사가 아니다.
  Future<void> ignoreParse(Future<dynamic> call) async {
    try {
      await call;
    } catch (_) {}
  }

  test('추천 문제는 POST 본문으로 size 와 제외 목록을 보낸다', () async {
    await ignoreParse(
      QuestionApiClient(dio).getRecommendations(
        const RecommendationsRequest(size: 3, excludeQuestionUuids: ['a', 'b']),
      ),
    );

    expect(capture.last!.method, 'POST');
    expect(capture.last!.path, '/questions/recommendations');
    expect(capture.last!.data, {
      'size': 3,
      'excludeQuestionUuids': ['a', 'b'],
    });
    // 제외 목록이 쿼리스트링으로 쌓이면 헤더 한도(8KB)를 넘는다.
    expect(capture.last!.queryParameters, isEmpty);
  });

  test('답안 제출은 회원 헤더 없이 sessionUuid 를 본문에 싣는다', () async {
    await ignoreParse(
      QuestionApiClient(dio).submitAnswer(
        'q-1',
        const SubmitRequest(choiceSetId: 'cs', selectedChoiceKey: 'A', sessionUuid: 's-1'),
      ),
    );

    expect(capture.last!.path, '/questions/q-1/submit');
    expect(capture.last!.headers.keys, isNot(contains('X-Member-UUID')));
    // 실제 전송 형태(JSON)로 확인한다.
    final wire = jsonDecode(jsonEncode(capture.last!.data)) as Map;
    expect(wire['sessionUuid'], 's-1');
    expect(wire['selectedChoiceKey'], 'A');
    expect(wire['choiceSetId'], 'cs');
  });

  test('회원 식별용 memberUuid 를 쿼리로 보내지 않는다', () async {
    await ignoreParse(ProgressApiClient(dio).getProgress());
    expect(capture.last!.queryParameters.containsKey('memberUuid'), isFalse);

    await ignoreParse(ProgressApiClient(dio).getHeatmap(null, null));
    expect(capture.last!.queryParameters.containsKey('memberUuid'), isFalse);

    await ignoreParse(MemberApiClient(dio).getMe());
    expect(capture.last!.queryParameters.containsKey('memberUuid'), isFalse);
  });

  test('AI 코멘트는 연습 세션 단위로 조회할 수 있다', () async {
    await ignoreParse(ProgressApiClient(dio).getAiComment(sessionUuid: 's-9'));
    expect(capture.last!.path, '/progress/ai-comment');
    expect(capture.last!.queryParameters['sessionUuid'], 's-9');
  });

  test('닉네임 중복확인은 GET 쿼리, 변경은 PATCH 본문으로 보낸다', () async {
    await ignoreParse(MemberApiClient(dio).checkNickname('새닉네임'));
    expect(capture.last!.method, 'GET');
    expect(capture.last!.path, '/members/me/nickname/check');
    expect(capture.last!.queryParameters['nickname'], '새닉네임');

    await ignoreParse(
      MemberApiClient(dio).changeNickname(const NicknameChangeRequest('새닉네임')),
    );
    expect(capture.last!.method, 'PATCH');
    expect(capture.last!.path, '/members/me/nickname');
    expect(jsonDecode(jsonEncode(capture.last!.data)), {'nickname': '새닉네임'});
  });

  test('선택지 생성 모드는 서버 enum 이름으로 PATCH 한다', () async {
    for (final entry in {
      ChoiceGenerationMode.real: 'REAL',
      ChoiceGenerationMode.practice: 'PRACTICE',
    }.entries) {
      await ignoreParse(
        MemberApiClient(dio).updateChoiceGenerationMode(ChoiceModeRequest(entry.key)),
      );
      expect(capture.last!.method, 'PATCH');
      expect(capture.last!.path, '/members/me/settings/choice-generation-mode');
      expect(
        jsonDecode(jsonEncode(capture.last!.data)),
        {'choiceGenerationMode': entry.value},
      );
    }
  });

  test('오답 노트는 size 만 쿼리로 보낸다', () async {
    await ignoreParse(ProgressApiClient(dio).getWrongQuestions(size: 20));
    expect(capture.last!.path, '/progress/wrong-questions');
    expect(capture.last!.queryParameters, {'size': 20});
  });

  test('건의는 POST 본문의 content 로 보내고, 내 목록은 GET /feedback/me 로 받는다', () async {
    await ignoreParse(FeedbackApiClient(dio).submit(const FeedbackSubmitRequest('내용')));
    expect(capture.last!.method, 'POST');
    expect(capture.last!.path, '/feedback');
    expect(jsonDecode(jsonEncode(capture.last!.data)), {'content': '내용'});

    await ignoreParse(FeedbackApiClient(dio).getMyFeedbacks());
    expect(capture.last!.method, 'GET');
    expect(capture.last!.path, '/feedback/me');
  });

  test('신고는 POST 본문으로, 신고 여부는 submissionUuid 쿼리로 조회한다', () async {
    await ignoreParse(
      ReportApiClient(dio).submitReport(
        'q-1',
        const ReportRequest(
          submissionUuid: 'sub-1',
          categories: [ReportCategory.wrongAnswer],
        ),
      ),
    );
    expect(capture.last!.method, 'POST');
    expect(capture.last!.path, '/questions/q-1/report');
    expect(jsonDecode(jsonEncode(capture.last!.data)), {
      'submissionUuid': 'sub-1',
      'categories': ['WRONG_ANSWER'],
    });

    await ignoreParse(ReportApiClient(dio).getReportStatus('q-1', 'sub-1'));
    expect(capture.last!.method, 'GET');
    expect(capture.last!.path, '/questions/q-1/report/status');
    expect(capture.last!.queryParameters, {'submissionUuid': 'sub-1'});
  });

  test('데일리 세트는 오늘 조회, 완료 점수 등록, 순위 조회 요청을 보낸다', () async {
    await ignoreParse(DailySetApiClient(dio).getToday());
    expect(capture.last!.method, 'GET');
    expect(capture.last!.path, '/daily-set/today');

    await ignoreParse(
      DailySetApiClient(dio).complete(
        const DailySetCompleteRequest(correctCount: 4, sessionUuid: 's-1'),
      ),
    );
    expect(capture.last!.method, 'POST');
    expect(capture.last!.path, '/daily-set/complete');
    expect(jsonDecode(jsonEncode(capture.last!.data)), {'correctCount': 4, 'sessionUuid': 's-1'});

    await ignoreParse(DailySetApiClient(dio).getLeaderboard());
    expect(capture.last!.method, 'GET');
    expect(capture.last!.path, '/daily-set/leaderboard');
  });

  test('답안 제출 시 세션 UUID 를 함께 보낸다 (데일리 세트 풀이)', () async {
    await ignoreParse(
      QuestionApiClient(dio).submitAnswer(
        'q-1',
        const SubmitRequest(choiceSetId: 'cs', selectedChoiceKey: 'A', sessionUuid: 'sess-1'),
      ),
    );
    final wire = jsonDecode(jsonEncode(capture.last!.data)) as Map;
    expect(wire['sessionUuid'], 'sess-1');
  });
}
