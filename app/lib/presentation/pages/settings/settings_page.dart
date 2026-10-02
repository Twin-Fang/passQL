import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../../core/app_colors.dart';
import '../../../core/text_styles.dart';
import '../../../router/app_routes.dart';
import '../../providers/auth_provider.dart';
import '../../providers/settings_providers.dart';
import '../../widgets/common/app_toast.dart';
import '../../widgets/settings/choice_mode_tile.dart';
import '../../widgets/settings/nickname_edit_sheet.dart';
import '../../widgets/settings/settings_link_tile.dart';
import '../../widgets/settings/wrong_notes_section.dart';

class SettingsPage extends ConsumerWidget {
  const SettingsPage({super.key});

  /// 실수로 누르는 것을 막기 위해 한 번 확인한 뒤 로그아웃한다.
  /// 로그아웃되면 라우터가 자동으로 로그인 화면으로 보낸다.
  Future<void> _confirmSignOut(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('로그아웃할까요?'),
        content: const Text('다시 로그인하면 기록은 그대로 이어져요.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('취소'),
          ),
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text('로그아웃'),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      await ref.read(authProvider.notifier).signOut();
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settingsAsync = ref.watch(settingsDataProvider);
    final nicknameAsync = ref.watch(nicknameNotifierProvider);

    return Scaffold(
      backgroundColor: AppColors.pageBg,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('설정', style: AppTextStyles.heading_24),
              const SizedBox(height: 24),
              // 정보 카드
              settingsAsync.when(
                loading: () => const _InfoCardSkeleton(),
                error: (e, _) => Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: AppColors.cardBg,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.borderDefault),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '정보를 불러오지 못했습니다.',
                        style: AppTextStyles.paragraph_14.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 12),
                      GestureDetector(
                        onTap: () => ref.refresh(settingsDataProvider),
                        child: Text(
                          '다시 시도',
                          style: AppTextStyles.paragraph_14.copyWith(
                            color: AppColors.brandIndigo,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                data: (data) {
                  // 닉네임은 nicknameNotifier 상태 우선 (재생성 반영)
                  final nickname = nicknameAsync.valueOrNull ?? data.nickname;
                  final isRegenerating = nicknameAsync.isLoading;

                  return _InfoCard(
                    memberUuid: data.memberUuid,
                    nickname: nickname,
                    version: data.version,
                    isRegenerating: isRegenerating,
                    onCopyUuid: () async {
                      await Clipboard.setData(
                        ClipboardData(text: data.memberUuid),
                      );
                      // async gap 이후 위젯이 unmount됐을 수 있으므로 체크
                      if (!context.mounted) return;
                      showAppToast(context, '회원 ID가 복사되었습니다.');
                    },
                    onRegenerateNickname: () => ref
                        .read(nicknameNotifierProvider.notifier)
                        .regenerate(),
                    onEditNickname: () async {
                      final changed = await NicknameEditSheet.show(
                        context,
                        nickname,
                      );
                      if (changed == true && context.mounted) {
                        showAppToast(context, '닉네임이 변경됐어요');
                      }
                    },
                  );
                },
              ),
              const SizedBox(height: 16),
              // 선택지 생성 방식
              const ChoiceModeTile(),
              const SizedBox(height: 16),
              // 오답 노트
              const WrongNotesSection(),
              const SizedBox(height: 16),
              // 건의사항
              SettingsLinkTile(
                title: '건의사항',
                description: '앱에 바라는 점을 보내고, 처리 상태를 확인해요',
                onTap: () => context.push(AppRoutes.feedback),
              ),
              const SizedBox(height: 16),
              // 로그아웃
              SettingsLinkTile(
                title: '로그아웃',
                description: '이 기기에서 로그아웃해요',
                onTap: () => _confirmSignOut(context, ref),
              ),
              const SizedBox(height: 40),
              // 하단 푸터
              const _Footer(),
            ],
          ),
        ),
      ),
    );
  }
}

