import 'package:flutter/cupertino.dart';

import '../../../core/utils/study_guide_progress.dart';
import '../../design/design.dart';

/// 학습 가이드 단계 행 (#1078): 단계 아이콘 타일 + 단계 이름 + 설명·진행(n/N 회차) + 상태 배지 + 화살표
/// 지금 할 단계는 "지금" 배지, 준비 중 단계는 눌러도 이동 없음
class StudyGuideStageRow extends StatelessWidget {
  const StudyGuideStageRow({
    super.key,
    required this.icon,
    required this.title,
    required this.description,
    required this.progress,
    required this.isCurrentStage,
    required this.notReadyText,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String description;
  final StudyGuideStageProgress progress;
  final bool isCurrentStage;

  /// 준비 중(열린 회차 없음)일 때 둘째 줄 문구
  final String notReadyText;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.passqlColors;
    final isNotReady = progress.status == StudyGuideStageStatus.notReady;
    return PassqlListRow(
      title: title,
      subtitle: isNotReady ? notReadyText : '$description | $_progressText',
      leading: PassqlIconTile(
        icon: icon,
        color: isNotReady ? colors.secondaryLabel : colors.accent,
      ),
      trailing: _statusBadge,
      hasChevron: !isNotReady,
      onTap: isNotReady ? null : onTap,
    );
  }

  String get _progressText =>
      '${progress.touchedRoundCount}/${progress.totalRoundCount}회차';

  /// 상태 배지: 지금 할 단계 > 완료 > 진행 중 (시작 전·준비 중은 없음)
  Widget? get _statusBadge {
    if (isCurrentStage) {
      return const PassqlBadge(text: '지금', kind: PassqlBadgeKind.warning);
    }
    return switch (progress.status) {
      StudyGuideStageStatus.done => const PassqlBadge(
        text: '완료',
        kind: PassqlBadgeKind.success,
      ),
      StudyGuideStageStatus.inProgress => const PassqlBadge(
        text: '진행 중',
        kind: PassqlBadgeKind.neutral,
      ),
      _ => null,
    };
  }
}
