// freezed 생성자 파라미터의 JsonKey 는 정상 사용법이라 경고를 끈다.
// ignore_for_file: invalid_annotation_target
import 'package:freezed_annotation/freezed_annotation.dart';

import 'ai_stats_analysis.dart';

part 'ai_comment_response.freezed.dart';
part 'ai_comment_response.g.dart';

/// GET /progress/ai-comment 응답.
/// comment: AI 생성 한국어 코멘트 (Redis 캐시 24h), analysis: 통계 구조화 분석 (결과 화면 코멘트면 null, #861)
@freezed
class AiCommentResponse with _$AiCommentResponse {
  const factory AiCommentResponse({
    // 옛 앱 호환 글 코멘트 (analysis 없을 때 표시)
    required String comment,
    String? generatedAt,
    AiStatsAnalysis? analysis,
  }) = _AiCommentResponse;

  factory AiCommentResponse.fromJson(Map<String, dynamic> json) =>
      _$AiCommentResponseFromJson(json);
}
