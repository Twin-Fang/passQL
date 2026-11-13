import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../router/app_routes.dart';
import '../../design/design.dart';
import '../../providers/lock_screen_providers.dart';
import 'lock_screen_phone_illustration.dart';

/// 잠금화면 소개 시트 (#990): 미니 폰 반복 그림 > 제목 > 한 줄 세 개 > 미리 풀어 보기 / 나중에
/// 노출 기록은 시트를 띄우기 전에 (닫는 방법과 무관하게 횟수 셈)
Future<void> showLockScreenIntroSheet(BuildContext context) async {
  await recordLockScreenIntroShown();
  if (!context.mounted) return;
  final shouldOpenPreview = await showPassqlSheet<bool>(
    context,
    builder: (sheetContext) => _LockScreenIntroBody(
      onPreview: () => Navigator.of(sheetContext).pop(true),
      onLater: () => Navigator.of(sheetContext).pop(false),
    ),
  );
  if (shouldOpenPreview == true && context.mounted) {
    unawaited(context.push(AppRoutes.lockScreenPreview));
  }
}

class _LockScreenIntroBody extends StatelessWidget {
  const _LockScreenIntroBody({required this.onPreview, required this.onLater});

  final VoidCallback onPreview;
  final VoidCallback onLater;

  // 한 줄 세 개: 무료(크레딧 젬, #1041), 기록, 언제든 끔. 아이콘 null = 크레딧 젬
  static const List<(IconData?, String)> _lines = [
    (null, '하루 크레딧으로 무료로 써요'),
    (CupertinoIcons.checkmark_seal_fill, '풀면 오늘 기록에 그대로 쌓여요'),
    (CupertinoIcons.power, '바로 닫을 수 있고, 언제든 끌 수 있어요'),
  ];

  @override
  Widget build(BuildContext context) {
    final colors = context.passqlColors;
    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          PassqlSpacing.md,
          0,
          PassqlSpacing.md,
          PassqlSpacing.md,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Center(child: LockScreenPhoneIllustration()),
            const SizedBox(height: PassqlSpacing.md),
            Semantics(
              header: true,
              child: PassqlKeepAllText(
                '화면 켤 때 한 문제씩 풀어요',
                textAlign: TextAlign.center,
                style: PassqlTypography.title2.copyWith(color: colors.label),
              ),
            ),
            const SizedBox(height: PassqlSpacing.md),
            for (final (index, (icon, text)) in _lines.indexed)
              PassqlReveal(
                index: index + 1,
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    vertical: PassqlSpacing.xxs,
                  ),
                  child: Row(
                    children: [
                      icon == null
                          ? const PassqlCreditIcon(size: PassqlIconSize.lg)
                          : Icon(
                              icon,
                              size: PassqlIconSize.lg,
                              color: colors.accent,
                            ),
                      const SizedBox(width: PassqlSpacing.sm),
                      Expanded(
                        child: PassqlKeepAllText(
                          text,
                          style: PassqlTypography.subheadline.copyWith(
                            color: colors.label,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            const SizedBox(height: PassqlSpacing.md),
            PassqlButton(label: '미리 한 문제 풀어 보기', onPressed: onPreview),
            const SizedBox(height: PassqlSpacing.xs),
            PassqlButton(
              label: '나중에',
              variant: PassqlButtonVariant.plain,
              onPressed: onLater,
            ),
          ],
        ),
      ),
    );
  }
}

/// 학습을 끝낸 결과 화면에서 소개 시트 1회 시도 (화면에는 아무것도 그리지 않음)
/// [hasStudiedEnoughToday]: 세트 완료면 true, 랜덤 풀기면 오늘 제출 3개 이상
/// 결과 연출(보상·평가 창)이 닫혀 결과 화면이 맨 위가 될 때까지 기다렸다가 1회 판정
class LockScreenIntroOnResult extends ConsumerStatefulWidget {
  const LockScreenIntroOnResult({
    super.key,
    required this.hasStudiedEnoughToday,
    required this.child,
  });

  final bool Function(WidgetRef ref) hasStudiedEnoughToday;
  final Widget child;

  @override
  ConsumerState<LockScreenIntroOnResult> createState() =>
      _LockScreenIntroOnResultState();
}

class _LockScreenIntroOnResultState
    extends ConsumerState<LockScreenIntroOnResult> {
  // 결과 화면 진입 뒤 첫 확인까지 기다림 (진입 연출이 끝난 뒤), 이후 같은 간격으로 다시 확인
  static const Duration _checkInterval = Duration(milliseconds: 1500);
  // 보상 창 등이 오래 떠 있어도 이 횟수까지만 다시 확인 (약 1분)
  static const int _maximumCheckCount = 40;

  Timer? _checkTimer;
  int _checkCount = 0;

  @override
  void initState() {
    super.initState();
    _checkTimer = Timer.periodic(_checkInterval, (_) => _checkOnce());
  }

  @override
  void dispose() {
    _checkTimer?.cancel();
    super.dispose();
  }

  /// 확인 1회: 결과 화면이 맨 위 아니면 다음 확인으로 미룸 > 맨 위면 판정 1회 후 종료
  Future<void> _checkOnce() async {
    _checkCount += 1;
    if (!mounted || _checkCount > _maximumCheckCount) return _stopChecking();
    if (ModalRoute.of(context)?.isCurrent != true) return;
    _stopChecking();
    // 앱 설정 응답이 늦게 와도 반영되게 판정 시점에 읽음
    if (!ref.read(isLockScreenAvailableProvider)) return;
    final shouldShow = await shouldShowLockScreenIntro(
      ref,
      hasStudiedEnoughToday: widget.hasStudiedEnoughToday(ref),
    );
    if (!shouldShow || !mounted) return;
    if (ModalRoute.of(context)?.isCurrent != true) return;
    await showLockScreenIntroSheet(context);
  }

  void _stopChecking() {
    _checkTimer?.cancel();
    _checkTimer = null;
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
