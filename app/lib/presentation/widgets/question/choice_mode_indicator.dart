import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../data/models/member/choice_generation_mode.dart';
import '../../design/design.dart';
import '../../providers/choice_mode_switch_plan.dart';
import '../../providers/settings_providers.dart';
import '../common/app_toast.dart';
import 'choice_generation_mode_display.dart';
import 'choice_mode_sheet.dart';

/// 풀이 화면 보기 위 한 줄: 지금 보기 방식(AI 새 보기·검증된 보기) 알약 > 누르면 보기 방식 시트
/// 무료(결제 켜짐)는 검증된 보기로 표시, 시트에서 새 보기 잠금 미리보기. 모드를 모르거나 불러오기 실패면 숨김
/// 바꾸면 지금 문제에 반영 (제출 뒤면 다음 풀이부터 안내 토스트, #907)
class ChoiceModeIndicator extends ConsumerWidget {
  const ChoiceModeIndicator({
    super.key,
    required this.hasSubmitted,
    required this.onModeChanged,
  });

  /// 이 풀이를 제출했는지 (시트 안내 문구)
  final bool hasSubmitted;

  /// 저장된 새 방식을 지금 문제에 반영하고 한 일을 돌려줌
  final ChoiceModeSwitchAction Function() onModeChanged;

  /// 시트 열기 > 저장 성공 시 반영 > 지금 문제에 반영 못 했으면 안내
  void _openChoiceModeSheet(BuildContext context) {
    showChoiceModeSheet(
      context,
      hasSubmitted: hasSubmitted,
      onModeSaved: () {
        final action = onModeChanged();
        if (action.isAppliedToCurrentQuestion || !context.mounted) return;
        showAppToast(context, appliesFromNextSolveNotice);
      },
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.passqlColors;
    final mode = ref.watch(effectiveChoiceModeProvider).valueOrNull;
    if (mode == null) return const SizedBox.shrink();
    final isFreshChoices = mode == ChoiceGenerationMode.real;
    final contentColor = isFreshChoices
        ? colors.accentText
        : colors.secondaryLabel;
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        PassqlSpacing.md,
        PassqlSpacing.xs,
        PassqlSpacing.md,
        PassqlSpacing.xxs,
      ),
      child: Align(
        alignment: Alignment.centerLeft,
        child: PassqlPressable(
          hasMinimumTouchTarget: true,
          semanticLabel: '보기 방식 ${mode.shortName}, 바꾸기',
          onTap: () => _openChoiceModeSheet(context),
          child: Container(
            padding: const EdgeInsets.symmetric(
              horizontal: PassqlSpacing.sm,
              vertical: PassqlSpacing.xxs,
            ),
            decoration: BoxDecoration(
              color: isFreshChoices ? colors.accentTint : colors.fill,
              borderRadius: BorderRadius.circular(PassqlRadius.capsule),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  isFreshChoices
                      ? CupertinoIcons.bolt_fill
                      : CupertinoIcons.checkmark_seal_fill,
                  size: PassqlIconSize.sm,
                  color: contentColor,
                ),
                const SizedBox(width: PassqlSpacing.xxs),
                Text(
                  mode.shortName,
                  style: PassqlTypography.footnoteSemibold.copyWith(
                    color: contentColor,
                  ),
                ),
                const SizedBox(width: PassqlSpacing.xxs),
                Icon(
                  CupertinoIcons.chevron_down,
                  size: PassqlIconSize.xs,
                  color: contentColor,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
