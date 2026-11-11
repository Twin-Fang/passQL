import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/logging/app_logger.dart';
import 'rewarded_interstitial_offer.dart';

/// 결과 화면 진입 시 보상형 전면 광고 제안 1회: 챕터 결과
/// 첫 프레임 뒤 준비(미리 불러오기, 화면을 기다리게 하지 않음) > 불러온 경우에만 안내, 화면이 떠나면 쓰지 않은 광고 해제
class RewardedInterstitialOnEnter extends StatefulWidget {
  const RewardedInterstitialOnEnter({super.key, required this.child});

  final Widget child;

  @override
  State<RewardedInterstitialOnEnter> createState() =>
      _RewardedInterstitialOnEnterState();
}

class _RewardedInterstitialOnEnterState
    extends State<RewardedInterstitialOnEnter> {
  RewardedInterstitialOffer? _offer;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) unawaited(_prepareThenPresent());
    });
  }

  /// 준비 > 결과 화면이 맨 위에 남아 있으면 제시, 다른 화면이 위에 쌓였으면 광고 해제
  Future<void> _prepareThenPresent() async {
    final offer = _offer = RewardedInterstitialOffer(
      ProviderScope.containerOf(context),
    );
    await offer.prepare();
    if (!mounted) return;
    if (ModalRoute.of(context)?.isCurrent ?? true) {
      await offer.presentIfReady(context);
    } else {
      offer.dispose();
    }
  }

  @override
  void dispose() {
    _offer?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => widget.child;
}

/// 결과 화면을 떠날 때 보상형 전면 광고 제안 1회 뒤 [onLeave] (닫기 버튼·뒤로가기 공통): 오늘의 세트 결과
/// 진입 때 미리 불러 두고(세트 보상 연출과 겹치지 않게 안내는 떠날 때), 떠날 때 아직 못 불러왔으면 바로 떠남
class RewardedInterstitialOnLeave extends StatefulWidget {
  const RewardedInterstitialOnLeave({
    super.key,
    required this.onLeave,
    required this.builder,
  });

  /// 실제로 화면을 떠나는 동작 (풀이 흐름 나가기 등)
  final void Function(BuildContext context) onLeave;

  /// [leaveWithAdOffer]: 닫기 버튼에 연결할 "제안 뒤 떠나기"
  final Widget Function(BuildContext context, VoidCallback leaveWithAdOffer)
  builder;

  @override
  State<RewardedInterstitialOnLeave> createState() =>
      _RewardedInterstitialOnLeaveState();
}

class _RewardedInterstitialOnLeaveState
    extends State<RewardedInterstitialOnLeave> {
  RewardedInterstitialOffer? _offer;

  /// 떠나는 중 (안내·광고 진행 중 닫기 연타·뒤로가기 중복 방지, 떠난 뒤에도 유지 > 화면 전환 중 두 번 나가기 방지)
  bool _isLeaving = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final offer = _offer = RewardedInterstitialOffer(
        ProviderScope.containerOf(context),
      );
      unawaited(offer.prepare());
    });
  }

  @override
  void dispose() {
    _offer?.dispose();
    super.dispose();
  }

  /// 제시(불러 둔 경우만) > 떠나기 (제시가 실패해도 떠나기는 반드시, 성공·실패 공통)
  Future<void> _leaveWithAdOffer() async {
    if (_isLeaving) return;
    _isLeaving = true;
    try {
      await _offer?.presentIfReady(context);
    } catch (error) {
      AppLogger.warn('ads rewarded interstitial', 'offer failed : $error');
    } finally {
      if (mounted) widget.onLeave(context);
    }
  }

  @override
  Widget build(BuildContext context) => PopScope(
    // 뒤로가기도 제안을 거침 (떠나기는 onLeave 가 직접 pop)
    canPop: false,
    onPopInvokedWithResult: (didPop, _) {
      if (!didPop) unawaited(_leaveWithAdOffer());
    },
    child: widget.builder(context, () => unawaited(_leaveWithAdOffer())),
  );
}
