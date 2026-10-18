import '../../../data/models/ai/choice_explanation.dart';
import '../../providers/ai_explanation_session_provider.dart';

/// 구조화 해설 > 판정 한 줄 (표시 라벨 기준)
/// 서버 verdict 는 choiceKey 로 조립돼 화면 라벨(#512)과 다를 수 있어 앱이 다시 조립
/// 정답: '정답 · {내 보기 이유}' / 오답: '오답 · B 선택, 정답은 A · {내 보기 이유}'
String composeAiExplanationVerdict(
  ChoiceExplanation explanation,
  AiExplanationEntry entry,
) {
  final selectedReason = selectedChoiceReasonOf(explanation);
  final reasonSuffix = selectedReason == null ? '' : ' · $selectedReason';
  if (explanation.isSelectedCorrect) return '정답$reasonSuffix';
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