/// 정보 카드 (디바이스 ID / 닉네임 / 버전)
class _InfoCard extends StatelessWidget {
  const _InfoCard({
    required this.memberUuid,
    required this.nickname,
    required this.version,
    required this.isRegenerating,
    required this.onCopyUuid,
    required this.onRegenerateNickname,
    required this.onEditNickname,
  });

  final String memberUuid;
  final String nickname;
  final String version;
  final bool isRegenerating;
  // async 콜백 — Clipboard.setData 이후 context.mounted 체크를 위해 Future<void> 사용
  final Future<void> Function() onCopyUuid;
  final VoidCallback onRegenerateNickname;
  final VoidCallback onEditNickname;

  @override
  Widget build(BuildContext context) {
    // UUID는 앞 19자 + "..." 로 축약
    final truncatedUuid = memberUuid.length > 19
        ? '${memberUuid.substring(0, 19)}...'
        : memberUuid;

    return Container(
      decoration: BoxDecoration(
        color: AppColors.cardBg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.borderDefault),
      ),
      child: Column(
        children: [
          _InfoRow(
            label: '회원 ID',
            value: truncatedUuid,
            valueStyle: AppTextStyles.paragraph_14.copyWith(
              color: AppColors.textPrimary,
            ),
            action: IconButton(
              icon: const FaIcon(FontAwesomeIcons.copy, size: 16),
              color: AppColors.textCaption,
              onPressed: onCopyUuid,
            ),
          ),
          const Divider(height: 1, color: AppColors.borderDefault),
          _InfoRow(
            label: '닉네임',
            value: nickname,
            valueStyle: AppTextStyles.label_16.copyWith(
              color: AppColors.textPrimary,
            ),
            action: isRegenerating
                ? const SizedBox(
                    width: 40,
                    height: 40,
                    child: Center(
                      child: SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: AppColors.textCaption,
                        ),
                      ),
                    ),
                  )
                : Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        tooltip: '닉네임 직접 변경',
                        icon: const FaIcon(FontAwesomeIcons.pen, size: 16),
                        color: AppColors.textCaption,
                        onPressed: onEditNickname,
                      ),
                      IconButton(
                        tooltip: '랜덤 닉네임',
                        icon: const FaIcon(
                          FontAwesomeIcons.arrowsRotate,
                          size: 16,
                        ),
                        color: AppColors.textCaption,
                        onPressed: onRegenerateNickname,
                      ),
                    ],
                  ),
          ),
          const Divider(height: 1, color: AppColors.borderDefault),
          _InfoRow(
            label: '버전',
            value: version,
            valueStyle: AppTextStyles.paragraph_14.copyWith(
              color: AppColors.textCaption,
            ),
            action: null,
          ),
        ],
      ),
    );
  }
}

/// 카드 내 단일 행
class _InfoRow extends StatelessWidget {
  const _InfoRow({
    required this.label,
    required this.value,
    required this.valueStyle,
    required this.action,
  });

  final String label;
  final String value;
  final TextStyle valueStyle;
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 4, 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: AppTextStyles.tag_12.copyWith(
                    color: AppColors.textCaption,
                  ),
                ),
                const SizedBox(height: 4),
                Text(value, style: valueStyle),
              ],
            ),
          ),
          ?action,
        ],
      ),
    );
  }
}

/// 로딩 스켈레톤 — 카드 자리 유지
class _InfoCardSkeleton extends StatelessWidget {
  const _InfoCardSkeleton();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 220,
      decoration: BoxDecoration(
        color: AppColors.cardBg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.borderDefault),
      ),
    );
  }
}

/// passQL 브랜드 푸터
class _Footer extends StatelessWidget {
  const _Footer();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Center(child: Image.asset('assets/logo.png', height: 24)),
        const SizedBox(height: 8),
        Center(
          child: Text(
            '© 2026 passQL. All rights reserved.',
            style: AppTextStyles.tag_12.copyWith(color: AppColors.textCaption),
          ),
        ),
      ],
    );
  }
}
