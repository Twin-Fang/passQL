import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/error/app_exception.dart';
import '../../../data/models/member/choice_generation_mode.dart';
import '../../providers/plan_providers.dart';
import '../../providers/settings_providers.dart';
import '../common/app_toast.dart';
import '../pro/pro_offer_sheet.dart';

/// 새 보기로 풀기 켜기·끄기 공통: 무료(결제 켜짐)가 켜면 저장 없이 프로 안내 시트 > 그 외 저장 (실패 사유 토스트)
/// 설정 ChoiceModeTile·문제 탭 ChoiceModeShortcutRow 가 함께 씀
Future<void> switchFreshChoiceMode(
  BuildContext context,
  WidgetRef ref, {
  required bool shouldUseFreshChoices,
}) async {
  if (shouldUseFreshChoices && ref.read(shouldShowProUiProvider)) {
    await showProOfferSheet(context, ref);
    return;
  }
  try {
    await ref
        .read(choiceModeProvider.notifier)
        .setMode(
          shouldUseFreshChoices
              ? ChoiceGenerationMode.real
              : ChoiceGenerationMode.practice,
        );
  } on AppException catch (exception) {
    // 값은 Notifier 가 이전 상태로 되돌려 둠 (이유만 알림)
    if (context.mounted) showAppToast(context, exception.message);
  }
}
