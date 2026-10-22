import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/error/app_exception.dart';
import '../../../data/models/member/choice_generation_mode.dart';
import '../../design/design.dart';
import '../../providers/plan_providers.dart';
import '../../providers/settings_providers.dart';
import '../common/app_toast.dart';
import '../pro/pro_offer_sheet.dart';
import '../settings/choice_generation_mode_display.dart';

/// 문제 탭 공통 영역의 풀이 모드 행: 현재 값(연습/실전) 표시 + 스위치로 전환
/// 값의 원본은 설정 ChoiceModeTile 과 같은 choiceModeProvider (불러오기 전에는 전환 불가)
/// 무료(결제 켜짐): 저장값과 무관하게 실효 모드(연습)로 표시, 실전으로 켜면 프로 안내 시트 (ChoiceModeTile 과 같은 규칙)
class ChoiceModeShortcutRow extends ConsumerWidget {
  const ChoiceModeShortcutRow({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.passqlColors;
    final choiceModeState = ref.watch(choiceModeProvider);
    // 불러오기 실패 시 행 숨김 (전환 불가한 막다른 행 방지)
    if (choiceModeState.hasError && !choiceModeState.hasValue) {
      return const SizedBox.shrink();
    }
    final isRealModeLocked = ref.watch(shouldShowProUiProvider);
    final storedMode = choiceModeState.valueOrNull;
    final currentMode = isRealModeLocked && storedMode != null
        ? ChoiceGenerationMode.practice
        : storedMode;
    final isReal = currentMode == ChoiceGenerationMode.real;
    return PassqlListRow(
      title: '풀이 모드',
      subtitle: currentMode?.description,
      leading: PassqlIconTile(
        icon: CupertinoIcons.bolt_fill,
        color: colors.accent,
      ),
      trailing: currentMode == null
          ? null
          : Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(currentMode.shortName),
                const SizedBox(width: PassqlSpacing.xs),
                // 스위치 낭독: '풀이 모드 실전, 켜짐'
                Semantics(
                  label: '풀이 모드 ${currentMode.shortName}',
                  child: CupertinoSwitch(
                    value: isReal,
                    activeTrackColor: colors.accent,
                    onChanged: (value) =>
                        _switchMode(context, ref, shouldBeReal: value),
                  ),
                ),
              ],
            ),
    );
  }

  Future<void> _switchMode(
    BuildContext context,
    WidgetRef ref, {
    required bool shouldBeReal,
  }) async {
    // 무료(결제 켜짐): 실전 모드는 잠금 > 변경 요청 없이 시트 (현재 모드 그대로)
    if (shouldBeReal && ref.read(shouldShowProUiProvider)) {
      await showProOfferSheet(context, ref);
      return;
    }
    try {
      await ref
          .read(choiceModeProvider.notifier)
          .setMode(
            shouldBeReal
                ? ChoiceGenerationMode.real
                : ChoiceGenerationMode.practice,
          );
    } on AppException catch (exception) {
      // 값은 Notifier 가 이전 상태로 되돌려 둠 (이유만 알림)
      if (context.mounted) showAppToast(context, exception.message);
    }
  }
}
