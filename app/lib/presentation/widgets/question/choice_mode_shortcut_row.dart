import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/error/app_exception.dart';
import '../../../data/models/member/choice_generation_mode.dart';
import '../../design/design.dart';
import '../../providers/settings_providers.dart';
import '../common/app_toast.dart';

/// 문제 탭 공통 영역의 풀이 모드 행: 현재 값(연습/실전) 표시 + 탭 > 전환
/// 값의 원본은 설정 ChoiceModeTile 과 같은 choiceModeProvider (불러오기 전에는 전환 불가)
class ChoiceModeShortcutRow extends ConsumerWidget {
  const ChoiceModeShortcutRow({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.passqlColors;
    final currentMode = ref.watch(choiceModeProvider).valueOrNull;
    final isReal = currentMode == ChoiceGenerationMode.real;
    return PassqlListRow(
      title: '풀이 모드',
      // 모드 설명은 설정의 실전 모드 행과 같은 문구
      subtitle: switch (currentMode) {
        null => null,
        ChoiceGenerationMode.real => '매번 AI가 새 선택지를 만들어요',
        ChoiceGenerationMode.practice => '검증된 선택지를 먼저 써요',
      },
      leading: PassqlIconTile(
        icon: CupertinoIcons.bolt_fill,
        color: colors.accent,
      ),
      trailing: currentMode == null ? null : Text(isReal ? '실전' : '연습'),
      onTap: currentMode == null
          ? null
          : () => _switchMode(context, ref, shouldBeReal: !isReal),
    );
  }

  Future<void> _switchMode(
    BuildContext context,
    WidgetRef ref, {
    required bool shouldBeReal,
  }) async {
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
