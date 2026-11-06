import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../data/models/member/choice_generation_mode.dart';
import '../../design/design.dart';
import '../../providers/settings_providers.dart';
import 'choice_generation_mode_display.dart';
import 'choice_mode_switch_action.dart';

/// 문제 탭 공통 영역의 새 보기로 풀기 행: 지금 방식 한 줄 설명 + 스위치로 전환
/// 값의 원본은 설정 ChoiceModeTile 과 같은 effectiveChoiceModeProvider (불러오기 전에는 전환 불가)
/// 무료(결제 켜짐): 실효 모드(검증된 보기)로 표시, 켜면 프로 안내 시트 (switchFreshChoiceMode 공통 규칙)
class ChoiceModeShortcutRow extends ConsumerWidget {
  const ChoiceModeShortcutRow({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.passqlColors;
    final effectiveMode = ref.watch(effectiveChoiceModeProvider);
    // 불러오기 실패 시 행 숨김 (전환 불가한 막다른 행 방지)
    if (effectiveMode.hasError && !effectiveMode.hasValue) {
      return const SizedBox.shrink();
    }
    final currentMode = effectiveMode.valueOrNull;
    return PassqlListRow(
      title: ChoiceGenerationModeDisplay.freshChoicesTitle,
      subtitle: currentMode?.description,
      leading: PassqlIconTile(
        icon: CupertinoIcons.bolt_fill,
        color: colors.accent,
      ),
      trailing: currentMode == null
          ? null
          // 스위치 낭독: '새 보기로 풀기, 켜짐'
          : Semantics(
              label: ChoiceGenerationModeDisplay.freshChoicesTitle,
              child: CupertinoSwitch(
                value: currentMode == ChoiceGenerationMode.real,
                activeTrackColor: colors.accent,
                onChanged: (value) => switchFreshChoiceMode(
                  context,
                  ref,
                  shouldUseFreshChoices: value,
                ),
              ),
            ),
    );
  }
}
