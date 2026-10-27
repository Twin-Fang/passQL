// freezed 생성자 파라미터의 JsonKey 는 정상 사용법이라 경고를 끈다.
// ignore_for_file: invalid_annotation_target
import 'package:freezed_annotation/freezed_annotation.dart';

part 'concept_models.freezed.dart';
part 'concept_models.g.dart';

/// 개념 상태 3가지: 안 함, 읽음(확인 문제 미완료), 풀이 완료(확인 문제 전부 풂)
enum ConceptStatus {
  @JsonValue('NOT_STARTED')
  notStarted,
  @JsonValue('READ')
  read,
  @JsonValue('SOLVED')
  solved,
}

/// 개념 화면 모드: 읽기, 풀기(확인 문제)
enum ConceptStudyMode {
  @JsonValue('READ')
  read,
  @JsonValue('SOLVE')
  solve,
}

/// 읽기 깊이: 핵심만, 자세히
enum ConceptReadingDepth {
  @JsonValue('CORE')
  core,
  @JsonValue('DETAIL')
  detail,
}

/// GET /concepts/topics: 이용 가능 여부(공개 또는 미리보기 회원), 무료 단원 수, 단원들
@freezed
class ConceptTopicListResponse with _$ConceptTopicListResponse {
  const factory ConceptTopicListResponse({
    @Default(false) bool isAvailable,
    @Default(2) int freeTopicCount,
    @Default([]) List<ConceptTopicSummary> topics,
  }) = _ConceptTopicListResponse;

  factory ConceptTopicListResponse.fromJson(Map<String, dynamic> json) =>
      _$ConceptTopicListResponseFromJson(json);
}

/// 단원 1행: 순서(0부터), 개념 수, 완료 수, 잠금
@freezed
class ConceptTopicSummary with _$ConceptTopicSummary {
  const factory ConceptTopicSummary({
    required String topicUuid,
    required String displayName,
    @Default(0) int orderIndex,
    @Default(0) int conceptCount,
    @Default(0) int completedCount,
    @Default(false) bool isLocked,
  }) = _ConceptTopicSummary;

  factory ConceptTopicSummary.fromJson(Map<String, dynamic> json) =>
      _$ConceptTopicSummaryFromJson(json);
}

/// GET /concepts/topics/{topicUuid}: 단원의 개념 목록 (잠긴 단원도 제목·진행은 옴)
@freezed
class ConceptListResponse with _$ConceptListResponse {
  const factory ConceptListResponse({
    required String topicUuid,
    required String displayName,
    @Default(false) bool isLocked,
    @Default([]) List<ConceptSummary> concepts,
  }) = _ConceptListResponse;

  factory ConceptListResponse.fromJson(Map<String, dynamic> json) =>
      _$ConceptListResponseFromJson(json);
}

/// 단원 안 개념 1행
@freezed
class ConceptSummary with _$ConceptSummary {
  const factory ConceptSummary({
    required String conceptUuid,
    required String title,
    String? summary,
    @JsonKey(unknownEnumValue: ConceptStatus.notStarted)
    @Default(ConceptStatus.notStarted)
    ConceptStatus status,
    @Default(0) int checkCorrectCount,
    @Default(0) int checkQuestionCount,
  }) = _ConceptSummary;

  factory ConceptSummary.fromJson(Map<String, dynamic> json) =>
      _$ConceptSummaryFromJson(json);
}

/// GET /concepts/{conceptUuid}: 핵심만, 자세히 문단, 이웃 개념, 내 진행
@freezed
class ConceptDetailResponse with _$ConceptDetailResponse {
  const factory ConceptDetailResponse({
    required String conceptUuid,
    required String topicUuid,
    required String title,
    String? summary,
    String? coreMd,
    @Default([]) List<ConceptDetailSection> detailSections,
    String? previousConceptUuid,
    String? nextConceptUuid,
    @JsonKey(unknownEnumValue: ConceptStudyMode.read)
    @Default(ConceptStudyMode.read)
    ConceptStudyMode lastMode,
    @JsonKey(unknownEnumValue: ConceptReadingDepth.core)
    @Default(ConceptReadingDepth.core)
    ConceptReadingDepth lastDepth,
    @Default(false) bool isRead,
    @Default(0) int checkCorrectCount,
    @Default([]) List<String> relatedQuestionUuids,
  }) = _ConceptDetailResponse;

