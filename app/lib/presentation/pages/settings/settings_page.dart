import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../router/app_routes.dart';
import '../../../core/auth/social_sign_in.dart';
import '../../../core/error/app_exception.dart';
import '../../../core/monitoring/crash_reporter.dart';
import '../../../data/models/legal/legal_models.dart';
import '../../design/design.dart';
import '../../providers/app_config_providers.dart';
import '../../providers/auth_provider.dart';
import '../../providers/notification_preference_providers.dart';
import '../../providers/settings_providers.dart';
import '../../widgets/common/app_toast.dart';
import '../../widgets/settings/choice_mode_tile.dart';
import '../../widgets/settings/notification_preference_tiles.dart';
import '../../widgets/settings/push_notification_tile.dart';
import '../../widgets/settings/theme_mode_tile.dart';
import '../../widgets/settings/settings_footer.dart';
import '../../widgets/settings/settings_group.dart';

class SettingsPage extends ConsumerWidget {
  const SettingsPage({super.key});

  /// 되돌릴 수 없는 작업이라 안내 후 한 번 더 확인받는다. 실패하면 사유를 알리고 계정은 그대로 둔다.
  Future<void> _confirmWithdraw(BuildContext context, WidgetRef ref) async {
    final isConfirmed = await showPassqlConfirmDialog(
      context,
      title: '정말 탈퇴할까요?',
      message: '계정과 개인정보가 삭제되고 되돌릴 수 없어요.\n같은 계정으로 다시 가입하면 새 계정으로 시작해요.',
      confirmLabel: '탈퇴하기',
      requiredText: '탈퇴하기',
    );
    if (!isConfirmed || !context.mounted) return;

    // 성공하면 이 화면이 사라지므로, 대화상자를 닫을 네비게이터를 미리 잡아 둔다.
    final navigator = Navigator.of(context, rootNavigator: true);
    // 진행 중에는 화면을 잠가 중복 탭을 막는다.
    showPassqlBlockingProgress(context);
    String? failureMessage;
    try {
      // 성공하면 로그인 상태가 풀려 라우터가 로그인 화면으로 보낸다.
      await ref.read(authProvider.notifier).withdraw();
    } on AppException catch (exception, stackTrace) {
      reportIfUnexpectedFailure(exception, stackTrace, reason: 'withdraw');
      failureMessage = exception.message;
    } on SocialSignInException catch (exception) {
      failureMessage = exception.message;
    } catch (exception, stackTrace) {
      reportIfUnexpectedFailure(exception, stackTrace, reason: 'withdraw');
      failureMessage = '탈퇴에 실패했어요. 잠시 후 다시 시도해 주세요.';
    }
    // 잠금 대화상자를 닫는다 (성공·실패·재인증 취소 공통).
    // maybePop 은 PopScope(canPop: false) 를 존중해 닫지 못하므로 pop 으로 닫는다.
    navigator.pop();
    if (failureMessage != null && context.mounted) {
      showAppToast(context, failureMessage);
    }
  }

  /// 실수로 누르는 것을 막기 위해 한 번 확인한 뒤 로그아웃한다.
  /// 로그아웃되면 라우터가 자동으로 로그인 화면으로 보낸다.
  Future<void> _confirmSignOut(BuildContext context, WidgetRef ref) async {
    final isConfirmed = await showPassqlConfirmDialog(
      context,
      title: '로그아웃할까요?',
      message: '다시 로그인하면 기록은 그대로 이어져요.',
      confirmLabel: '로그아웃',
    );
    if (isConfirmed) {
      await ref.read(authProvider.notifier).signOut();
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settingsAsync = ref.watch(settingsDataProvider);
    final data = settingsAsync.valueOrNull;
    // 앱 버전 원본은 시작 게이트와 같은 Provider (회원 API 실패와 무관하게 표시)
    final appVersion = ref.watch(currentAppVersionProvider).valueOrNull;
    // 알림 종류 줄은 설정을 읽었을 때만 묶음에 넣는다. 빈 줄을 넣으면 그 앞에 구분선이 남는다 (#774)
    final hasNotificationPreference =
        ref.watch(notificationPreferenceProvider).valueOrNull != null;

    return Scaffold(
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
              children: passqlRevealInOrder([
                const SettingsGroup(title: '학습', children: [ChoiceModeTile()]),
                const SizedBox(height: PassqlSpacing.xl),
                const SettingsGroup(title: '화면', children: [ThemeModeTile()]),
                const SizedBox(height: PassqlSpacing.xl),
                SettingsGroup(
                  title: '알림',
                  footer: notificationPreferenceFooter(ref),
                  // 알림함·공지는 홈 종 아이콘으로만 (여기는 받기 설정만, #863)
                  children: [
                    const PushNotificationTile(),
                    if (hasNotificationPreference)
                      for (final spec in notificationPreferenceRows)
                        NotificationPreferenceTile(spec: spec),
                  ],
                ),
                const SizedBox(height: PassqlSpacing.xl),
                SettingsGroup(
                  title: '토론',
                  children: [
                    SettingsRow(
                      icon: CupertinoIcons.person_crop_circle_badge_xmark,
                      title: '차단한 사용자 관리',
                      onTap: () => context.push(AppRoutes.blockedMembers),
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
                    // 앱 정보 (#658): 버전 표시, 누르면 빌드 번호·사업자 정보·라이선스
                    SettingsRow(
                      icon: CupertinoIcons.info,
                      title: '앱 정보',
                      trailing: appVersion == null ? null : Text(appVersion),
                      onTap: () => context.push(AppRoutes.appInfo),
                    ),
                  ],
                ),
                const SizedBox(height: PassqlSpacing.xl),
                // 계정 작업은 한 묶음, 되돌릴 수 없는 탈퇴는 맨 아래 (#774)
                SettingsGroup(
                  children: [
                    SettingsRow(
                      icon: CupertinoIcons.square_arrow_right,
                      title: '로그아웃',
                      shouldShowChevron: false,
                      onTap: () => _confirmSignOut(context, ref),
                    ),
                    // 회원 탈퇴 (스토어 심사 필수)
                    SettingsRow(
                      icon: CupertinoIcons.person_crop_circle_badge_xmark,
                      title: '회원 탈퇴',
                      isDestructive: true,
                      shouldShowChevron: false,
                      onTap: () => _confirmWithdraw(context, ref),
                    ),
                  ],
                ),
                const SizedBox(height: PassqlSpacing.xl),
                SettingsFooter(memberUuid: data?.memberUuid),
              ]),
            ),
          ),
        ],
      ),
    );
  }
}
