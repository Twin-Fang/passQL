/// 서버가 무료 응답에서 뺀 묶음 이름 2개 (응답 lockedSections 값)
abstract final class LockedSectionNames {
  // 실행 결과 표·SQL (제출 응답)
  static const String executionResult = 'EXECUTION_RESULT';
  // 정답 근거·핵심 개념·헷갈리는 지점·보기별 해설·시험 팁 (제출·해설 응답)
  static const String fullExplanation = 'FULL_EXPLANATION';
}

/// 응답 lockedSections 판정 (제출·해설 응답 공통)
extension LockedSectionList on List<String> {
  bool get isExecutionResultLocked =>
      contains(LockedSectionNames.executionResult);

  bool get isFullExplanationLocked =>
      contains(LockedSectionNames.fullExplanation);
}
