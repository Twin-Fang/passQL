import 'dart:math' as math;

import 'package:flutter/rendering.dart' show ScrollDirection;
import 'package:flutter/semantics.dart';
import 'package:flutter/widgets.dart';

import '../passql_haptics.dart';
import '../passql_theme.dart';
import '../tokens/passql_tokens.dart';
import 'passql_button.dart';
import 'passql_fade_switcher.dart';
import 'passql_memo_canvas.dart';
import 'passql_memo_controller.dart';
import 'passql_pressable.dart';
import 'passql_semantic_button.dart';
import 'passql_svg_path.dart';

// 메모 틀 조각 3개: 펜 버튼(끔), 도구 막대(켬), 직접 그린 도구 아이콘
part 'memo/memo_toggle_button.dart';
part 'memo/memo_toolbar.dart';
part 'memo/memo_tool_icon.dart';

/// 풀이 화면 메모 틀: 끔이면 오른쪽 아래 펜 버튼, 켬이면 아래 도구 막대 + 위 안내를 문항 영역 위에 띄움
/// 안쪽 [PassqlMemoCanvas] 가 이 상태로 그림. 화면은 컨트롤러를 State 에 두고(응시 동안 유지) 문항 영역을 감싸기만 함
/// 펜 버튼은 내용을 아래로 읽는 동안 숨김 > 위로 올리거나 맨 위·맨 아래면 다시 보임 (보기 카드 가림 방지, #995)
class PassqlMemoScope extends StatefulWidget {
  const PassqlMemoScope({
    super.key,
    required this.controller,
    required this.activePageKey,
    required this.child,
  });

  final PassqlMemoController controller;

  /// 지금 보이는 문항 (펜 버튼의 메모 있음 점·되돌리기 대상)
  final Object activePageKey;
  final Widget child;

  /// 메모 층 아래 여백: 펜 버튼(+위아래 틈)이 마지막 내용을 가리지 않게
  static const double floatingControlsReservedHeight =
      _toggleButtonSize + PassqlSpacing.sm;

  static const String memoModeHint = '메모 중이에요. 보기를 고르려면 메모를 끄세요';

  /// 가장 가까운 메모 틀의 컨트롤러 (없으면 null, 상태가 바뀌면 다시 그림)
  static PassqlMemoController? maybeControllerOf(BuildContext context) =>
      context
          .dependOnInheritedWidgetOfExactType<_PassqlMemoInheritedController>()
          ?.notifier;

  @override
  State<PassqlMemoScope> createState() => _PassqlMemoScopeState();
}

class _PassqlMemoScopeState extends State<PassqlMemoScope> {
  /// 아래로 읽는 중이라 펜 버튼을 숨겼는지
  bool _isToggleButtonHidden = false;

  PassqlMemoController get controller => widget.controller;

  @override
  void didUpdateWidget(PassqlMemoScope oldWidget) {
    super.didUpdateWidget(oldWidget);
    // 다음 문항은 맨 위부터 > 펜 버튼 다시 보임
    if (oldWidget.activePageKey != widget.activePageKey) {
      _isToggleButtonHidden = false;
    }
  }

  /// 세로 스크롤 > 펜 버튼 숨김·보임 (가로 스크롤 표는 무시, 끝을 알리지 않음)
  bool _onScrollNotification(ScrollNotification notification) {
    final metrics = notification.metrics;
    if (metrics.axis != Axis.vertical) return false;
    final isAtEdge = metrics.extentBefore <= 0 || metrics.extentAfter <= 0;
    var shouldHide = _isToggleButtonHidden;
    if (isAtEdge) {
      // 맨 아래는 메모 층이 버튼 높이만큼 비워 둬 가리지 않음
      shouldHide = false;
    } else if (notification is UserScrollNotification) {
      // reverse = 손가락을 올려 내용을 아래로 읽는 중
      if (notification.direction == ScrollDirection.reverse) shouldHide = true;
      if (notification.direction == ScrollDirection.forward) shouldHide = false;
    }
    if (shouldHide != _isToggleButtonHidden) {
      setState(() => _isToggleButtonHidden = shouldHide);
    }
    return false;
  }