  factory ConceptDetailResponse.fromJson(Map<String, dynamic> json) =>
      _$ConceptDetailResponseFromJson(json);
}

/// 자세히 문단 1개 (anchor 는 확인 문제 '다시 읽기' 이동 지점)
@freezed
class ConceptDetailSection with _$ConceptDetailSection {
  const factory ConceptDetailSection({
    required String anchor,
    required String title,
    @Default('') String bodyMd,
  }) = _ConceptDetailSection;

  factory ConceptDetailSection.fromJson(Map<String, dynamic> json) =>
      _$ConceptDetailSectionFromJson(json);
}

/// 확인 문제 1개 (정답·풀이는 채점 응답에서만)
@freezed
class ConceptCheckQuestionResponse with _$ConceptCheckQuestionResponse {
  const factory ConceptCheckQuestionResponse({
    required String questionUuid,
    @Default(0) int sortOrder,
    required String stem,
    String? stemSql,
    @Default([]) List<ConceptCheckChoiceResponse> choices,
  }) = _ConceptCheckQuestionResponse;

  factory ConceptCheckQuestionResponse.fromJson(Map<String, dynamic> json) =>
      _$ConceptCheckQuestionResponseFromJson(json);
}

/// 확인 문제 보기
@freezed
class ConceptCheckChoiceResponse with _$ConceptCheckChoiceResponse {
  const factory ConceptCheckChoiceResponse({
    required String choiceKey,
    required String body,
  }) = _ConceptCheckChoiceResponse;

  factory ConceptCheckChoiceResponse.fromJson(Map<String, dynamic> json) =>
      _$ConceptCheckChoiceResponseFromJson(json);
}

/// POST /concepts/{conceptUuid}/check-questions/{questionUuid}/answer 요청
@freezed
class ConceptCheckAnswerRequest with _$ConceptCheckAnswerRequest {
  const factory ConceptCheckAnswerRequest({required String choiceKey}) =
      _ConceptCheckAnswerRequest;

  factory ConceptCheckAnswerRequest.fromJson(Map<String, dynamic> json) =>
      _$ConceptCheckAnswerRequestFromJson(json);
}

/// 채점 결과: 정답 여부·정답 키·풀이·다시 읽기 앵커·보기별 근거·개념 누적
@freezed
class ConceptCheckAnswerResponse with _$ConceptCheckAnswerResponse {
  const factory ConceptCheckAnswerResponse({
    @Default(false) bool isCorrect,
    required String correctKey,
    @Default('') String explanation,
    @Default('') String rereadAnchor,
    @Default({}) Map<String, String> rationaleByChoiceKey,
    @Default(0) int checkCorrectCount,
    @Default(0) int checkSolvedCount,
  }) = _ConceptCheckAnswerResponse;

  factory ConceptCheckAnswerResponse.fromJson(Map<String, dynamic> json) =>
      _$ConceptCheckAnswerResponseFromJson(json);
}

/// PUT /concepts/{conceptUuid}/progress 요청 (null 칸은 서버가 기존값 유지, 그대로 null 로 보냄)
@freezed
class ConceptProgressRequest with _$ConceptProgressRequest {
  const factory ConceptProgressRequest({
    bool? isRead,
    ConceptStudyMode? lastMode,
    ConceptReadingDepth? lastDepth,
  }) = _ConceptProgressRequest;

  factory ConceptProgressRequest.fromJson(Map<String, dynamic> json) =>
      _$ConceptProgressRequestFromJson(json);
}
