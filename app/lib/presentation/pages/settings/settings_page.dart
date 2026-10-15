import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../router/app_routes.dart';
import '../../../core/auth/social_sign_in.dart';
import '../../../core/error/app_exception.dart';
import '../../../data/models/legal/legal_models.dart';
import '../../design/design.dart';
import '../../providers/auth_provider.dart';
import '../../providers/settings_providers.dart';
import '../../widgets/common/app_toast.dart';
import '../../widgets/settings/choice_mode_tile.dart';
import '../../widgets/settings/theme_mode_tile.dart';
import '../../widgets/settings/nickname_edit_sheet.dart';
import '../../providers/wrong_questions_provider.dart';
import '../../widgets/settings/settings_group.dart';

class SettingsPage extends ConsumerWidget {
  const SettingsPage({super.key});

  /// 취소/확인 두 버튼 확인창. 확인 버튼은 되돌리기 어려운 동작이라 파괴적 스타일로 보인다.
  Future<bool?> _confirm(
    BuildContext context, {
    required String title,
    required String content,
    required String confirmLabel,
  }) {
    return showCupertinoDialog<bool>(
      context: context,
      builder: (dialogContext) => CupertinoAlertDialog(
        title: Text(title),
        content: Text(content),
        actions: [
          CupertinoDialogAction(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('취소'),
          ),
          CupertinoDialogAction(
            isDestructiveAction: true,
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: Text(confirmLabel),
          ),
        ],
      ),
    );
  }

