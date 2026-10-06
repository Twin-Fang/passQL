import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../../core/app_colors.dart';
import '../../../core/text_styles.dart';
import '../../../router/app_routes.dart';
import '../../../core/auth/social_sign_in.dart';
import '../../../core/error/app_exception.dart';
import '../../../data/models/legal/legal_models.dart';
import '../../providers/auth_provider.dart';
import '../../providers/settings_providers.dart';
import '../../widgets/common/app_toast.dart';
import '../../widgets/settings/choice_mode_tile.dart';
import '../../widgets/settings/nickname_edit_sheet.dart';
import '../../providers/wrong_questions_provider.dart';
import '../../widgets/settings/settings_group.dart';

class SettingsPage extends ConsumerWidget {
  const SettingsPage({super.key});

  /// 되돌릴 수 없는 작업이라 안내 후 한 번 더 확인받는다. 실패하면 사유를 알리고 계정은 그대로 둔다.
  Future<void> _confirmWithdraw(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('정말 탈퇴할까요?'),
        content: const Text(
          '계정과 개인정보가 삭제되고 되돌릴 수 없어요.\n같은 계정으로 다시 가입하면 새 계정으로 시작해요.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('취소'),
          ),
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text('탈퇴하기'),
          ),
        ],
      ),
    );
    if (confirmed != true || !context.mounted) return;

    // 성공하면 이 화면이 사라지므로, 대화상자를 닫을 네비게이터를 미리 잡아 둔다.
    final navigator = Navigator.of(context, rootNavigator: true);
    // 진행 중에는 화면을 잠가 중복 탭을 막는다.
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (_) => const PopScope(
        canPop: false,
        child: Center(child: CircularProgressIndicator()),
      ),
    );
    String? failure;
    try {
      // 성공하면 로그인 상태가 풀려 라우터가 로그인 화면으로 보낸다.
      await ref.read(authProvider.notifier).withdraw();
    } on AppException catch (e) {
      failure = e.message;
    } on SocialSignInException catch (e) {
      failure = e.message;
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
    final wrongCount = ref
        .watch(wrongQuestionsProvider)
        .valueOrNull
        ?.totalCount;

    return Scaffold(
      backgroundColor: AppColors.pageBg,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
          children: [
            Text('설정', style: AppTextStyles.heading_24),
            const SizedBox(height: 20),
            // 프로필: 닉네임만 크게 보여 주고, 내부 식별자(회원 ID)는 하단으로 내린다.
            settingsAsync.when(
              loading: () => const _ProfileSkeleton(),
              error: (e, _) => _ProfileError(
                onRetry: () => ref.invalidate(settingsDataProvider),
              ),
              data: (data) {
                // 닉네임은 nicknameNotifier 상태 우선 (재생성 반영)
                final nickname = nicknameAsync.valueOrNull ?? data.nickname;
                return _ProfileCard(
                  nickname: nickname,
                  isRegenerating: nicknameAsync.isLoading,
                  onRegenerate: () =>
                      ref.read(nicknameNotifierProvider.notifier).regenerate(),
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
            const SizedBox(height: 28),
            SettingsGroup(
              title: '학습',
              children: [
                SettingsRow(
                  icon: FontAwesomeIcons.bookBookmark,
                  title: '오답 노트',
                  trailing: wrongCount == null
                      ? null
                      : Text(
                          '$wrongCount',
                          style: AppTextStyles.paragraph_14.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                  onTap: () => context.push(AppRoutes.wrongNotes),
                ),
                const ChoiceModeTile(),
              ],
            ),
            const SizedBox(height: 28),
            SettingsGroup(
              title: '지원',
              children: [
                SettingsRow(
                  icon: FontAwesomeIcons.comment,
                  title: '건의사항',
                  onTap: () => context.push(AppRoutes.feedback),
                ),
                SettingsRow(
                  icon: FontAwesomeIcons.fileLines,
                  title: '이용약관',
                  onTap: () => context.push(
                    AppRoutes.legal(LegalType.termsOfService.serverValue),
                  ),
                ),
                SettingsRow(
                  icon: FontAwesomeIcons.shieldHalved,
                  title: '개인정보처리방침',
                  onTap: () => context.push(
                    AppRoutes.legal(LegalType.privacyPolicy.serverValue),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 28),
            SettingsGroup(
              title: '계정',
              children: [
                SettingsRow(
                  icon: FontAwesomeIcons.rightFromBracket,
                  title: '로그아웃',
                  showChevron: false,
                  onTap: () => _confirmSignOut(context, ref),
                ),
                // 회원 탈퇴 (스토어 심사 필수)
                SettingsRow(
                  icon: FontAwesomeIcons.userXmark,
                  title: '회원 탈퇴',
                  destructive: true,
                  showChevron: false,
                  onTap: () => _confirmWithdraw(context, ref),
                ),
              ],
            ),
            const SizedBox(height: 32),
            _Footer(
              version: settingsAsync.valueOrNull?.version,
              memberUuid: settingsAsync.valueOrNull?.memberUuid,
            ),
          ],
        ),
      ),
    );
  }
}

/// 프로필 카드. 카드를 누르면 닉네임 편집, 오른쪽 버튼은 랜덤 닉네임.
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
    final initial = nickname.isEmpty ? '?' : nickname.characters.first;
    return Material(
      color: AppColors.cardBg,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onEdit,
        child: Container(
          padding: const EdgeInsets.fromLTRB(16, 16, 8, 16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.borderDefault),
          ),
          child: Row(
            children: [
              CircleAvatar(
                radius: 26,
                backgroundColor: AppColors.accentLight,
                child: Text(
                  initial,
                  style: AppTextStyles.heading_20.copyWith(
                    color: AppColors.brandIndigo,
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      nickname,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.subHeading_18.copyWith(
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '눌러서 닉네임 변경',
                      style: AppTextStyles.tag_12.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              if (isRegenerating)
                const SizedBox(
                  width: 44,
                  height: 44,
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
              else
                IconButton(
                  tooltip: '랜덤 닉네임',
                  icon: const FaIcon(FontAwesomeIcons.arrowsRotate, size: 16),
                  color: AppColors.textCaption,
                  onPressed: onRegenerate,
                ),
            ],
          ),
        ),
      ),
    );
  }
}

/// 로딩 스켈레톤 — 프로필 카드 자리 유지
class _ProfileSkeleton extends StatelessWidget {
  const _ProfileSkeleton();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 86,
      decoration: BoxDecoration(
        color: AppColors.cardBg,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.borderDefault),
      ),
    );
  }
}

class _ProfileError extends StatelessWidget {
  const _ProfileError({required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cardBg,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.borderDefault),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              '정보를 불러오지 못했습니다.',
              style: AppTextStyles.paragraph_14.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ),
          TextButton(onPressed: onRetry, child: const Text('다시 시도')),
        ],
      ),
    );
  }
}

/// 하단 정보: 버전과 회원 ID(문의 시 필요). 회원 ID 는 눌러서 복사한다.
class _Footer extends StatelessWidget {
  const _Footer({required this.version, required this.memberUuid});

  final String? version;
  final String? memberUuid;

  @override
  Widget build(BuildContext context) {
    final caption = AppTextStyles.tag_12.copyWith(color: AppColors.textCaption);
    return Column(
      children: [
        Image.asset('assets/logo.png', height: 20),
        const SizedBox(height: 8),
        if (version != null) Text('버전 $version', style: caption),
        if (memberUuid != null)
          GestureDetector(
            onTap: () async {
              await Clipboard.setData(ClipboardData(text: memberUuid!));
              if (!context.mounted) return;
              showAppToast(context, '회원 ID가 복사되었습니다.');
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Text('회원 ID $memberUuid', style: caption),
            ),
          ),
      ],
    );
  }
}
