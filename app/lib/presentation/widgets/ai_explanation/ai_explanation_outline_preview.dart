import 'package:flutter/widgets.dart';

import '../../../data/models/ai/choice_explanation.dart';
import '../../../data/models/ai/explanation_outline.dart';
import '../../providers/ai_explanation_session_provider.dart';
import '../pro/locked_preview_samples.dart';
import 'ai_explanation_sections.dart';

/// 잠긴 상세 해설 미리보기 (#999): 서버 구성(섹션·항목 수·대략 글자 수) > 자리 글 해설 > 실제 해설과 같은 부품으로 그림
/// 판정 줄은 위에 이미 있어 빼고 그림, 글은 뜻 없는 자리 글뿐 (서버 본문 없음)
class AiExplanationOutlinePreview extends StatelessWidget {
  const AiExplanationOutlinePreview({
    super.key,
    required this.outline,
    required this.entry,
  });

  final ExplanationOutline outline;
  final AiExplanationEntry entry;

  @override
  Widget build(BuildContext context) {
    return AiExplanationSections(
      explanation: placeholderExplanationOf(outline, entry),
      entry: entry,
      isVerdictShown: false,
    );
  }
}

// 핵심 개념 이름 자리 글 길이
const int _keyConceptNamePlaceholderLength = 8;

/// 구성 > 자리 글로 채운 해설 (보기 키는 화면 순서 키, 정답·내 선택 표시는 이미 아는 값만)
ChoiceExplanation placeholderExplanationOf(
  ExplanationOutline outline,
  AiExplanationEntry entry,
) {
  List<int> characterCountsOf(ExplanationOutlineSectionKind kind) {
    for (final section in outline.sections) {
      if (section.kind == kind) return section.itemCharacterCounts;
    }
    return const [];
  }

  String firstPlaceholderOf(ExplanationOutlineSectionKind kind) {
    final characterCounts = characterCountsOf(kind);
    return characterCounts.isEmpty
        ? ''
        : LockedPreviewPlaceholder.textOfLength(characterCounts.first);
  }

  final choiceKeys = _choiceKeysOf(
    entry,
    characterCountsOf(ExplanationOutlineSectionKind.choiceAnalyses).length,
  );
  final analysisCharacterCounts = characterCountsOf(
    ExplanationOutlineSectionKind.choiceAnalyses,
  );
  return ChoiceExplanation(
    selectedChoiceKey: entry.request.selectedChoiceKey ?? '',
    correctChoiceKey: entry.correctChoiceKey ?? '',
    isSelectedCorrect: entry.isCorrect,
    correctReason: firstPlaceholderOf(
      ExplanationOutlineSectionKind.correctReason,
    ),
    examTip: firstPlaceholderOf(ExplanationOutlineSectionKind.examTip),
    keyConcepts: [
      for (final characterCount in characterCountsOf(
        ExplanationOutlineSectionKind.keyConcepts,
      ))
        KeyConcept(
          name: LockedPreviewPlaceholder.textOfLength(
            _keyConceptNamePlaceholderLength,
          ),
          description: LockedPreviewPlaceholder.textOfLength(characterCount),
        ),
    ],
    confusingPoints: [
      for (final characterCount in characterCountsOf(
        ExplanationOutlineSectionKind.confusingPoints,
      ))
        LockedPreviewPlaceholder.textOfLength(characterCount),
    ],
    choiceAnalyses: [
      for (var index = 0; index < analysisCharacterCounts.length; index++)
        ChoiceAnalysis(
          choiceKey: choiceKeys[index],
          isCorrect: choiceKeys[index] == entry.correctChoiceKey,
          reason: LockedPreviewPlaceholder.textOfLength(
            analysisCharacterCounts[index],
          ),
        ),
    ],
  );
}

/// 보기별 카드 키: 화면 순서 키가 개수와 맞으면 그 키, 아니면 A, B, C...
List<String> _choiceKeysOf(AiExplanationEntry entry, int choiceCount) {
  final displayedKeys = entry.displayLabelByChoiceKey.keys.toList();
  if (displayedKeys.length == choiceCount) return displayedKeys;
  return [
    for (var index = 0; index < choiceCount; index++)
      String.fromCharCode('A'.codeUnitAt(0) + index),
  ];
}
