import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';
import '../models/progress/progress_response.dart';
import '../models/progress/heatmap_response.dart';
import '../models/progress/expected_pass_response.dart';
import '../models/progress/topic_analysis_response.dart';
import '../models/progress/wrong_questions_response.dart';
import '../models/progress/ai_comment_response.dart';
import '../models/progress/accuracy_detail_response.dart';
import '../models/progress/study_pattern_response.dart';

part 'progress_api.g.dart';

@RestApi()
abstract class ProgressApiClient {
  factory ProgressApiClient(Dio dio, {String baseUrl}) = _ProgressApiClient;

  /// 전체 학습 현황.
  @GET('/progress')
  Future<ProgressResponse> getProgress();

  /// 예상 합격률: 최근 모의고사 최대 5회 기준 + 공식 합격률 (#1086, 무료 공개)
  @GET('/progress/expected-pass')
  Future<ExpectedPassResponse> getExpectedPass();

  /// 날짜별 학습 히트맵.
  @GET('/progress/heatmap')
  Future<HeatmapResponse> getHeatmap(
    @Query('from') String? from,
    @Query('to') String? to,
  );

  /// 토픽별 정답률/문제수 분석 (레이더 차트 + 막대 차트용).
  @GET('/progress/topic-analysis')
  Future<TopicAnalysisResponse> getTopicAnalysis();

  /// AI 영역 분석 코멘트 (Redis 24h 캐시, AI 호출 latency 있음).
  @GET('/progress/ai-comment')
  Future<AiCommentResponse> getAiComment({
    @Query('sessionUuid') String? sessionUuid,
  });

  /// 오답 노트. 같은 문제는 한 번만, 기본은 정리 안 된 오답 최근 틀린 순 (#1081)
  /// subject: SUBJECT_ONE | SUBJECT_TWO (없으면 전체), sort: RECENT | MOST_WRONG
  @GET('/progress/wrong-questions')
  Future<WrongQuestionsResponse> getWrongQuestions({
    @Query('size') int? size,
    @Query('subject') String? subject,
    @Query('sort') String? sort,
    @Query('includeResolved') bool? includeResolved,
  });

  /// 오답 다시 풀기 묶음: 정리 안 된 오답 많이 틀린 순 최대 10개 (#1081, 프로)
  @GET('/progress/wrong-questions/retry-set')
  Future<WrongQuestionRetrySetResponse> getWrongQuestionRetrySet({
    @Query('subject') String? subject,
    @Query('size') int? size,
  });

  /// 학습 패턴: 최근 4주 날짜별 풀이, 최근 12주 요일·시간대 분포, 학습일·최장 연속 (#909, 무료)
  @GET('/progress/study-pattern')
  Future<StudyPatternResponse> getStudyPattern();

  /// 정답률 상세: 난이도별 정답률, 오답 정리, 주별 남은 오답 (#909, 프로 > 무료는 403)
  @GET('/progress/accuracy-detail')
  Future<AccuracyDetailResponse> getAccuracyDetail();
}
