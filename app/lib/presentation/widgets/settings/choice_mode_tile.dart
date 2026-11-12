import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../data/models/member/choice_generation_mode.dart';
import '../../design/design.dart';
import '../../providers/plan_providers.dart';
import '../../providers/settings_providers.dart';
import '../pro/pro_offer_sheet.dart';
import '../question/choice_generation_mode_display.dart';
import '../question/choice_mode_switch_action.dart';
import 'settings_group.dart';

/// 새 보기로 풀기 스위치 (설정 학습 묶음·풀이 화면 보기 방식 시트).
///
/// 켜면 REAL: 풀 때마다 AI 가 새 보기를 만든다.
/// 끄면 PRACTICE: 기존 보기를 먼저 쓰고 없을 때만 AI 가 만든다.
/// 무료(결제 켜짐): 실효 모드(연습) 설명 + 스위치 자리에 PRO 칩, 줄을 누르면 이용권 시트 (서버도 연습으로 처리, §4-1, #993)
class ChoiceModeTile extends ConsumerWidget {
  const ChoiceModeTile({super.key, this.onModeSaved});

  /// 저장 성공 뒤 할 일 (풀이 화면 시트: 닫고 지금 문제에 반영). 설정 화면은 없음
  final VoidCallback? onModeSaved;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.passqlColors;
    final effectiveMode = ref.watch(effectiveChoiceModeProvider);
    final isFreshChoicesLocked = ref.watch(shouldShowProUiProvider);
    final isFreshChoices =
        effectiveMode.valueOrNull == ChoiceGenerationMode.real;

    // 설정 그룹 안의 한 줄로 그린다(카드는 SettingsGroup 이 맡는다).
    return SettingsRow(
      icon: CupertinoIcons.bolt_fill,
      iconColor: colors.accent,
      title: ChoiceGenerationModeDisplay.freshChoicesTitle,
      // 잠김이면 PRO 로 받는 기능(새 보기)을 설명
      subtitle:
          (isFreshChoices || isFreshChoicesLocked
                  ? ChoiceGenerationMode.real
                  : ChoiceGenerationMode.practice)
              .description,
      shouldShowChevron: false,
      onTap: isFreshChoicesLocked
          ? () => showProOfferSheet(context, ref)
          : null,
      trailing: isFreshChoicesLocked
          ? const PassqlPlanChip(isPro: true)
          : CupertinoSwitch(
              value: isFreshChoices,
              activeTrackColor: colors.accent,
              // 불러오는 중에는 값을 모르므로 조작을 막는다.
              onChanged: effectiveMode.hasValue
                  ? (value) => switchFreshChoiceMode(
                      context,
                      ref,
                      shouldUseFreshChoices: value,
                      onModeSaved: onModeSaved,
                    )
                  : null,
            ),
    );
  }
}
