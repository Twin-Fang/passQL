import 'package:flutter/cupertino.dart';
import 'package:go_router/go_router.dart';

import '../../../core/utils/number_format.dart';
import '../../../data/models/exam_answer/exam_answer_enums.dart';
import '../../../data/models/exam_answer/exam_answer_round_response.dart';
import '../../../router/app_routes.dart';
import '../../design/design.dart';
import '../exam_answer/exam_answer_status_styles.dart';

/// 홈 가답안 구간 (#1075): 시험일 ~ 공식 정답 반영 기간에만 (노출 판정은 examAnswerHomeEntryProvider)
/// 행 하나: 가채점 안내 > 회차 상태·참여자 수 > 가답안 화면
class ExamAnswerHomeSection extends StatelessWidget {
  const ExamAnswerHomeSection({super.key, required this.roundResponse});

  final ExamAnswerRoundResponse roundResponse;

  @override
  Widget build(BuildContext context) {
    final colors = context.passqlColors;
    final isOfficial = roundResponse.status == ExamAnswerRoundStatus.official;
    final participantCount = roundResponse.participantCount;
    return PassqlSection(
      title: '${roundResponse.displayTitle} 가답안',
      child: PassqlListRow(
        title: isOfficial ? '공식 정답으로 채점하기' : '가채점하고 합격 예측',
        // 한 줄 설명: 회차 상태 | 참여자 수 (행 오른쪽엔 화살표만, Design 5.1)
        subtitle: participantCount > 0
            ? '${roundResponse.status.label} | ${formatThousands(participantCount)}명 참여'
            : roundResponse.status.label,
        leading: PassqlIconTile(
          icon: CupertinoIcons.checkmark_seal_fill,
          color: colors.accent,
        ),
        hasChevron: true,
        hasHorizontalPadding: false,
        onTap: () => context.push(
          AppRoutes.examAnswer(
            roundResponse.certType,
            roundResponse.roundNumber,
          ),
        ),
      ),
    );
  }
}
