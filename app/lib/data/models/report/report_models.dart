import 'package:json_annotation/json_annotation.dart';

/// 신고 사유. 서버 `ReportCategory` 와 대응.
enum ReportCategory {
  @JsonValue('WRONG_ANSWER')
  wrongAnswer('정답이 잘못된 것 같아요'),
  @JsonValue('WEIRD_QUESTION')
  weirdQuestion('문제 내용이 이상해요'),
  @JsonValue('WEIRD_CHOICES')
  weirdChoices('선택지가 이상해요'),
  @JsonValue('WEIRD_EXECUTION')
  weirdExecution('SQL 실행 결과가 이상해요'),
  @JsonValue('ETC')
  etc('기타');

  const ReportCategory(this.label);

  /// 화면에 보여줄 문구.
  final String label;

  /// 서버로 보내는 값.
  String get serverValue => switch (this) {
    ReportCategory.wrongAnswer => 'WRONG_ANSWER',
    ReportCategory.weirdQuestion => 'WEIRD_QUESTION',
    ReportCategory.weirdChoices => 'WEIRD_CHOICES',
    ReportCategory.weirdExecution => 'WEIRD_EXECUTION',
    ReportCategory.etc => 'ETC',
  };
}

/// `POST /questions/{questionUuid}/report` 요청.
class ReportRequest {
  const ReportRequest({
    required this.submissionUuid,
    required this.categories,
    this.choiceSetUuid,
    this.detail,
  });

  /// 어떤 제출에 대한 신고인지. 같은 제출은 한 번만 신고할 수 있다.
  final String submissionUuid;
  final List<ReportCategory> categories;
  final String? choiceSetUuid;

  /// '기타'를 골랐을 때의 상세 내용.
  final String? detail;

  Map<String, dynamic> toJson() => {
    'submissionUuid': submissionUuid,
    'categories': [for (final c in categories) c.serverValue],
    // 값이 없는 선택 항목은 아예 보내지 않는다.
    'choiceSetUuid': ?choiceSetUuid,
    'detail': ?detail,
  };
}

/// `GET /questions/{questionUuid}/report/status` 응답.
class ReportStatusResponse {
  const ReportStatusResponse({required this.reported});

  final bool reported;

  factory ReportStatusResponse.fromJson(Map<String, dynamic> json) =>
      ReportStatusResponse(reported: json['reported'] as bool? ?? false);
}
