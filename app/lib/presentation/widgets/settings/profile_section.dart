import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../design/design.dart';
import '../../providers/settings_providers.dart';
import '../common/app_toast.dart';
import '../pro/pro_settings_card.dart';
import 'nickname_edit_sheet.dart';
import 'profile_card.dart';

/// 내 프로필 탭 맨 위: 이용권 카드 + 프로필(닉네임 변경)
class ProfileSection extends ConsumerWidget {
  const ProfileSection({super.key});

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
