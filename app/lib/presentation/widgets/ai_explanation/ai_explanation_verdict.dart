import '../../../data/models/ai/choice_explanation.dart';
import '../../../data/models/question/locked_section_names.dart';
import '../../providers/ai_explanation_session_provider.dart';

/// 구조화 해설 > 판정 한 줄 (표시 라벨 기준)
/// 서버 verdict 는 choiceKey 로 조립돼 화면 라벨(#512)과 다를 수 있어 앱이 다시 조립
/// 정답: '정답 · {내 보기 이유}' / 오답: '오답 · B 선택, 정답은 A · {내 보기 이유}' (보기 키를 모르면 '오답')
String composeAiExplanationVerdict(
  ChoiceExplanation explanation,
  AiExplanationEntry entry,
) {
  final selectedReason = selectedChoiceReasonOf(explanation);
  final reasonSuffix = selectedReason == null ? '' : ' · $selectedReason';
  if (explanation.isSelectedCorrect) return '정답$reasonSuffix';
  if (explanation.selectedChoiceKey.isEmpty ||
      explanation.correctChoiceKey.isEmpty) {
    return '오답$reasonSuffix';
  }
  final selectedLabel = entry.displayLabelOf(explanation.selectedChoiceKey);
  final correctLabel = entry.displayLabelOf(explanation.correctChoiceKey);
  return '오답 · $selectedLabel 선택, 정답은 $correctLabel$reasonSuffix';
}

/// 고른 보기의 판정 이유 (없으면 null)
String? selectedChoiceReasonOf(ChoiceExplanation explanation) {
  for (final analysis in explanation.choiceAnalyses) {
    if (analysis.choiceKey == explanation.selectedChoiceKey &&
        analysis.reason.trim().isNotEmpty) {
      return analysis.reason.trim();
    }
  }
  return null;
}

/// 판정만 남긴 해설 (이유 없음): 제출 결과 정오·고른 키·정답 키로 조립
/// 무료 회원에게 서버가 판정까지 비워 보내거나 해설 생성이 실패했을 때 판정 한 줄 자리 (#867)
ChoiceExplanation verdictOnlyExplanationOf(AiExplanationEntry entry) =>
    ChoiceExplanation(
      selectedChoiceKey: entry.request.selectedChoiceKey ?? '',
      correctChoiceKey: entry.correctChoiceKey ?? '',
      isSelectedCorrect: entry.isCorrect,
    );

/// 무료 판정 한 줄 자리로 대신할지: 제출 응답에서 해설 묶음이 잠겼고(무료, 결제 UI 대상) 보여 줄 글이 없음
bool shouldShowVerdictOnlyFor(
  AiExplanationEntry entry, {
  required bool shouldShowProUi,
  required String? fallbackText,
}) =>
    shouldShowProUi &&
    entry.request.initialLockedSections.isFullExplanationLocked &&
    (fallbackText?.trim().isEmpty ?? true);
