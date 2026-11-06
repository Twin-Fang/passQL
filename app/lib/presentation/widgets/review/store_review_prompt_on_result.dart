import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/review/store_review_prompter.dart';
import '../../providers/store_review_providers.dart';

/// 학습을 막 끝낸 결과 화면 진입 시 스토어 평가 요청 1회 시도 (화면에는 아무것도 그리지 않음)
/// 조건·대기·기록은 StoreReviewPrompter, 이 위젯은 결과 화면이 아직 앞에 있는지만 알려 줌
class StoreReviewPromptOnResult extends ConsumerStatefulWidget {
  const StoreReviewPromptOnResult({
    super.key,
    required this.trigger,
    required this.isGoodResult,
    required this.child,
  });

  final StoreReviewTrigger trigger;

  /// 좋은 결과인지 (오늘의 세트 정답률 60% 이상, 모의고사 합격)
  final bool isGoodResult;
  final Widget child;

  @override
  ConsumerState<StoreReviewPromptOnResult> createState() =>
      _StoreReviewPromptOnResultState();
}

class _StoreReviewPromptOnResultState
    extends ConsumerState<StoreReviewPromptOnResult> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      unawaited(
        ref
            .read(storeReviewPrompterProvider)
            .recordStudyCompletedAndRequestIfEligible(
              trigger: widget.trigger,
              isGoodResult: widget.isGoodResult,
              isResultStillVisible: _isResultStillVisible,
            ),
      );
    });
  }

  // 결과 화면이 맨 위 경로 + 앱이 앞에 있음 (다른 화면으로 갔거나 백그라운드면 요청하지 않음)
  bool _isResultStillVisible() =>
      mounted &&
      (ModalRoute.of(context)?.isCurrent ?? false) &&
      WidgetsBinding.instance.lifecycleState == AppLifecycleState.resumed;

  @override
  Widget build(BuildContext context) => widget.child;
}
