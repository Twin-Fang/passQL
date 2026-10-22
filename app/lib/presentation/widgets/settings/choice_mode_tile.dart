import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/error/app_exception.dart';
import '../../../data/models/member/choice_generation_mode.dart';
import '../../design/design.dart';
import '../../providers/plan_providers.dart';
import '../../providers/settings_providers.dart';
import '../common/app_toast.dart';
import '../pro/pro_offer_sheet.dart';
import 'settings_group.dart';

/// 선택지 생성 방식 토글.
///
/// 켜면 실전(REAL): 항상 AI 가 새 선택지를 만든다.
/// 끄면 연습(PRACTICE): 검증된 기존 선택지를 먼저 쓰고 없을 때만 AI 가 만든다.
class ChoiceModeTile extends ConsumerWidget {
  const ChoiceModeTile({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.passqlColors;
    final mode = ref.watch(choiceModeProvider);
    final isReal = mode.valueOrNull == ChoiceGenerationMode.real;

    // 설정 그룹 안의 한 줄로 그린다(카드는 SettingsGroup 이 맡는다).
    return SettingsRow(
      icon: CupertinoIcons.bolt_fill,
      iconColor: colors.accent,
      title: '실전 모드',
      // 한 줄에 들어가도록 짧게 쓴다(두 줄이면 스위치 옆에서 어색하게 끊긴다).
      subtitle: isReal ? '매번 AI가 새 선택지를 만들어요' : '검증된 선택지를 먼저 써요',
      shouldShowChevron: false,
      trailing: CupertinoSwitch(
        value: isReal,
        activeTrackColor: colors.accent,
        // 불러오는 중에는 값을 모르므로 조작을 막는다.
        onChanged: mode.hasValue
            ? (value) => _change(context, ref, value)
            : null,
      ),
    );
  }

  Future<void> _change(
    BuildContext context,
    WidgetRef ref,
    bool isRealMode,
  ) async {
    // 무료(결제 켜짐): 실전 모드는 잠금 > 변경 요청 없이 시트 (현재 모드 그대로)
    if (isRealMode && ref.read(shouldShowProUiProvider)) {
      await showProOfferSheet(context, ref);
      return;
    }
    try {
      await ref
          .read(choiceModeProvider.notifier)
          .setMode(
            isRealMode
                ? ChoiceGenerationMode.real
                : ChoiceGenerationMode.practice,
          );
    } on AppException catch (exception) {
      // 값은 Notifier 가 이전 상태로 되돌려 두었다. 이유만 알린다.
      if (context.mounted) showAppToast(context, exception.message);
    }
  }
}
