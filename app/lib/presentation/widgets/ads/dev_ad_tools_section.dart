import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/ads/ad_frequency_history_reset.dart';
import '../../../core/ads/ad_placement.dart';
import '../../../core/ads/rewarded_ad_player.dart';
import '../../design/design.dart';

/// 개발자 도구 광고 구역 (#809): 보상형 광고 바로 보기, 빈도 기록 초기화, 테스트 광고 여부
class DevAdToolsSection extends ConsumerStatefulWidget {
  const DevAdToolsSection({super.key});

  @override
  ConsumerState<DevAdToolsSection> createState() => _DevAdToolsSectionState();
}

class _DevAdToolsSectionState extends ConsumerState<DevAdToolsSection> {
  /// 마지막 동작 결과 한 줄
  String? _resultMessage;

  /// 보상형 광고 불러오기·시청 중
  bool _isRewardedLoading = false;

  /// 보상형 광고 바로 보기 (보너스 기록 없음, 광고 표시만 확인)
  Future<void> _playRewardedAd() async {
    setState(() => _isRewardedLoading = true);
    final outcome = await ref
        .read(rewardedAdPlayerProvider)
        .loadAndShow(AdPlacement.rewardedDailyBonus);
    if (!mounted) return;
    setState(() {
      _isRewardedLoading = false;
      _resultMessage = '보상형 광고 결과: ${outcome.name}';
    });
  }

  /// 전면·앱 오프닝 빈도 기록 초기화
  Future<void> _resetFrequencyHistory() async {
    await AdFrequencyHistoryReset.resetAll();
    if (!mounted) return;
    setState(
      () => _resultMessage = '빈도 기록 초기화: 다음 결과 화면·30초 뒤 복귀에서 바로 확인',
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.passqlColors;
    final resultMessage = _resultMessage;
    return PassqlGroupedSection(
      header: '광고',
      footer: AdUnitIds.shouldUseTestAds
          ? '테스트 광고 단위 사용 중'
          : '실제 광고 단위 사용 중 (누르지 말 것)',
      children: [
        Padding(
          padding: const EdgeInsets.all(PassqlSpacing.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              PassqlButton(
                label: '보상형 광고 바로 보기',
                variant: PassqlButtonVariant.tinted,
                size: PassqlButtonSize.regular,
                isLoading: _isRewardedLoading,
                onPressed: _playRewardedAd,
              ),
              const SizedBox(height: PassqlSpacing.xs),
              PassqlButton(
                label: '전면·앱 오프닝 빈도 기록 초기화',
                variant: PassqlButtonVariant.tinted,
                size: PassqlButtonSize.regular,
                onPressed: _resetFrequencyHistory,
              ),
              if (resultMessage != null) ...[
                const SizedBox(height: PassqlSpacing.xs),
                Text(
                  resultMessage,
                  style: PassqlTypography.footnote.copyWith(
                    color: colors.secondaryLabel,
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}
