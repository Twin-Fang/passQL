import 'submit_result.dart';

/// 서버가 무료 응답에서 뺀 묶음 이름 2개 (응답 lockedSections 값)
abstract final class LockedSectionNames {
  // 실행 결과 표·SQL (제출 응답)
  static const String executionResult = 'EXECUTION_RESULT';
  // 정답 근거·핵심 개념·헷갈리는 지점·보기별 해설·시험 팁 (제출·해설 응답)
  static const String fullExplanation = 'FULL_EXPLANATION';
}

/// 제출 응답의 잠긴 묶음 판정
extension SubmitResultLockedSections on SubmitResult {
  bool get isExecutionResultLocked =>
      lockedSections.contains(LockedSectionNames.executionResult);

  bool get isFullExplanationLocked =>
      lockedSections.contains(LockedSectionNames.fullExplanation);
}
