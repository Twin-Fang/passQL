import 'concept_models.dart';

/// 단원 이름 구분자: "2단원 · SELECT 기본" (만들기·짧은 이름 자르기 공통)
const String conceptUnitLabelSeparator = ' · ';

/// 단원 순번(0부터) + 이름 > "N단원 · 이름" (순번 없으면 이름만, 이름 없으면 "N단원")
String toConceptUnitLabel(int? orderIndex, {String? displayName}) {
  if (orderIndex == null) return displayName ?? '';
  final unitNumberLabel = '${orderIndex + 1}단원';
  return displayName == null
      ? unitNumberLabel
      : '$unitNumberLabel$conceptUnitLabelSeparator$displayName';
}

/// 단원 개념 목록 진행 집계
extension ConceptListProgress on ConceptListResponse {
  /// 풀이까지 끝낸 개념 수
  int get solvedConceptCount => concepts
      .where((concept) => concept.status == ConceptStatus.solved)
      .length;
}

/// 결과 화면 단원 줄 값: "N단원 · 이름", 이 개념을 열었을 때와 지금의 끝낸 개념 수, 단원 개념 수, 다음 단원 이름
class ConceptUnitProgress {
  const ConceptUnitProgress({
    required this.label,
    required this.solvedCountBefore,
    required this.solvedCount,
    required this.total,
    this.nextUnitLabel,
    this.nextUnitTopicUuid,
    this.overallSolvedCount = 0,
    this.overallTotal = 0,
  });

  final String label;
  final int solvedCountBefore;
  final int solvedCount;
  final int total;

  /// 전체 단원의 끝낸 개념 수와 개념 수 (점수판 "전체" 카드)
  final int overallSolvedCount;
  final int overallTotal;

  /// 이 개념을 열었을 때의 전체 끝낸 수 (단원 증가분만큼 되돌림)
  int get overallSolvedCountBefore =>
      overallSolvedCount - (solvedCount - solvedCountBefore);

  /// 다음 단원 짧은 이름 ("3단원"). 없으면 마지막 단원
  final String? nextUnitLabel;

  /// 다음 단원 uuid (단원 끝 한 장에서 바로 이동, 잠긴 단원은 건너뜀). 없으면 마지막 단원
  final String? nextUnitTopicUuid;

  bool get hasIncrease => solvedCount > solvedCountBefore;

  /// 이번 개념으로 단원을 다 끝냈는가 (단원 끝 한 장을 띄우는 조건)
  bool get isCompletedNow => hasIncrease && total > 0 && solvedCount >= total;

  /// "2단원 · SELECT 기본" > "2단원" (없으면 전체 이름)
  String get shortLabel => label.split(conceptUnitLabelSeparator).first;
}
