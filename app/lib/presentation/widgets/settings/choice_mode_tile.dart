import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../data/models/member/choice_generation_mode.dart';
import '../../design/design.dart';
import '../../providers/plan_providers.dart';
import '../../providers/settings_providers.dart';
import '../pro/locked_preview_samples.dart';
import '../pro/pro_locked_section.dart';
import '../question/choice_generation_mode_display.dart';
import '../question/choice_mode_switch_action.dart';
import 'settings_group.dart';

/// 새 보기로 풀기 스위치 (설정 학습 묶음·풀이 화면 보기 방식 시트).
///
/// 켜면 REAL: 풀 때마다 AI 가 새 보기를 만든다.
/// 끄면 PRACTICE: 검증된 기존 보기를 먼저 쓰고 없을 때만 AI 가 만든다.
/// 무료(결제 켜짐): 실효 모드(연습)로 표시 + 아래 잠금 자리 (서버도 연습으로 처리, §4-1)
class ChoiceModeTile extends ConsumerWidget {
  const ChoiceModeTile({super.key, this.onModeSaved});

  /// 저장 성공 뒤 할 일 (풀이 화면 시트: 닫고 지금 문제에 반영). 설정 화면은 없음
  final VoidCallback? onModeSaved;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.passqlColors;
    final effectiveMode = ref.watch(effectiveChoiceModeProvider);
    final isFreshChoicesLocked = ref.watch(shouldShowProUiProvider);
    final isFreshChoices = effectiveMode.valueOrNull == ChoiceGenerationMode.real;

    // 설정 그룹 안의 한 줄로 그린다(카드는 SettingsGroup 이 맡는다).
    final modeRow = SettingsRow(
      icon: CupertinoIcons.bolt_fill,
      iconColor: colors.accent,
      title: ChoiceGenerationModeDisplay.freshChoicesTitle,
      subtitle:
          (isFreshChoices
                  ? ChoiceGenerationMode.real
                  : ChoiceGenerationMode.practice)
              .description,
      shouldShowChevron: false,
      trailing: CupertinoSwitch(
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
    if (!isFreshChoicesLocked) return modeRow;
    // 현재 모드(검증된 보기) 선명 + 새 보기 잠금 블러 (그룹 카드 안쪽 여백)
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        modeRow,
        const Padding(
          padding: EdgeInsets.fromLTRB(
            PassqlSpacing.md,
            0,
            PassqlSpacing.md,
            PassqlSpacing.md,
          ),
          child: ProLockedSection(
            preview: FreshChoicesLockedSample(),
            caption: LockedPreviewCaptions.freshChoices,
          ),
        ),
      ],
    );
  }
}
