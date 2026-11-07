import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';
import '../models/progress/progress_response.dart';
import '../models/progress/heatmap_response.dart';
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

  /// 최근 오답 노트. 같은 문제는 가장 최근 오답 시각 기준으로 한 번만 내려온다.
  @GET('/progress/wrong-questions')
  Future<WrongQuestionsResponse> getWrongQuestions({
    @Query('size') int? size,
  });

  /// 학습 패턴: 최근 4주 날짜별 풀이, 최근 12주 요일·시간대 분포, 학습일·최장 연속 (#909, 무료)
  @GET('/progress/study-pattern')
  Future<StudyPatternResponse> getStudyPattern();

  /// 정답률 상세: 난이도별 정답률, 오답 정리, 주별 남은 오답 (#909, 프로 > 무료는 403)
  @GET('/progress/accuracy-detail')
  Future<AccuracyDetailResponse> getAccuracyDetail();
}
