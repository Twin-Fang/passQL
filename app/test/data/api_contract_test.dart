import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:passql_app/core/error/app_exception.dart';
import 'package:passql_app/core/error/error_code.dart';
import 'package:passql_app/data/community/community_image_compressor.dart';
import 'package:passql_app/data/image/webp_image_compressor.dart';
import 'package:passql_app/data/models/home/recommendations_request.dart';
import 'package:passql_app/data/models/member/choice_generation_mode.dart';
import 'package:passql_app/data/models/member/choice_mode_models.dart';
import 'package:passql_app/data/models/member/nickname_models.dart';
import 'package:passql_app/data/models/question/submit_request.dart';
import 'package:passql_app/data/models/community/community_models.dart';
import 'package:passql_app/data/sources/ai_api.dart';
import 'package:passql_app/data/sources/community_api.dart';
import 'package:passql_app/data/sources/feedback_api.dart';
import 'package:passql_app/data/models/report/report_models.dart';
import 'package:passql_app/data/models/daily_set/daily_set_models.dart';
import 'package:passql_app/data/sources/daily_set_api.dart';
import 'package:passql_app/data/sources/member_api.dart';
import 'package:passql_app/data/sources/report_api.dart';
import 'package:passql_app/data/sources/progress_api.dart';
import 'package:passql_app/data/sources/question_api.dart';

import '../helpers/fakes/fake_http_client_adapter.dart';

