import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../design/design.dart';

/// 프로필 카드. 편집 버튼은 닉네임 변경 시트를, 새로고침 아이콘은 랜덤 닉네임을 부른다.
class ProfileCard extends StatelessWidget {
  const ProfileCard({
    super.key,
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
              child: Center(child: PassqlLoadingIndicator()),
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
            isFullWidth: false,
            onPressed: onEdit,
          ),
        ],
      ),
    );
  }
}

/// 로딩 스켈레톤 — 프로필 카드 자리 유지
class ProfileCardSkeleton extends StatelessWidget {
  const ProfileCardSkeleton({super.key});

  @override
  Widget build(BuildContext context) =>
      const PassqlSkeletonBox(height: 84, radius: PassqlRadius.lg);
}

class ProfileCardError extends StatelessWidget {
  const ProfileCardError({super.key, required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) => PassqlCard(
    child: PassqlStatusView.error(message: '정보를 불러오지 못했습니다.', onRetry: onRetry),
  );
}