  /// 되돌릴 수 없는 작업이라 안내 후 한 번 더 확인받는다. 실패하면 사유를 알리고 계정은 그대로 둔다.
  Future<void> _confirmWithdraw(BuildContext context, WidgetRef ref) async {
    final confirmed = await _confirm(
      context,
      title: '정말 탈퇴할까요?',
      content: '계정과 개인정보가 삭제되고 되돌릴 수 없어요.\n같은 계정으로 다시 가입하면 새 계정으로 시작해요.',
      confirmLabel: '탈퇴하기',
    );
    if (confirmed != true || !context.mounted) return;

    // 성공하면 이 화면이 사라지므로, 대화상자를 닫을 네비게이터를 미리 잡아 둔다.
    final navigator = Navigator.of(context, rootNavigator: true);
    // 진행 중에는 화면을 잠가 중복 탭을 막는다.
    showCupertinoDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (_) => const PopScope(
        canPop: false,
        child: Center(child: CupertinoActivityIndicator(radius: 14)),
      ),
    );
    String? failure;
    try {
      // 성공하면 로그인 상태가 풀려 라우터가 로그인 화면으로 보낸다.
      await ref.read(authProvider.notifier).withdraw();
    } on AppException catch (exception) {
      failure = exception.message;
    } on SocialSignInException catch (exception) {
      failure = exception.message;
    } catch (_) {
      failure = '탈퇴에 실패했어요. 잠시 후 다시 시도해 주세요.';
    }
    // 잠금 대화상자를 닫는다. 성공해서 화면이 바뀐 경우에도 닫혀야 한다.
    navigator.maybePop();
    if (failure != null && context.mounted) showAppToast(context, failure);
  }

  /// 실수로 누르는 것을 막기 위해 한 번 확인한 뒤 로그아웃한다.
  /// 로그아웃되면 라우터가 자동으로 로그인 화면으로 보낸다.
  Future<void> _confirmSignOut(BuildContext context, WidgetRef ref) async {
    final confirmed = await _confirm(
      context,
      title: '로그아웃할까요?',
      content: '다시 로그인하면 기록은 그대로 이어져요.',
      confirmLabel: '로그아웃',
    );
    if (confirmed == true) {
      await ref.read(authProvider.notifier).signOut();
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.passqlColors;
    final settingsAsync = ref.watch(settingsDataProvider);
    final nicknameAsync = ref.watch(nicknameNotifierProvider);
    final wrongCount = ref
        .watch(wrongQuestionsProvider)
        .valueOrNull
        ?.totalCount;
    final data = settingsAsync.valueOrNull;

    return Scaffold(
      backgroundColor: colors.background,
      body: PassqlLargeTitleScrollView(
        title: '설정',
        slivers: [
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(
              PassqlSpacing.md,
              PassqlSpacing.md,
              PassqlSpacing.md,
              0,
            ),
            sliver: SliverList.list(
              children: [
                // 프로필: 닉네임만 보여 주고, 내부 식별자(회원 ID)는 하단으로 내린다.
                settingsAsync.when(
                  loading: () => const _ProfileSkeleton(),
                  error: (error, _) => _ProfileError(
                    onRetry: () => ref.invalidate(settingsDataProvider),
                  ),
                  data: (data) {
                    // 닉네임은 nicknameNotifier 상태 우선 (재생성 반영)
                    final nickname = nicknameAsync.valueOrNull ?? data.nickname;
                    return _ProfileCard(
                      nickname: nickname,
                      isRegenerating: nicknameAsync.isLoading,
                      onRegenerate: () => ref
                          .read(nicknameNotifierProvider.notifier)
                          .regenerate(),
                      onEdit: () async {
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
                const SizedBox(height: PassqlSpacing.xl),
                const SettingsGroup(title: '학습', children: [ChoiceModeTile()]),
                const SizedBox(height: PassqlSpacing.xl),
                const SettingsGroup(title: '화면', children: [ThemeModeTile()]),
                const SizedBox(height: PassqlSpacing.xl),
                SettingsGroup(
                  title: '기록',
                  children: [
                    SettingsRow(
                      icon: CupertinoIcons.book,
                      iconColor: colors.wrong,
                      title: '오답 노트',
                      trailing: wrongCount == null ? null : Text('$wrongCount'),
                      onTap: () => context.push(AppRoutes.wrongNotes),
                    ),
                  ],
                ),
                const SizedBox(height: PassqlSpacing.xl),
                SettingsGroup(
                  title: '정보',
                  children: [
                    SettingsRow(
                      icon: CupertinoIcons.chat_bubble,
                      title: '의견 보내기',
                      onTap: () => context.push(AppRoutes.feedback),
                    ),
                    SettingsRow(
                      icon: CupertinoIcons.doc_text,
                      title: '이용약관',
                      onTap: () => context.push(
                        AppRoutes.legal(LegalType.termsOfService.serverValue),
                      ),
                    ),
                    SettingsRow(
                      icon: CupertinoIcons.shield,
                      title: '개인정보처리방침',
                      onTap: () => context.push(
                        AppRoutes.legal(LegalType.privacyPolicy.serverValue),
                      ),
                    ),
                    if (data != null)
                      SettingsRow(
                        icon: CupertinoIcons.info,
                        title: '버전',
                        trailing: Text(data.version),
                        showChevron: false,
                      ),
                  ],
                ),
                const SizedBox(height: PassqlSpacing.xl),
                SettingsGroup(
                  children: [
                    SettingsRow(
                      icon: CupertinoIcons.square_arrow_right,
                      title: '로그아웃',
                      showChevron: false,
                      onTap: () => _confirmSignOut(context, ref),
                    ),
                  ],
                ),
                const SizedBox(height: PassqlSpacing.xl),
                // 회원 탈퇴 (스토어 심사 필수)
                SettingsGroup(
                  children: [
                    SettingsRow(
                      icon: CupertinoIcons.person_crop_circle_badge_xmark,
                      title: '회원 탈퇴',
                      destructive: true,
                      showChevron: false,
                      onTap: () => _confirmWithdraw(context, ref),
                    ),
                  ],
                ),
                const SizedBox(height: PassqlSpacing.xl),
                _Footer(memberUuid: data?.memberUuid),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// 프로필 카드. 편집 버튼은 닉네임 변경 시트를, 새로고침 아이콘은 랜덤 닉네임을 부른다.
class _ProfileCard extends StatelessWidget {
  const _ProfileCard({
    required this.nickname,
    required this.isRegenerating,
    required this.onEdit,
    required this.onRegenerate,
  });

  final String nickname;
  final bool isRegenerating;
  final VoidCallback onEdit;
  final VoidCallback onRegenerate;

  @override
  Widget build(BuildContext context) {
    final colors = context.passqlColors;
    final initial = nickname.isEmpty ? '?' : nickname.characters.first;
    return PassqlCard(
      child: Row(
        children: [
          Container(
            width: 52,
            height: 52,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: colors.accentTint,
              shape: BoxShape.circle,
            ),
            child: Text(
              initial,
              style: PassqlTypography.title3.copyWith(color: colors.accent),
            ),
          ),
          const SizedBox(width: PassqlSpacing.sm),
          Expanded(
            child: Text(
              nickname,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: PassqlTypography.headline.copyWith(color: colors.label),
            ),
          ),
          if (isRegenerating)
            const SizedBox(
              width: 44,
              height: 44,
              child: Center(child: CupertinoActivityIndicator()),
            )
          else
            CupertinoButton(
              padding: EdgeInsets.zero,
              minimumSize: const Size(44, 44),
              onPressed: onRegenerate,
              child: Semantics(
                label: '랜덤 닉네임',
                child: Tooltip(
                  message: '랜덤 닉네임',
                  child: Icon(
                    CupertinoIcons.arrow_clockwise,
                    size: 20,
                    color: colors.tertiaryLabel,
                  ),
                ),
              ),
            ),
          PassqlButton(
            label: '편집',
            variant: PassqlButtonVariant.plain,
            size: PassqlButtonSize.small,
            expand: false,
            onPressed: onEdit,
          ),
        ],
      ),
    );
  }
}

/// 로딩 스켈레톤 — 프로필 카드 자리 유지
class _ProfileSkeleton extends StatelessWidget {
  const _ProfileSkeleton();

  @override
  Widget build(BuildContext context) =>
      const PassqlSkeletonBox(height: 84, radius: PassqlRadius.lg);
}

class _ProfileError extends StatelessWidget {
  const _ProfileError({required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) => PassqlCard(
    child: PassqlStatusView.error(message: '정보를 불러오지 못했습니다.', onRetry: onRetry),
  );
}

/// 하단 정보: 회원 ID(문의 시 필요). 눌러서 복사한다.
class _Footer extends StatelessWidget {
  const _Footer({required this.memberUuid});

  final String? memberUuid;

  @override
  Widget build(BuildContext context) {
    final colors = context.passqlColors;
    final caption = PassqlTypography.caption.copyWith(color: colors.tertiaryLabel);
    return Column(
      children: [
        const PassqlLogo(height: 20),
        const SizedBox(height: PassqlSpacing.xs),
        if (memberUuid != null)
          GestureDetector(
            onTap: () async {
              await Clipboard.setData(ClipboardData(text: memberUuid!));
              if (!context.mounted) return;
              showAppToast(context, '회원 ID가 복사되었습니다.');
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: PassqlSpacing.xxs),
              child: Text('회원 ID $memberUuid', style: caption),
            ),
          ),
      ],
    );
  }
}
