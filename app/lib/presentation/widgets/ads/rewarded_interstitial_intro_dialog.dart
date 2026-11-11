import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../design/design.dart';

// 광고 시작까지 기다리는 시간 (초, 그동안 건너뛰기 가능)
const int rewardedInterstitialIntroCountdownSeconds = 5;

// 카운트다운 한 칸 (1초)
const Duration _countdownTickInterval = Duration(seconds: 1);

/// 보상형 전면 광고 안내 (AdMob 정책: 광고 전 보상 안내 + 건너뛰기, #963)
/// 제목(+N문제) > N초 카운트다운 > 건너뛰기. 카운트다운이 끝나면 true(광고 시작), 건너뛰기·뒤로가기면 false
Future<bool> showRewardedInterstitialIntroDialog(
  BuildContext context, {
  required int bonusQuestionCount,
}) async {
  final shouldStartAd = await showDialog<bool>(
    context: context,
    useRootNavigator: true,
    // 바깥을 잘못 눌러 닫히지 않게 (건너뛰기·뒤로가기로만 닫힘)
    barrierDismissible: false,
    builder: (_) =>
        _RewardedInterstitialIntroPanel(bonusQuestionCount: bonusQuestionCount),
  );
  return shouldStartAd ?? false;
}

class _RewardedInterstitialIntroPanel extends StatefulWidget {
  const _RewardedInterstitialIntroPanel({required this.bonusQuestionCount});

  final int bonusQuestionCount;

  @override
  State<_RewardedInterstitialIntroPanel> createState() =>
      _RewardedInterstitialIntroPanelState();
}

class _RewardedInterstitialIntroPanelState
    extends State<_RewardedInterstitialIntroPanel> {
  int _remainingSeconds = rewardedInterstitialIntroCountdownSeconds;
  Timer? _countdownTimer;

  @override
  void initState() {
    super.initState();
    _countdownTimer = Timer.periodic(_countdownTickInterval, (_) => _tick());
  }

  @override
  void dispose() {
    _countdownTimer?.cancel();
    super.dispose();
  }

  /// 1초 줄이기 > 0이면 광고 시작으로 닫기
  void _tick() {
    if (!mounted) return;
    if (_remainingSeconds <= 1) {
      _closeWith(shouldStartAd: true);
      return;
    }
    setState(() => _remainingSeconds--);
  }

  /// 타이머 멈춘 뒤 1회만 자기 창 닫기 (건너뛰기·카운트다운 끝 공통)
  /// 위에 다른 창(세트 보상 연출 등)이 쌓였으면 그 창은 두고 이 창만 제거 + 광고 시작 안 함
  void _closeWith({required bool shouldStartAd}) {
    final countdownTimer = _countdownTimer;
    final introRoute = ModalRoute.of<bool>(context);
    if (countdownTimer == null || introRoute == null) return;
    countdownTimer.cancel();
    _countdownTimer = null;
    closePassqlDialogRoute<bool>(
      Navigator.of(context),
      introRoute,
      shouldStartAd && introRoute.isCurrent,
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.passqlColors;
    return Dialog(
      backgroundColor: colors.card,
      insetPadding: const EdgeInsets.all(PassqlSpacing.xl),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(PassqlRadius.lg),
      ),
      child: Padding(
        padding: const EdgeInsets.all(PassqlSpacing.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            PassqlIconTile(
              icon: CupertinoIcons.play_fill,
              color: colors.accent,
            ),
            const SizedBox(height: PassqlSpacing.md),
            Text(
              '광고를 보면 ${widget.bonusQuestionCount}문제가 더 열려요',
              textAlign: TextAlign.center,
              style: PassqlTypography.title3.copyWith(color: colors.label),
            ),
            const SizedBox(height: PassqlSpacing.xs),
            // 스크린리더가 바뀐 초를 읽게 함
            Semantics(
              liveRegion: true,
              child: Text(
                '$_remainingSeconds초 뒤 광고가 시작돼요',
                textAlign: TextAlign.center,
                style: PassqlTypography.subheadline.copyWith(
                  color: colors.secondaryLabel,
                  fontFeatures: PassqlTypography.tabular,
                ),
              ),
            ),
            const SizedBox(height: PassqlSpacing.xl),
            PassqlButton(
              label: '건너뛰기',
              variant: PassqlButtonVariant.tinted,
              onPressed: () => _closeWith(shouldStartAd: false),
            ),
          ],
        ),
      ),
    );
  }
}
