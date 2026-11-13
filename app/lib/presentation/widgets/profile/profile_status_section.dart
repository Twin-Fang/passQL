import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../data/models/progress/progress_response.dart';
import '../../../router/app_routes.dart';
import '../../design/design.dart';
import '../../providers/home_providers.dart';
import '../../providers/settings_providers.dart';
import 'profile_account_row.dart';

// 누르는 영역 44 안에서 이니셜 원 위아래로 생기는 빈 공간
const double _nameRowVerticalSlack =
    (PassqlSize.minTouchTarget - profileAccountAvatarSize) / 2;

/// 내 프로필 첫 구간 (#749, #816 A안, #971): 계정 줄 > 통계 3칸(정답률·푼 문제·연속 학습). 크레딧·이용권은 다음 구간(ProfilePlanSection)
/// 푼 문제가 0개면 큰 숫자 대신 안내 + 버튼 하나 (지금 빈 상태 카드와 같은 분기)
class ProfileStatusSection extends ConsumerWidget {
  const ProfileStatusSection({super.key, required this.progress});

  final ProgressResponse? progress;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
          ProfileAccountRow(
            nickname: nickname,
            profileImageUrl: settings.valueOrNull?.profileImageUrl,
            authProvider: settings.valueOrNull?.authProvider,
            joinedAt: settings.valueOrNull?.joinedAt,
            isLoading: settings.isLoading && nickname.isEmpty,
            hasError: settings.hasError && nickname.isEmpty,
            onRetry: () => ref.invalidate(settingsDataProvider),
          ),
          const SizedBox(height: PassqlSpacing.md),
          if (isEmpty || progressValue == null)
            const _EmptyStatus()
          else ...[
            // 통계 3칸: 정답률 · 푼 문제 · 연속 학습 (세로 구분선)
            _StatColumns(
              stats: [
                (
                  value: '${(progressValue.correctRate * 100).round()}%',
                  label: '정답률',
                ),
                (value: '${progressValue.solvedCount}', label: '푼 문제'),
                (value: '${progressValue.streakDays}일', label: '연속 학습'),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

/// 통계 칸 묶음: 값(큰 글자) + 이름, 칸 사이 세로 구분선. 스크린리더는 `정답률 62%` 처럼 이름 먼저
class _StatColumns extends StatelessWidget {
  const _StatColumns({required this.stats});

  final List<({String value, String label})> stats;

  // 세로 구분선 높이·두께
  static const double _dividerHeight = 28;
  static const double _dividerWidth = 0.5;

  @override
  Widget build(BuildContext context) {
    final colors = context.passqlColors;
    return Row(
      children: [
        for (var index = 0; index < stats.length; index++) ...[
          if (index > 0)
            Container(
              width: _dividerWidth,
              height: _dividerHeight,
              color: colors.separator,
            ),
          Expanded(
            child: Semantics(
              label: '${stats[index].label} ${stats[index].value}',
              excludeSemantics: true,
              child: Column(
                children: [
                  Text(
                    stats[index].value,
                    style: PassqlTypography.title2.copyWith(
                      color: colors.label,
                      fontFeatures: PassqlTypography.tabular,
                    ),
                  ),
                  const SizedBox(height: PassqlSpacing.hairlineGap),
                  Text(
                    stats[index].label,
                    style: PassqlTypography.footnote.copyWith(
                      color: colors.secondaryLabel,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ],
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
