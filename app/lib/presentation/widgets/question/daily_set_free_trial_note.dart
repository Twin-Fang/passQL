import 'package:flutter/cupertino.dart';

import '../../design/design.dart';

/// 오늘의 세트 무료 체험 안내 한 줄 (#992)
/// 보일지는 호출부가 shouldShowDailySetFreeTrialNoteProvider 로 정함 (보이면 실행 안내 줄 대신)
class DailySetFreeTrialNote extends StatelessWidget {
  const DailySetFreeTrialNote({super.key, required this.isExecutable});

  /// 실행형 문제인가 (개념형은 SQL 실행이 없어 해설만 안내)
  final bool isExecutable;

  static const String _executableNote =
      '오늘의 세트에서는 SQL 실행과 AI 해설을 볼 수 있어요!';
  static const String _conceptNote = '오늘의 세트에서는 AI 해설을 볼 수 있어요!';

  @override
  Widget build(BuildContext context) {
    final colors = context.passqlColors;
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        PassqlSpacing.md,
        PassqlSpacing.xs,
        PassqlSpacing.md,
        PassqlSpacing.xxs,
      ),
      child: Row(
        children: [
          Icon(
            CupertinoIcons.gift,
            size: PassqlIconSize.xs,
            color: colors.accentText,
          ),
          const SizedBox(width: PassqlSpacing.xxs),
          Expanded(
            child: Text(
              isExecutable ? _executableNote : _conceptNote,
              style: PassqlTypography.footnote.copyWith(
                color: colors.secondaryLabel,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
