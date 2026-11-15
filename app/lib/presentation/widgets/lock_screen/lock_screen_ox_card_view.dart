import 'package:flutter/cupertino.dart';

import '../../../core/utils/date_format.dart';
import '../../design/design.dart';
import '../../providers/lock_screen_ox_card_notifier.dart';
import '../ox_quiz/ox_quiz_card_view.dart';

/// 잠금화면 OX 복습 본문 (#1110): "OX 복습" 머리 > OX 카드(문장, O·X 큰 버튼) > 고르면 정오 + 이유 + 다음 복습일
/// 카드 모양은 OX 퀴즈와 같은 OxQuizCardView, 다음 동작은 화면 하단 바
class LockScreenOxCardView extends StatelessWidget {
  const LockScreenOxCardView({
    super.key,
    required this.oxCardState,
    required this.onPicked,
  });

  static const String caption = 'OX 복습';

  final LockScreenOxCardState oxCardState;
  final ValueChanged<bool> onPicked;

  @override
  Widget build(BuildContext context) {
    final colors = context.passqlColors;
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(
        PassqlSpacing.md,
        PassqlSpacing.xs,
        PassqlSpacing.md,
        PassqlSpacing.md,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Semantics(
            header: true,
            child: Text(
              caption,
              style: PassqlTypography.footnote.copyWith(
                color: colors.secondaryLabel,
              ),
            ),
          ),
          const SizedBox(height: PassqlSpacing.sm),
          OxQuizCardView(
            card: oxCardState.card,
            pickedIsTrue: oxCardState.pickedIsTrue,
            isLastCard: true,
            onPicked: onPicked,
            resultNote: _toResultNote(),
          ),
        ],
      ),
    );
  }

  /// 해설 아래 한 줄: 다음 복습일 > 저장 실패 안내 > 저장 중이면 없음
  String? _toResultNote() {
    final nextReviewDate = oxCardState.nextReviewDate;
    if (nextReviewDate != null) {
      return '다음 복습 ${formatMonthDay(nextReviewDate)}';
    }
    if (oxCardState.hasSyncFailure) return '복습 기록을 저장하지 못했어요';
    return null;
  }
}
