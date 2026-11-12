import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/utils/app_clock.dart';
import '../../../core/utils/date_format.dart';
import '../../design/design.dart';
import '../../providers/plan_providers.dart';
import '../practice/remaining_solves_pill.dart';

/// 잠금화면 상단 줄: 작은 시계·날짜 > 크레딧 알약(무료, 값 바뀌면 튐) 또는 PRO 마크(프로) > 닫기
/// [onClose] 없으면 닫기 버튼 없음 (미리보기)
class LockScreenTopBar extends ConsumerStatefulWidget {
  const LockScreenTopBar({super.key, this.onClose});

  final VoidCallback? onClose;

  @override
  ConsumerState<LockScreenTopBar> createState() => _LockScreenTopBarState();
}

class _LockScreenTopBarState extends ConsumerState<LockScreenTopBar> {
  // 시계 다시 그리는 주기 (분 단위 표시라 30초면 늦어도 30초 안에 맞음)
  static const Duration _clockRefreshInterval = Duration(seconds: 30);

  Timer? _clockTimer;

  @override
  void initState() {
    super.initState();
    _clockTimer = Timer.periodic(_clockRefreshInterval, (_) => setState(() {}));
  }

  @override
  void dispose() {
    _clockTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.passqlColors;
    final now = AppClock.now();
    final isPro = ref.watch(isProProvider);
    final onClose = widget.onClose;
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        PassqlSpacing.md,
        PassqlSpacing.xs,
        PassqlSpacing.xs,
        PassqlSpacing.xxs,
      ),
      child: Row(
        children: [
          Text(
            formatClockTime(now),
            style: PassqlTypography.headline.copyWith(
              color: colors.label,
              fontFeatures: PassqlTypography.tabular,
            ),
          ),
          const SizedBox(width: PassqlSpacing.xs),
          Expanded(
            child: Text(
              formatMonthDayWeekday(now),
              style: PassqlTypography.footnote.copyWith(
                color: colors.secondaryLabel,
              ),
            ),
          ),
          if (isPro)
            const _ProMarkPill()
          else
            const RemainingSolvesPill(isCompact: true),
          if (onClose != null) ...[
            const SizedBox(width: PassqlSpacing.xxs),
            PassqlNavButton(kind: PassqlNavLeading.close, onTap: onClose),
          ] else
            const SizedBox(width: PassqlSpacing.xs),
        ],
      ),
    );
  }
}

/// 프로 표시 알약: 옅은 강조 바탕 + PRO 마크·글자
class _ProMarkPill extends StatelessWidget {
  const _ProMarkPill();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: PassqlSpacing.xs,
        vertical: PassqlSpacing.xxs,
      ),
      decoration: BoxDecoration(
        color: context.passqlColors.accentTint,
        borderRadius: BorderRadius.circular(PassqlRadius.capsule),
      ),
      child: const PassqlProMark(shouldShowLabel: true),
    );
  }
}
