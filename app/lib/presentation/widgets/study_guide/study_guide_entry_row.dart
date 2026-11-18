import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/utils/study_guide_progress.dart';
import '../../../router/app_routes.dart';
import '../../design/design.dart';
import '../../providers/study_guide_providers.dart';

/// 합격 로드맵 입구 행 (#1078, #1158): 홈 한 곳. 부제 = 지금 할 단계, 탭 > 로드맵 화면
class StudyGuideEntryRow extends ConsumerWidget {
  const StudyGuideEntryRow({super.key, this.hasHorizontalPadding = true});

  /// false: 이미 좌우 여백이 있는 구간 면 안 (홈 구간)
  final bool hasHorizontalPadding;

  static const String title = '합격 로드맵';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 로딩·실패는 기본 부제 (홈 전체를 막지 않음)
    final stageProgresses = ref.watch(studyGuideProgressProvider).valueOrNull;
    return PassqlListRow(
      title: title,
      subtitle: _subtitleOf(stageProgresses),
      leading: PassqlIconTile(
        icon: CupertinoIcons.map_fill,
        color: context.passqlColors.correct,
      ),
      hasChevron: true,
      hasHorizontalPadding: hasHorizontalPadding,
      onTap: () => context.push(AppRoutes.studyGuide),
    );
  }

  /// 진행 > 부제: 지금 단계 / 전부 끝 / 아직 모름
  static String _subtitleOf(List<StudyGuideStageProgress>? stageProgresses) {
    if (stageProgresses == null) return '합격까지 4단계로 안내해요';
    final currentStage = findCurrentStudyGuideStage(stageProgresses);
    if (currentStage == null) return '모든 단계를 마쳤어요';
    return '지금 ${toStudyGuideStageTitle(currentStage)}';
  }
}
