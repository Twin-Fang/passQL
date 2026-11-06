import 'package:freezed_annotation/freezed_annotation.dart';

/// SQLD 과목 2개 (서버 MockExamSubject) + 앱이 모르는 값
enum MockExamSubject {
  @JsonValue('SUBJECT_ONE')
  subjectOne,
  @JsonValue('SUBJECT_TWO')
  subjectTwo,
  unknown,
}

/// 응시 상태: 풀이 중, 채점 끝 + 앱이 모르는 값
enum MockExamAttemptStatus {
  @JsonValue('IN_PROGRESS')
  inProgress,
  @JsonValue('SUBMITTED')
  submitted,
  unknown,
}

/// 회차 시작 불가 이유 3개: 이용권 필요, 무료 체험 소진, 다른 회차 풀이 중 + 앱이 모르는 값
enum MockExamStartBlockReason {
  @JsonValue('PRO_REQUIRED')
  proRequired,
  @JsonValue('FREE_TRIAL_USED')
  freeTrialUsed,
  @JsonValue('OTHER_ATTEMPT_IN_PROGRESS')
  otherAttemptInProgress,
  unknown,
}

/// 불합격 이유: 합격, 과락(우선), 총점 60점 미만 + 앱이 모르는 값
enum MockExamFailReason {
  @JsonValue('NONE')
  none,
  @JsonValue('SUBJECT_FAIL')
  subjectFail,
  @JsonValue('TOTAL_SCORE_BELOW')
  totalScoreBelow,
  unknown,
}

/// 채점 계기: 회원 제출, 시간 끝 자동 제출 + 앱이 모르는 값
enum MockExamSubmitReason {
  @JsonValue('MEMBER')
  member,
  @JsonValue('TIME_UP')
  timeUp,
  unknown,
}
