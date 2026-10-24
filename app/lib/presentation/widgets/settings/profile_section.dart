import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/error/app_exception.dart';
import '../../design/design.dart';
import '../../providers/settings_providers.dart';
import '../common/app_toast.dart';
import '../pro/pro_settings_card.dart';
import 'nickname_edit_sheet.dart';
import 'profile_card.dart';

/// 내 프로필 탭 맨 위: 이용권 카드 + 프로필(닉네임 변경·랜덤 닉네임)
class ProfileSection extends ConsumerWidget {
  const ProfileSection({super.key});

  /// 닉네임 재생성: 확인 > 변경 > 성공 토스트, 실패하면 원인 문구 토스트 (닉네임은 이전 값 유지)
  Future<void> _regenerateNickname(BuildContext context, WidgetRef ref) async {
    // 바로 적용되고 쿨다운이 시작돼서 먼저 확인받는다
    final isConfirmed = await showPassqlConfirmDialog(
      context,
      title: '랜덤 닉네임으로 바꿀까요?',
      message: '새 닉네임이 바로 적용되고, 변경 후 3일간은 다시 바꿀 수 없어요.',
      confirmLabel: '바꾸기',
      isDestructive: false,
    );
    if (!isConfirmed || !context.mounted) return;

    try {
      await ref.read(nicknameNotifierProvider.notifier).regenerate();
      if (context.mounted) showAppToast(context, '닉네임이 변경됐어요');
    } on AppException catch (exception) {
      if (context.mounted) showAppToast(context, exception.message);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settingsAsync = ref.watch(settingsDataProvider);
    final nicknameAsync = ref.watch(nicknameNotifierProvider);
    return Column(
      children: [
        // 등급 카드 (결제 꺼짐·등급 모름이면 자리째 없음, 아래 간격 포함)
        const ProSettingsCard(),
        settingsAsync.when(
          loading: () => const ProfileCardSkeleton(),
          error: (error, _) => ProfileCardError(
            onRetry: () => ref.invalidate(settingsDataProvider),
          ),
          data: (data) {
            // 닉네임은 nicknameNotifier 상태 우선 (재생성 반영)
            final nickname = nicknameAsync.valueOrNull ?? data.nickname;
            return ProfileCard(
              nickname: nickname,
              isRegenerating: nicknameAsync.isLoading,
              onRegenerate: () => _regenerateNickname(context, ref),
              onEdit: () async {
                final changed = await NicknameEditSheet.show(context, nickname);
                if (changed == true && context.mounted) {
                  showAppToast(context, '닉네임이 변경됐어요');
                }
              },
            );
          },
        ),
        const SizedBox(height: PassqlSpacing.md),
      ],
    );
  }
}
