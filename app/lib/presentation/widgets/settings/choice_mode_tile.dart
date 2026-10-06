import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/app_colors.dart';
import '../../../core/error/app_exception.dart';
import '../../../core/text_styles.dart';
import '../../../data/models/member/choice_generation_mode.dart';
import '../../providers/settings_providers.dart';
import '../common/app_toast.dart';

/// 선택지 생성 방식 토글.
///
/// 켜면 실전(REAL): 항상 AI 가 새 선택지를 만든다.
/// 끄면 연습(PRACTICE): 검증된 기존 선택지를 먼저 쓰고 없을 때만 AI 가 만든다.
class ChoiceModeTile extends ConsumerWidget {
  const ChoiceModeTile({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final mode = ref.watch(choiceModeProvider);
    final isReal = mode.valueOrNull == ChoiceGenerationMode.real;

    return Container(
      padding: const EdgeInsets.fromLTRB(20, 16, 12, 16),
      decoration: BoxDecoration(
        color: AppColors.cardBg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.borderDefault),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '실전 모드',
                  style: AppTextStyles.label_16.copyWith(
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  isReal
                      ? '풀 때마다 AI가 새 선택지를 만들어요'
                      : '검증된 선택지를 먼저 쓰고, 없을 때만 AI가 만들어요',
                  style: AppTextStyles.tag_12.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: isReal,
            activeThumbColor: AppColors.brandIndigo,
            // 불러오는 중에는 값을 모르므로 조작을 막는다.
            onChanged: mode.hasValue
                ? (value) => _change(context, ref, value)
                : null,
          ),
        ],
      ),
    );
  }

  Future<void> _change(BuildContext context, WidgetRef ref, bool real) async {
    try {
      await ref
          .read(choiceModeProvider.notifier)
          .setMode(
            real ? ChoiceGenerationMode.real : ChoiceGenerationMode.practice,
          );
    } on AppException catch (e) {
      // 값은 Notifier 가 이전 상태로 되돌려 두었다. 이유만 알린다.
      if (context.mounted) showAppToast(context, e.message);
    }
  }
}