  /// 켬·끔 전환 + 햅틱, 켤 때 스크린리더에 안내 문구
  void _toggleMemoMode(BuildContext context) {
    PassqlHaptics.playSelection();
    controller.toggleMemoMode();
    if (controller.isMemoMode) {
      SemanticsService.sendAnnouncement(
        View.of(context),
        PassqlMemoScope.memoModeHint,
        TextDirection.ltr,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // 하단 바 뒤로 본문이 이어지는 화면(extendBody)은 바 높이가 padding 에 들어 있음
    final bottomInset = MediaQuery.paddingOf(context).bottom;
    return _PassqlMemoInheritedController(
      notifier: controller,
      // 문항 영역이 받던 제약 그대로 (크기·배치 변화 없음)
      child: Stack(
        fit: StackFit.passthrough,
        children: [
          NotificationListener<ScrollNotification>(
            onNotification: _onScrollNotification,
            child: widget.child,
          ),
          Positioned.fill(
            child: ListenableBuilder(
              listenable: controller,
              builder: (context, _) =>
                  _buildFloatingControls(context, bottomInset),
            ),
          ),
        ],
      ),
    );
  }

  /// 켬: 위 안내(터치 없음) + 아래 도구 막대 / 끔: 오른쪽 아래 펜 버튼
  Widget _buildFloatingControls(BuildContext context, double bottomInset) {
    final isMemoMode = controller.isMemoMode;
    // 빈 곳은 터치를 받지 않음 (아래 문항으로 그대로)
    return Stack(
      children: [
        Positioned(
          left: PassqlSpacing.md,
          right: PassqlSpacing.md,
          bottom: bottomInset + PassqlSpacing.sm,
          // 켬 안내는 도구 막대 바로 위 (위쪽에 두면 문항 머리를 가림)
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (isMemoMode) ...[
                const IgnorePointer(child: Center(child: _PassqlMemoHint())),
                const SizedBox(height: PassqlSpacing.xs),
              ],
              PassqlFadeSwitcher(
                alignment: Alignment.bottomRight,
                child: isMemoMode
                    ? _PassqlMemoToolbar(
                        key: const ValueKey('memoToolbar'),
                        controller: controller,
                        activePageKey: widget.activePageKey,
                        onDone: () => _toggleMemoMode(context),
                      )
                    : Align(
                        key: const ValueKey('memoToggleButton'),
                        alignment: Alignment.bottomRight,
                        // 숨김: 아래로 밀려 사라짐 + 터치 없음 (스크린리더에서도 빠짐)
                        child: IgnorePointer(
                          ignoring: _isToggleButtonHidden,
                          child: ExcludeSemantics(
                            excluding: _isToggleButtonHidden,
                            child: AnimatedSlide(
                              offset: _isToggleButtonHidden
                                  ? _hiddenToggleButtonOffset
                                  : Offset.zero,
                              duration: PassqlMotion.durationOf(
                                context,
                                PassqlMotion.fast,
                              ),
                              curve: PassqlMotion.curve,
                              child: AnimatedOpacity(
                                opacity: _isToggleButtonHidden ? 0 : 1,
                                duration: PassqlMotion.durationOf(
                                  context,
                                  PassqlMotion.fast,
                                ),
                                child: _PassqlMemoToggleButton(
                                  hasMemo: controller.hasStrokesOn(
                                    widget.activePageKey,
                                  ),
                                  onTap: () => _toggleMemoMode(context),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _PassqlMemoInheritedController
    extends InheritedNotifier<PassqlMemoController> {
  const _PassqlMemoInheritedController({
    required super.notifier,
    required super.child,
  });
}

/// 켬 안내 한 줄: 토스트와 같은 반전 알약 (label 바탕 + background 글자)
class _PassqlMemoHint extends StatelessWidget {
  const _PassqlMemoHint();

  // 알약 바탕 불투명도 (뒤 내용이 살짝 비치게, 시안 0.82)
  static const double _backgroundOpacity = 0.82;

  @override
  Widget build(BuildContext context) {
    final colors = context.passqlColors;
    return ExcludeSemantics(
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: colors.label.withValues(alpha: _backgroundOpacity),
          borderRadius: BorderRadius.circular(PassqlRadius.capsule),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: PassqlSpacing.sm,
            vertical: PassqlSpacing.xs,
          ),
          child: Text(
            PassqlMemoScope.memoModeHint,
            textAlign: TextAlign.center,
            style: PassqlTypography.footnote.copyWith(color: colors.background),
          ),
        ),
      ),
    );
  }
}

/// 펜 버튼·도구 막대 공통 바탕: 떠 있는 카드색 + 헤어라인 + 옅은 그림자, 알약 모양
/// 반투명 유리는 그림자가 비쳐 아래쪽이 탁해져 불투명 cardElevated 를 씀
class _PassqlMemoFloatingSurface extends StatelessWidget {
  const _PassqlMemoFloatingSurface({required this.child});

  final Widget child;

  // 그림자 퍼짐·아래 이동·진하기 (떠 있는 크롬을 내용과 떼어 보이는 정도만)
  static const double _shadowBlurRadius = 12;
  static const Offset _shadowOffset = Offset(0, 2);
  static const double _shadowOpacityFactor = 0.5;

  @override
  Widget build(BuildContext context) {
    final colors = context.passqlColors;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: colors.cardElevated,
        borderRadius: BorderRadius.circular(PassqlRadius.capsule),
        border: Border.all(color: colors.separator, width: PassqlSize.hairline),
        boxShadow: [
          BoxShadow(
            color: colors.separator.withValues(
              alpha: colors.separator.a * _shadowOpacityFactor,
            ),
            blurRadius: _shadowBlurRadius,
            offset: _shadowOffset,
          ),
        ],
      ),
      child: child,
    );
  }
}

// 펜 버튼 지름 (시안 48: 최소 터치 44 보다 조금 크게)
const double _toggleButtonSize = 48;
// 숨긴 펜 버튼 위치: 자기 높이 1.5배 아래로 (아래 여백 밖으로 빠짐)
const Offset _hiddenToggleButtonOffset = Offset(0, 1.5);