/// 서버 계약(요청 형태)을 고정하는 테스트.
/// 응답 파싱이 아니라 "어떤 요청이 나가는가"만 본다.
void main() {
  late FakeHttpClientAdapter adapter;
  late Dio dio;

  setUp(() {
    adapter = FakeHttpClientAdapter.emptyJson();
    dio = Dio(BaseOptions(baseUrl: 'https://test'))
      ..httpClientAdapter = adapter;
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

    expect(adapter.lastRequest.method, 'POST');
    expect(adapter.lastRequest.path, '/questions/recommendations');
    expect(adapter.lastRequest.data, {
      'size': 3,
      'excludeQuestionUuids': ['a', 'b'],
    });
    // 제외 목록이 쿼리스트링으로 쌓이면 헤더 한도(8KB)를 넘는다.
    expect(adapter.lastRequest.queryParameters, isEmpty);
  });

  test('답안 제출은 회원 헤더 없이 sessionUuid 를 본문에 싣는다', () async {
    await ignoreParse(
      QuestionApiClient(dio).submitAnswer(
        'q-1',
        const SubmitRequest(
          choiceSetId: 'cs',
          selectedChoiceKey: 'A',
          sessionUuid: 's-1',
        ),
      ),
    );

    expect(adapter.lastRequest.path, '/questions/q-1/submit');
    expect(adapter.lastRequest.headers.keys, isNot(contains('X-Member-UUID')));
    // 실제 전송 형태(JSON)로 확인한다.
    final wire = jsonDecode(jsonEncode(adapter.lastRequest.data)) as Map;
    expect(wire['sessionUuid'], 's-1');
    expect(wire['selectedChoiceKey'], 'A');
    expect(wire['choiceSetId'], 'cs');
  });

  test('회원 식별용 memberUuid 를 쿼리로 보내지 않는다', () async {
    await ignoreParse(ProgressApiClient(dio).getProgress());
    expect(
      adapter.lastRequest.queryParameters.containsKey('memberUuid'),
      isFalse,
    );

    await ignoreParse(ProgressApiClient(dio).getHeatmap(null, null));
    expect(
      adapter.lastRequest.queryParameters.containsKey('memberUuid'),
      isFalse,
    );

    await ignoreParse(MemberApiClient(dio).getMe());
    expect(
      adapter.lastRequest.queryParameters.containsKey('memberUuid'),
      isFalse,
    );
  });

  test('AI 코멘트는 연습 세션 단위로 조회할 수 있다', () async {
    await ignoreParse(ProgressApiClient(dio).getAiComment(sessionUuid: 's-9'));
    expect(adapter.lastRequest.path, '/progress/ai-comment');
    expect(adapter.lastRequest.queryParameters['sessionUuid'], 's-9');
  });

  test('닉네임 중복확인은 GET 쿼리, 변경은 PATCH 본문으로 보낸다', () async {
    await ignoreParse(MemberApiClient(dio).checkNickname('새닉네임'));
    expect(adapter.lastRequest.method, 'GET');
    expect(adapter.lastRequest.path, '/members/me/nickname/check');
    expect(adapter.lastRequest.queryParameters['nickname'], '새닉네임');

    await ignoreParse(
      MemberApiClient(dio).changeNickname(const NicknameChangeRequest('새닉네임')),
    );
    expect(adapter.lastRequest.method, 'PATCH');
    expect(adapter.lastRequest.path, '/members/me/nickname');
    expect(jsonDecode(jsonEncode(adapter.lastRequest.data)), {
      'nickname': '새닉네임',
    });
  });

  test('선택지 생성 모드는 서버 enum 이름으로 PATCH 한다', () async {
    for (final entry in {
      ChoiceGenerationMode.real: 'REAL',
      ChoiceGenerationMode.practice: 'PRACTICE',
    }.entries) {
      await ignoreParse(
        MemberApiClient(
          dio,
        ).updateChoiceGenerationMode(ChoiceModeRequest(entry.key)),
      );
      expect(adapter.lastRequest.method, 'PATCH');
      expect(
        adapter.lastRequest.path,
        '/members/me/settings/choice-generation-mode',
      );
      expect(jsonDecode(jsonEncode(adapter.lastRequest.data)), {
        'choiceGenerationMode': entry.value,
      });
    }
  });

  test('구조화 해설은 GET 쿼리로 문제·세트·보기를 보내고, 모르는 값은 빼고 보낸다 (#521)', () async {
    await ignoreParse(
      AiApiClient(dio).getChoiceExplanation(
        'q-1',
        choiceSetUuid: 'set-1',
        selectedChoiceKey: 'B',
      ),
    );
    expect(adapter.lastRequest.method, 'GET');
    expect(adapter.lastRequest.path, '/ai/choice-explanation');
    expect(adapter.lastRequest.queryParameters, {
      'questionUuid': 'q-1',
      'choiceSetUuid': 'set-1',
      'selectedChoiceKey': 'B',
    });

    await ignoreParse(AiApiClient(dio).getChoiceExplanation('q-1'));
    expect(adapter.lastRequest.queryParameters, {'questionUuid': 'q-1'});
  });

  test('오답 노트는 size 만 쿼리로 보낸다', () async {
    await ignoreParse(ProgressApiClient(dio).getWrongQuestions(size: 20));
    expect(adapter.lastRequest.path, '/progress/wrong-questions');
    expect(adapter.lastRequest.queryParameters, {'size': 20});
  });

  test(
    '건의는 POST /feedback 에 multipart 로 보낸다 (request 파트 + images 파트)',
    () async {
      final formData = FormData.fromMap({
        'request': MultipartFile.fromString(
          '{"content":"내용"}',
          contentType: DioMediaType('application', 'json'),
        ),
        'images': [
          MultipartFile.fromBytes(
            [1, 2, 3],
            filename: '0.webp',
            contentType: DioMediaType('image', 'webp'),
          ),
        ],
      });
      await ignoreParse(FeedbackApiClient(dio).submit(formData));
      expect(adapter.lastRequest.method, 'POST');
      expect(adapter.lastRequest.path, '/feedback');
      expect(adapter.lastRequest.data, isA<FormData>());
      expect(
        (adapter.lastRequest.data as FormData).files.map((part) => part.key),
        ['request', 'images'],
      );
    },
  );

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
    expect(adapter.lastRequest.method, 'POST');
    expect(adapter.lastRequest.path, '/questions/q-1/report');
    expect(jsonDecode(jsonEncode(adapter.lastRequest.data)), {
      'submissionUuid': 'sub-1',
      'categories': ['WRONG_ANSWER'],
    });

    await ignoreParse(ReportApiClient(dio).getReportStatus('q-1', 'sub-1'));
    expect(adapter.lastRequest.method, 'GET');
    expect(adapter.lastRequest.path, '/questions/q-1/report/status');
    expect(adapter.lastRequest.queryParameters, {'submissionUuid': 'sub-1'});
  });

  test('데일리 세트는 오늘 조회, 완료 점수 등록, 순위 조회 요청을 보낸다', () async {
    await ignoreParse(DailySetApiClient(dio).getToday());
    expect(adapter.lastRequest.method, 'GET');
    expect(adapter.lastRequest.path, '/daily-set/today');

    await ignoreParse(
      DailySetApiClient(dio).complete(
        const DailySetCompleteRequest(correctCount: 4, sessionUuid: 's-1'),
      ),
    );
    expect(adapter.lastRequest.method, 'POST');
    expect(adapter.lastRequest.path, '/daily-set/complete');
    expect(jsonDecode(jsonEncode(adapter.lastRequest.data)), {
      'correctCount': 4,
      'sessionUuid': 's-1',
    });

    await ignoreParse(DailySetApiClient(dio).getLeaderboard());
    expect(adapter.lastRequest.method, 'GET');
    expect(adapter.lastRequest.path, '/daily-set/leaderboard');
  });

  test('답안 제출 시 세션 UUID 를 함께 보낸다 (데일리 세트 풀이)', () async {
    await ignoreParse(
      QuestionApiClient(dio).submitAnswer(
        'q-1',
        const SubmitRequest(
          choiceSetId: 'cs',
          selectedChoiceKey: 'A',
          sessionUuid: 'sess-1',
        ),
      ),
    );
    final wire = jsonDecode(jsonEncode(adapter.lastRequest.data)) as Map;
    expect(wire['sessionUuid'], 'sess-1');
  });

  test('커뮤니티: 피드 쿼리, 의견 작성·신고 본문, 좋아요 메서드', () async {
    await ignoreParse(
      CommunityApiClient(
        dio,
      ).getFeed(source: CommunityFeedSource.solved.serverValue),
    );
    expect(adapter.lastRequest.path, '/community/feed');
    expect(adapter.lastRequest.queryParameters, {'source': 'solved'});

    await ignoreParse(
      CommunityApiClient(dio).createQuestionPost(
        'q-1',
        const CommunityPostCreateRequest(
          content: '헷갈려요',
          includeSolveSnapshot: true,
        ),
      ),
    );
    expect(adapter.lastRequest.method, 'POST');
    expect(adapter.lastRequest.path, '/community/questions/q-1/posts');
    expect(jsonDecode(jsonEncode(adapter.lastRequest.data)), {
      'content': '헷갈려요',
      'includeSolveSnapshot': true,
    });

    await ignoreParse(
      CommunityApiClient(dio).reportPost(
        'p-1',
        CommunityReportRequest(
          category: CommunityReportCategory.answerSpoiler.serverValue,
        ),
      ),
    );
    expect(adapter.lastRequest.path, '/community/posts/p-1/report');
    expect(jsonDecode(jsonEncode(adapter.lastRequest.data)), {
      'category': 'ANSWER_SPOILER',
    });

    await ignoreParse(CommunityApiClient(dio).toggleLike('p-1'));
    expect(adapter.lastRequest.method, 'PUT');
    expect(adapter.lastRequest.path, '/community/posts/p-1/like');
  });

  group('커뮤니티 이미지', () {
    // 가짜 WebP: RIFF + 크기 + WEBP 헤더 뒤에 지정 용량만큼 채움
    Uint8List fakeWebp(int length) {
      final bytes = Uint8List(length);
      bytes.setRange(0, 4, 'RIFF'.codeUnits);
      bytes.setRange(8, 12, 'WEBP'.codeUnits);
      return bytes;
    }

    // 썸네일 크기(10KB)의 가짜 WebP 는 320x213, 그 외는 1200x800
    Future<({int width, int height})> readFixedDimensions(
      Uint8List bytes,
    ) async => bytes.length == 10 * 1024
        ? (width: 320, height: 213)
        : (width: 1200, height: 800);

    test('품질 80 > 65 > 50 순으로 낮춰 500KB 이하가 되면 멈추고, 3회 모두 넘으면 한국어 안내', () async {
      final triedQualities = <int>[];
      final compressor = CommunityImageCompressor(
        webpCompressor: WebpImageCompressor(
          readDimensions: readFixedDimensions,
          encodeWebp:
              (
                source, {
                required minWidth,
                required minHeight,
                required quality,
              }) async {
                triedQualities.add(quality);
                // 원본 압축은 품질 50 에서만 한도 이하, 썸네일 압축(작은 한도)은 항상 통과
                if (minWidth <= CommunityImageLimits.thumbnailLongSidePixels) {
                  return fakeWebp(10 * 1024);
                }
                return fakeWebp(quality == 50 ? 400 * 1024 : 900 * 1024);
              },
        ),
      );
      final compressed = await compressor.compress(Uint8List(8));
      expect(triedQualities.take(3), [80, 65, 50]);
      expect(WebpImageCompressor.isWebpBytes(compressed.imageBytes), isTrue);
      expect(
        compressed.imageBytes.length,
        lessThanOrEqualTo(CommunityImageLimits.imageMaxBytes),
      );

      final alwaysTooLarge = CommunityImageCompressor(
        webpCompressor: WebpImageCompressor(
          readDimensions: readFixedDimensions,
          encodeWebp:
              (
                source, {
                required minWidth,
                required minHeight,
                required quality,
              }) async => fakeWebp(900 * 1024),
        ),
      );
      expect(
        alwaysTooLarge.compress(Uint8List(8)),
        throwsA(
          isA<AppException>().having(
            (e) => e.message,
            'message',
            contains('용량'),
          ),
        ),
      );
      // WebP 가 아닌 결과(매직바이트 불일치)는 거절
      expect(WebpImageCompressor.isWebpBytes(Uint8List(32)), isFalse);
      // EXIF 청크가 남은 WebP 는 감지
      final withExif = BytesBuilder()
        ..add(fakeWebp(12))
        ..add('EXIF'.codeUnits)
        ..add([2, 0, 0, 0, 0, 0]);
      expect(WebpImageCompressor.hasExifChunk(withExif.toBytes()), isTrue);
    });

    test('업로드는 첨부 순서대로 1장씩, 이미 올라간 장은 건너뛰고 실패하면 이후 장을 올리지 않는다', () async {
      CompressedCommunityImage image() => CompressedCommunityImage(
        imageBytes: fakeWebp(16),
        thumbnailBytes: fakeWebp(16),
        width: 1,
        height: 1,
      );
      final drafts = [
        CommunityImageDraft(image()),
        CommunityImageDraft(image()),
      ];
      var uploadCallCount = 0;

      // 1장째 성공, 2장째 실패
      await expectLater(
        uploadCommunityImageDrafts(drafts, (_) async {
          uploadCallCount++;
          if (uploadCallCount == 2) {
            throw const AppException(
              code: ErrorCode.rateLimited,
              message: '잠시 후 다시',
            );
          }
          return 'image-$uploadCallCount';
        }),
        throwsA(isA<AppException>()),
      );
      expect(drafts.map((d) => d.uploadedImageUuid), ['image-1', null]);

      // 재시도: 1장째는 건너뛰고 2장째만 올림
      final uuids = await uploadCommunityImageDrafts(
        drafts,
        (_) async => 'image-retry',
      );
      expect(uuids, ['image-1', 'image-retry']);
    });
  });
}
