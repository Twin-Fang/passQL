import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../data/models/progress/progress_response.dart';
import '../../../router/app_routes.dart';
import '../../design/design.dart';
import '../../providers/home_providers.dart';
import '../../providers/settings_providers.dart';
import '../common/app_toast.dart';
import '../settings/nickname_edit_sheet.dart';
import 'profile_pass_slot.dart';

// 이름 줄 이니셜 원 지름 (누르는 영역 44 안에 들어가는 크기)
const double _nameAvatarSize = 40;
// 누르는 영역 44 안에서 원 위아래로 생기는 빈 공간
const double _nameRowVerticalSlack = (44 - _nameAvatarSize) / 2;
// 닉네임 불러오는 동안 자리 폭 (닉네임 평균 길이 정도)
const double _nameSkeletonWidth = 120;

/// 내 프로필 첫 구간 (#749): 이름 줄 > 내 정답률 큰 숫자 + 푼 문제·연속 학습 한 줄 > 탑승권.
/// 푼 문제가 0개면 큰 숫자 대신 안내 + 버튼 하나 (지금 빈 상태 카드와 같은 분기)
class ProfileStatusSection extends ConsumerWidget {
  const ProfileStatusSection({super.key, required this.progress});

  final ProgressResponse? progress;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.passqlColors;
    final settings = ref.watch(settingsDataProvider);
    final nickname =
        ref.watch(nicknameNotifierProvider).valueOrNull ??
        settings.valueOrNull?.nickname ??
        '';
    final progressValue = progress;
    final isEmpty = (progressValue?.solvedCount ?? 0) == 0;
    return PassqlSection(
      // 영역별 정답률 구간과 같은 보이는 여백 (좌우 md, 위아래 lg).
      // 이름 줄은 누르는 영역 44 안에 40 원이 있어 위쪽 빈 공간만큼 위 여백에서 뺀다
      padding: const EdgeInsets.fromLTRB(
        PassqlSpacing.md,
        PassqlSpacing.lg - _nameRowVerticalSlack,
        PassqlSpacing.md,
        PassqlSpacing.lg,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _NameRow(
            nickname: nickname,
            isLoading: settings.isLoading && nickname.isEmpty,
            hasError: settings.hasError && nickname.isEmpty,
            onRetry: () => ref.invalidate(settingsDataProvider),
          ),
          const SizedBox(height: PassqlSpacing.md),
          if (isEmpty || progressValue == null)
            const _EmptyStatus()
          else ...[
            Text(
              '내 정답률',
              style: PassqlTypography.subheadline.copyWith(
                color: colors.secondaryLabel,
              ),
            ),
            const SizedBox(height: PassqlSpacing.hairlineGap),
            Text(
              '${(progressValue.correctRate * 100).round()}%',
              style: PassqlTypography.largeTitle.copyWith(color: colors.label),
            ),
            const SizedBox(height: PassqlSpacing.xxs),
            Text.rich(
              TextSpan(
                style: PassqlTypography.subheadline.copyWith(
                  color: colors.secondaryLabel,
                ),
                children: [
                  TextSpan(
                    text: '${progressValue.solvedCount}문제',
                    style: PassqlTypography.subheadlineSemibold.copyWith(
                      color: colors.label,
                    ),
                  ),
                  const TextSpan(text: ' 풀었어요 · '),
                  TextSpan(
                    text: '${progressValue.streakDays}일',
                    style: PassqlTypography.subheadlineSemibold.copyWith(
                      color: colors.label,
                    ),
                  ),
                  const TextSpan(text: ' 연속 학습'),
                ],
              ),
            ),
          ],
          const SizedBox(height: PassqlSpacing.md),
          ProfilePassSlot(nickname: nickname),
        ],
      ),
    );
  }
}

/// 맨 위 작은 이름 줄: 누르면 지금처럼 닉네임 편집 시트 (기존 닉네임 카드 대신)
class _NameRow extends StatelessWidget {
  const _NameRow({
    required this.nickname,
    required this.isLoading,
    required this.hasError,
    required this.onRetry,
  });

  final String nickname;
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
            height: _nameAvatarSize,
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
    final initial = nickname.isEmpty ? '?' : nickname.characters.first;
    return Align(
      alignment: Alignment.centerLeft,
      child: PassqlPressable(
        hasMinimumTouchTarget: true,
        semanticLabel: '닉네임 $nickname, 편집',
        onTap: () async {
          final isChanged = await NicknameEditSheet.show(context, nickname);
          if (isChanged == true && context.mounted) {
            showAppToast(context, '닉네임이 변경됐어요');
          }
        },
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: _nameAvatarSize,
              height: _nameAvatarSize,
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
            Flexible(
              child: Text(
                nickname,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: PassqlTypography.title3.copyWith(color: colors.label),
              ),
            ),
            Icon(
              CupertinoIcons.chevron_forward,
              size: PassqlIconSize.md,
              color: colors.tertiaryLabel,
            ),
          ],
        ),
      ),
    );
  }
}

/// 푼 문제 0개: 안내 + 버튼 하나. 오늘의 세트를 풀 수 있으면 세트, 아니면 문제 탭
class _EmptyStatus extends ConsumerWidget {
  const _EmptyStatus();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.passqlColors;
    // 세트 상태는 늦게 와도 막지 않음 (오기 전엔 문제 탭 안내)
    final dailySet = ref.watch(profileDailySetProvider).valueOrNull;
    final hasDailySet =
        dailySet != null &&
        dailySet.questions.isNotEmpty &&
        !dailySet.alreadyCompleted;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Semantics(
          header: true,
          child: Text(
            '아직 푼 문제가 없어요',
            style: PassqlTypography.title3.copyWith(color: colors.label),
          ),
        ),
        const SizedBox(height: PassqlSpacing.xxs),
        Text(
          '문제를 풀면 정답률이 여기 쌓여요',
          style: PassqlTypography.subheadline.copyWith(
            color: colors.secondaryLabel,
          ),
        ),
        const SizedBox(height: PassqlSpacing.sm),
        PassqlButton(
          label: hasDailySet ? '오늘의 세트 풀기' : '문제 풀러 가기',
          onPressed: hasDailySet
              ? () => context.push(AppRoutes.dailySet)
              : () => context.go(AppRoutes.questions),
        ),
      ],
    );
  }
}
