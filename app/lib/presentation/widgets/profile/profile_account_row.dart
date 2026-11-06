import 'package:flutter/cupertino.dart';
import 'package:go_router/go_router.dart';

import '../../../core/auth/auth_session.dart';
import '../../../core/utils/date_format.dart';
import '../../../router/app_routes.dart';
import '../../design/design.dart';
import '../account/login_provider_badge.dart';
import '../common/app_toast.dart';
import 'nickname_edit_sheet.dart';

// 이니셜 원 지름 (누르는 영역 44 안에 들어가는 크기)
const double profileAccountAvatarSize = 40;
// 닉네임 불러오는 동안 자리 폭 (닉네임 평균 길이 정도)
const double _nameSkeletonWidth = 120;

/// 내 프로필 계정 줄 (#816 A안): 이니셜 + 닉네임(연필 = 눌러서 편집, #863) + 로그인 방법 배지·가입일 + `관리` > 계정·이용권 화면
/// 계정 정보는 결제 스위치와 무관하게 항상 보임
class ProfileAccountRow extends StatelessWidget {
  const ProfileAccountRow({
    super.key,
    required this.nickname,
    required this.authProvider,
    required this.joinedAt,
    required this.isLoading,
    required this.hasError,
    required this.onRetry,
  });

  final String nickname;
  final SocialProvider? authProvider;
  final DateTime? joinedAt;
  final bool isLoading;
  final bool hasError;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final colors = context.passqlColors;
    if (isLoading) {
      return const PassqlLoadingSemantics(
        child: Align(
          alignment: Alignment.centerLeft,
          child: PassqlSkeletonBox(
            width: _nameSkeletonWidth,
            height: profileAccountAvatarSize,
          ),
        ),
      );
    }
    if (hasError) {
      return PassqlPressable(
        onTap: onRetry,
        semanticLabel: '정보를 불러오지 못했어요, 다시 시도',
        child: Text(
          '정보를 불러오지 못했어요 · 다시 시도',
          style: PassqlTypography.footnote.copyWith(
            color: colors.secondaryLabel,
          ),
        ),
      );
    }
    return Row(
      children: [
        Expanded(
          child: _NicknameBlock(
            nickname: nickname,
            authProvider: authProvider,
            joinedAt: joinedAt,
          ),
        ),
        const SizedBox(width: PassqlSpacing.xs),
        PassqlPressable(
          hasMinimumTouchTarget: true,
          semanticLabel: '계정·이용권 관리',
          onTap: () => context.push(AppRoutes.account),
          child: Text(
            '관리',
            style: PassqlTypography.subheadlineSemibold.copyWith(
              color: colors.accentText,
            ),
          ),
        ),
      ],
    );
  }
}

/// 이니셜 + 닉네임 + 로그인 방법·가입일 한 줄. 누르면 닉네임 편집 시트
class _NicknameBlock extends StatelessWidget {
  const _NicknameBlock({
    required this.nickname,
    required this.authProvider,
    required this.joinedAt,
  });

  final String nickname;
  final SocialProvider? authProvider;
  final DateTime? joinedAt;

  @override
  Widget build(BuildContext context) {
    final colors = context.passqlColors;
    final initial = nickname.isEmpty ? '?' : nickname.characters.first;
    final provider = authProvider;
    final joinedAt = this.joinedAt;
    // 예: 로그인 · 2026.10.16 가입 (가입일 모르면 로그인만)
    final accountSummary = [
      if (provider != null) '로그인',
      if (joinedAt != null) '${formatDottedDate(joinedAt)} 가입',
    ].join(' · ');
    return PassqlPressable(
      semanticLabel: [
        '닉네임 $nickname, 편집',
        if (provider != null) '${loginProviderLabelOf(provider)} 로그인',
        if (joinedAt != null) '${formatDottedDate(joinedAt)} 가입',
      ].join(', '),
      onTap: () async {
        final isChanged = await NicknameEditSheet.show(context, nickname);
        if (isChanged == true && context.mounted) {
          showAppToast(context, '닉네임이 변경됐어요');
        }
      },
      child: Row(
        children: [
          Container(
            width: profileAccountAvatarSize,
            height: profileAccountAvatarSize,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: colors.accentTint,
              shape: BoxShape.circle,
            ),
            child: Text(
              initial,
              style: PassqlTypography.headline.copyWith(
                color: colors.accentText,
              ),
            ),
          ),
          const SizedBox(width: PassqlSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        nickname,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: PassqlTypography.headline.copyWith(
                          color: colors.label,
                        ),
                      ),
                    ),
                    // 이동(›)이 아니라 편집이라 연필, 누를 수 있게 강조색
                    const SizedBox(width: PassqlSpacing.xxs),
                    Icon(
                      CupertinoIcons.pencil,
                      size: PassqlIconSize.md,
                      color: colors.accentText,
                    ),
                  ],
                ),
                if (accountSummary.isNotEmpty) ...[
                  const SizedBox(height: PassqlSpacing.hairlineGap),
                  Row(
                    children: [
                      if (provider != null) ...[
                        LoginProviderBadge(provider: provider),
                        const SizedBox(width: PassqlSpacing.xxs),
                      ],
                      Flexible(
                        child: Text(
                          accountSummary,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: PassqlTypography.footnote.copyWith(
                            color: colors.secondaryLabel,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
