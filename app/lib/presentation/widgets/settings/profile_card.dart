import 'package:flutter/cupertino.dart';

import '../../design/design.dart';

/// 프로필 카드: 닉네임 표시. 카드 전체가 편집 버튼 (랜덤 닉네임은 편집 시트 안, #687)
class ProfileCard extends StatelessWidget {
  const ProfileCard({
    super.key,
    required this.nickname,
    required this.onEdit,
  });

  final String nickname;
  final VoidCallback onEdit;

  @override
  Widget build(BuildContext context) {
    final colors = context.passqlColors;
    final initial = nickname.isEmpty ? '?' : nickname.characters.first;
    // 작은 '편집' 글자 대신 카드 전체를 누르게 해 누르는 영역을 넓힌다
    return PassqlPressable(
      onTap: onEdit,
      semanticLabel: '닉네임 $nickname, 편집',
      child: PassqlCard(
        child: Row(
          children: [
            Container(
              width: PassqlSize.avatar,
              height: PassqlSize.avatar,
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
              child: Text(
                nickname,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: PassqlTypography.headline.copyWith(color: colors.label),
              ),
            ),
            // 눌러서 들어간다는 iOS 표시. 목록 행보다 큰 카드라 상단 설정 아이콘과 같은 크기로 키움
            Icon(
              CupertinoIcons.chevron_forward,
              size: PassqlIconSize.xl,
              color: colors.tertiaryLabel,
            ),
          ],
        ),
      ),
    );
  }
}

/// 스켈레톤 자리 높이: 실제 프로필 카드 높이와 맞춤
const double _profileCardHeight = 72;

/// 로딩 스켈레톤 — 프로필 카드 자리 유지
class ProfileCardSkeleton extends StatelessWidget {
  const ProfileCardSkeleton({super.key});

  @override
  Widget build(BuildContext context) => const PassqlLoadingSemantics(
    child: PassqlSkeletonBox(
      height: _profileCardHeight,
      radius: PassqlRadius.lg,
    ),
  );
}

class ProfileCardError extends StatelessWidget {
  const ProfileCardError({super.key, required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) => PassqlCard(
    child: PassqlStatusView.error(message: '정보를 불러오지 못했습니다.', onRetry: onRetry),
  );
}
