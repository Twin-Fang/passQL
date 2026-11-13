import 'package:flutter/cupertino.dart';
import 'package:go_router/go_router.dart';

import '../../../core/auth/auth_session.dart';
import '../../../core/utils/date_format.dart';
import '../../../router/app_routes.dart';
import '../../design/design.dart';
import '../account/login_provider_appearance.dart';
import '../account/login_provider_icon.dart';

// 프로필 사진 원 지름 (누르는 영역 44 안에 들어가는 크기)
const double profileAccountAvatarSize = 40;
// 로그인 방법 아이콘 크기 (아래 줄 footnote 글자 높이)
const double _providerIconSize = PassqlIconSize.sm;
// 닉네임 불러오는 동안 자리 폭 (닉네임 평균 길이 정도)
const double _nameSkeletonWidth = 120;

/// 내 프로필 계정 줄 (#816 A안, #908): 프로필 사진 + 닉네임 + 로그인 방법 아이콘·가입일 + `관리`
/// 줄 전체가 계정·이용권 화면 진입 (닉네임 변경은 그 화면에서만), 결제 스위치와 무관하게 항상 보임
class ProfileAccountRow extends StatelessWidget {
  const ProfileAccountRow({
    super.key,
    required this.nickname,
    required this.profileImageUrl,
    required this.authProvider,
    required this.joinedAt,
    required this.isLoading,
    required this.hasError,
    required this.onRetry,
  });

  final String nickname;
  final String? profileImageUrl;
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
        semanticLabel:
            '${PassqlLoadFailureCopy.messageOf('정보를')}, ${PassqlLoadFailureCopy.retryLabel}',
        child: Text(
          '${PassqlLoadFailureCopy.messageOf('정보를')} | ${PassqlLoadFailureCopy.retryLabel}',
          style: PassqlTypography.footnote.copyWith(
            color: colors.secondaryLabel,
          ),
        ),
      );
    }
    final provider = authProvider;
    final joinedAt = this.joinedAt;
    return PassqlPressable(
      semanticLabel: [
        '닉네임 $nickname',
        if (provider != null) '${loginProviderLabelOf(provider)} 로그인',
        if (joinedAt != null) '${formatDottedDate(joinedAt)} 가입',
        '계정 관리',
      ].join(', '),
      onTap: () => context.push(AppRoutes.account),
      child: Row(
        children: [
          PassqlAvatar(
            size: profileAccountAvatarSize,
            fallbackName: nickname,
            imageUrl: profileImageUrl,
          ),
          const SizedBox(width: PassqlSpacing.sm),
          Expanded(
            child: _NicknameBlock(
              nickname: nickname,
              authProvider: provider,
              joinedAt: joinedAt,
            ),
          ),
          const SizedBox(width: PassqlSpacing.xs),
          // 줄 전체가 눌림 > 진입 표시는 목록 행과 같은 화살표 (누르는 영역 44 높이 유지)
          ConstrainedBox(
            constraints: const BoxConstraints(
              minHeight: PassqlSize.minTouchTarget,
            ),
            child: Center(
              widthFactor: 1,
              child: Icon(
                CupertinoIcons.chevron_forward,
                size: PassqlIconSize.md,
                color: colors.tertiaryLabel,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// 닉네임 + 로그인 방법 아이콘·가입일 한 줄 (읽기 전용, 스크린리더는 줄 전체 라벨로)
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
    final provider = authProvider;
    final joinedAt = this.joinedAt;
    // 예: [카카오 아이콘] 2026.10.16 가입 (아이콘이 로그인 방법, 가입일 모르면 "로그인")
    final accountSummary = joinedAt != null
        ? '${formatDottedDate(joinedAt)} 가입'
        : (provider != null ? '로그인' : '');
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          nickname,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: PassqlTypography.headline.copyWith(color: colors.label),
        ),
        if (accountSummary.isNotEmpty) ...[
          const SizedBox(height: PassqlSpacing.hairlineGap),
          Row(
            children: [
              if (provider != null) ...[
                LoginProviderIcon(
                  provider: provider,
                  size: _providerIconSize,
                  isSemanticLabelHidden: true,
                ),
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
    );
  }
}
