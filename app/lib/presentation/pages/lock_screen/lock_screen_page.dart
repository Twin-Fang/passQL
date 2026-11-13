import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/monitoring/app_analytics.dart';
import '../../design/design.dart';
import '../../providers/lock_screen_providers.dart';
import '../../providers/lock_screen_question_providers.dart';
import '../../providers/plan_providers.dart';
import '../../widgets/lock_screen/lock_screen_exhausted_view.dart';
import '../../widgets/lock_screen/lock_screen_question_view.dart';
import '../../widgets/lock_screen/lock_screen_top_bar.dart';

/// 잠금화면 위 문제 화면 (잠금 엔진 전용): 상단 줄 > 본문(로딩·문제·크레딧 소진) > 채점 뒤 하단 버튼
/// 하단: 무료 "잠금 해제", 프로 해제 아이콘 + "한 문제 더"(공정 상한이면 숨김), 소진은 PRO 구매(보조) + 광고 보고 +5(주)
/// 광고·구매·결과 보기는 잠금을 푼 뒤 앱에서 엶 (Play 정책: 잠금화면 위 광고·결제 금지)
class LockScreenPage extends ConsumerStatefulWidget {
  const LockScreenPage({super.key});

  @override
  ConsumerState<LockScreenPage> createState() => _LockScreenPageState();
}

class _LockScreenPageState extends ConsumerState<LockScreenPage> {
  StreamSubscription<void>? _shownSubscription;

  LockScreenBridge get _bridge => ref.read(lockScreenBridgeProvider);

  @override
  void initState() {
    super.initState();
    // 보일 때마다 새 문제 (엔진은 재사용되므로 화면 상태를 처음으로)
    _shownSubscription = _bridge.shownSignals.listen((_) => _show());
    // Dart 준비 전에 온 첫 표시 요청
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (await _bridge.consumePendingShow()) _show();
    });
  }

  @override
  void dispose() {
    _shownSubscription?.cancel();
    super.dispose();
  }

  void _show() => ref.read(lockScreenQuestionProvider.notifier).show();

  void _close() {
    unawaited(AppAnalytics.current.logLockScreenDismissed());
    unawaited(_bridge.dismiss());
  }

  void _unlock() {
    unawaited(AppAnalytics.current.logLockScreenDismissed());
    unawaited(_bridge.unlock());
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(lockScreenQuestionProvider);
    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            LockScreenTopBar(onClose: _close),
            Expanded(
              child: PassqlFadeSwitcher(
                child: KeyedSubtree(
                  key: ValueKey(
                    '${state.phase.name}:${state.question?.questionUuid}',
                  ),
                  child: switch (state.phase) {
                    LockScreenPhase.loading => const Center(
                      child: PassqlLoadingIndicator(),
                    ),
                    LockScreenPhase.exhausted =>
                      const LockScreenExhaustedView(),
                    LockScreenPhase.question => LockScreenQuestionView(
                      state: state,
                      onChoiceTap: (choiceKey) => ref
                          .read(lockScreenQuestionProvider.notifier)
                          .submit(choiceKey),
                      onExecutionResultUnlock: () =>
                          _bridge.unlockAndOpen(LockScreenRoutes.passSheet),
                    ),
                  },
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomBar(state),
    );
  }

  /// 하단 버튼: 소진 화면은 늘, 문제는 채점 뒤에만
  Widget? _buildBottomBar(LockScreenQuestionState state) {
    if (state.phase == LockScreenPhase.exhausted) {
      return PassqlBottomActionBar(
        actions: [
          PassqlButton(
            label: 'PRO 구매',
            variant: PassqlButtonVariant.tinted,
            onPressed: () => _bridge.unlockAndOpen(LockScreenRoutes.passSheet),
          ),
          PassqlButton(
            label: '광고 보고 +5',
            icon: CupertinoIcons.play_fill,
            onPressed: () =>
                _bridge.unlockAndOpen(LockScreenRoutes.creditReward),
          ),
        ],
      );
    }
    if (state.phase != LockScreenPhase.question || !state.hasSubmitted) {
      return null;
    }
    final isPro = ref.watch(isProProvider);
    final canSolveMore = isPro && !state.isFairUseLimitReached;
    return PassqlBottomActionBar(
      actions: [
        PassqlButton(
          label: '잠금 해제',
          icon: CupertinoIcons.lock_open_fill,
          variant: canSolveMore
              ? PassqlButtonVariant.tinted
              : PassqlButtonVariant.filled,
          onPressed: _unlock,
        ),
        if (canSolveMore)
          PassqlButton(
            label: '한 문제 더',
            icon: CupertinoIcons.arrow_right,
            onPressed: () =>
                ref.read(lockScreenQuestionProvider.notifier).loadNext(),
          ),
      ],
    );
  }
}
