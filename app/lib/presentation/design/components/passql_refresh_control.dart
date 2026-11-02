import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';

import '../passql_haptics.dart';
import '../passql_theme.dart';
import '../tokens/passql_tokens.dart';
import 'passql_glow.dart';
import 'passql_loading_semantics.dart';

/// 당겨서 새로고침 (#772). iOS 기본 회색 스피너 대신 passQL 웨이브 점과 빛으로 보여 준다.
/// 당기는 중: 점 다섯 개가 당긴 만큼 왼쪽부터 켜지고, 다 켜지면(놓을 때 + 가벼운 진동) 차례로 솟았다 내려오는 물결 반복.
/// 손을 떼는 순간 가운데에서 보라 빛이 화면 전체로 번지고, 다시 불러오는 동안 번졌다 옅어지기를 반복
/// (개념 점수판 빛과 같은 [PassqlGlow], 앱 맨 위 층에 그려 누름은 막지 않음).
/// 동작 줄이기면 물결·빛 없이 켜진 점만. CustomScrollView 의 sliver 로 넣는다
class PassqlRefreshControl extends StatelessWidget {
  const PassqlRefreshControl({
    super.key,
    required this.onRefresh,
    this.indicatorOffset = 0,
  });

  final Future<void> Function() onRefresh;

  /// 점을 띠 아래로 더 내리는 거리. 큰 제목 화면은 새로고침 띠가 상단 바 위에 열려
  /// 그대로 두면 점이 큰 제목보다 한참 위에 뜨므로, 상단 바(상태 표시줄 + 바 높이)만큼 내려 제목 바로 위에 둔다
  final double indicatorOffset;

  @override
  Widget build(BuildContext context) {
    return CupertinoSliverRefreshControl(
      onRefresh: onRefresh,
      builder:
          (context, mode, pulledExtent, triggerDistance, indicatorExtent) =>
              _RefreshIndicator(
                indicatorOffset: indicatorOffset,
                mode: mode,
                pulledExtent: pulledExtent,
                triggerDistance: triggerDistance,
                indicatorExtent: indicatorExtent,
              ),
    );
  }
}

class _RefreshIndicator extends StatefulWidget {
  const _RefreshIndicator({
    required this.indicatorOffset,
    required this.mode,
    required this.pulledExtent,
    required this.triggerDistance,
    required this.indicatorExtent,
  });

  final double indicatorOffset;
  final RefreshIndicatorMode mode;
  final double pulledExtent;
  final double triggerDistance;
  final double indicatorExtent;

  @override
  State<_RefreshIndicator> createState() => _RefreshIndicatorState();
}

class _RefreshIndicatorState extends State<_RefreshIndicator>
    with SingleTickerProviderStateMixin {
  // 점 수·지름·간격, 물결 높이 (빛 출발 반지름은 점 묶음 반폭)
  static const int _dotCount = 5;
  static const double _dotSize = 8;
  static const double _dotGap = 6;
  static const double _waveHeight = 10;
  // 이만큼 당겨야 점이 다 보임 (그 전엔 서서히 나타남)
  static const double _appearExtent = 32;
  static const double _glowStartRadius =
      (_dotCount * _dotSize + (_dotCount - 1) * _dotGap) / 2;

  late final AnimationController _waveController = AnimationController(
    vsync: this,
    duration: PassqlMotion.refreshWaveLoop,
  );

  // 다시 불러오는 동안 한 주기마다 새 빛을 띄움
  Timer? _glowRepeat;
  // 이번 당김에서 빛을 퍼뜨렸는가 (손 뗌·새로고침 진입 중 먼저 온 쪽에서 한 번만 시작)
  bool _hasGlowed = false;
  // 놓을 지점까지 당긴 뒤 손을 뗐는가 (새로고침이 손 떼기 전에 끝나도 잡고 있는 동안은 물결 유지)
  bool _isReleased = false;
  // 빛은 띠 밖 화면 전체로 번져야 해서 앱 맨 위 층(오버레이)에 그린다. 출발점은 점의 화면 위치
  final GlobalKey _dotKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    // 손을 뗀 순간은 새로고침 상태로 바로 알 수 없음(띠가 제자리로 줄어든 뒤에야 바뀜) > 화면 전체 손 뗌을 직접 들음
    GestureBinding.instance.pointerRouter.addGlobalRoute(_onPointerEvent);
  }

  @override
  void didUpdateWidget(_RefreshIndicator oldWidget) {
    super.didUpdateWidget(oldWidget);
    // 놓으면 새로고침되는 지점에 처음 닿는 순간 가벼운 진동 (한 번)
    if (widget.mode == RefreshIndicatorMode.armed &&
        oldWidget.mode != RefreshIndicatorMode.armed) {
      PassqlHaptics.playSelection();
    }
    _syncGlow();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _syncGlow();
  }

  /// 물결이 도는 동안: 놓을 지점부터 손을 떼고 새로고침이 끝날 때까지.
  /// 새로고침이 손을 떼기 전에 끝나도(done) 잡고 있는 동안은 계속
  bool get _isWaving => switch (widget.mode) {
    RefreshIndicatorMode.armed || RefreshIndicatorMode.refresh => true,
    RefreshIndicatorMode.done => !_isReleased,
    _ => false,
  };

  /// 물결은 [_isWaving] 동안 반복. 빛은 손 뗌에서 시작([_startGlow])하고, 끝나면 새 빛만 멈춤(번지던 빛은 끝까지).
  /// 동작 줄이기면 물결·빛 없음
  void _syncGlow() {
    // 새로고침에 들어왔다면 이미 손을 뗀 것 (손 뗌을 놓쳤을 때 대비)
    if (widget.mode == RefreshIndicatorMode.refresh) _isReleased = true;
    if (PassqlMotion.isReduced(context)) return;
    if (_isWaving) {
      if (!_waveController.isAnimating) _waveController.repeat();
    } else {
      _waveController
        ..stop()
        ..value = 0;
    }
    switch (widget.mode) {
      case RefreshIndicatorMode.armed:
        break;
      case RefreshIndicatorMode.refresh:
        _startGlow();
      case RefreshIndicatorMode.done:
        _glowRepeat?.cancel();
      case RefreshIndicatorMode.inactive:
      case RefreshIndicatorMode.drag:
        // 다음 당김을 위해 처음 상태로
        _glowRepeat?.cancel();
        _hasGlowed = false;
        _isReleased = false;
    }
  }

  /// 놓을 지점까지 당긴 뒤 손을 떼는 순간 빛을 퍼뜨림 (새로고침이 손 떼기 전에 끝났어도 한 번은)
  void _onPointerEvent(PointerEvent event) {
    if (event is! PointerUpEvent && event is! PointerCancelEvent) return;
    final mode = widget.mode;
    if (mode == RefreshIndicatorMode.inactive ||
        mode == RefreshIndicatorMode.drag) {
      return;
    }
    setState(() => _isReleased = true);
    _startGlow();
    _syncGlow();
  }

  /// 빛 시작 (당김마다 한 번). 다시 불러오는 중이면 한 주기마다 반복, 이미 끝났으면 한 번만
  void _startGlow() {
    if (_hasGlowed || PassqlMotion.isReduced(context)) return;
    _hasGlowed = true;
    _spawnGlow();
    if (widget.mode != RefreshIndicatorMode.done) {
      _glowRepeat = Timer.periodic(
        PassqlMotion.refreshGlowLoop,
        (_) => _spawnGlow(),
      );
    }
  }

  /// 빛 한 번을 앱 맨 위 층에 띄움. 빛이 스스로 끝까지 퍼진 뒤 걷히므로
  /// 새로고침이 빨리 끝나 이 표시(띠)가 먼저 사라져도 화면 끝까지 감.
  /// 레이아웃 중에 불릴 수 있어 다음 프레임에 점 위치를 재고 넣는다
  void _spawnGlow() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final overlay = Overlay.of(context, rootOverlay: true);
      final layer = overlay.context.findRenderObject() as RenderBox?;
      final dot = _dotKey.currentContext?.findRenderObject() as RenderBox?;
      if (layer == null || dot == null || !dot.attached || !dot.hasSize) {
        return;
      }
      final center = dot.localToGlobal(
        dot.size.center(Offset.zero),
        ancestor: layer,
      );
      late final OverlayEntry entry;
      entry = OverlayEntry(
        builder: (_) => _GlowBurst(
          center: center,
          startRadius: _glowStartRadius,
          onDone: () => entry.remove(),
        ),
      );
      overlay.insert(entry);
    });
  }

  @override
  void dispose() {
    GestureBinding.instance.pointerRouter.removeGlobalRoute(_onPointerEvent);
    // 이미 띄운 빛은 스스로 끝까지 퍼진 뒤 걷힘 (여기서 지우면 중간에 끊김)
    _glowRepeat?.cancel();
    _waveController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.passqlColors;
    final pull = (widget.pulledExtent / widget.triggerDistance).clamp(0.0, 1.0);
    final isLoading = _isWaving;
    // 조금 당겼을 때부터 서서히 나타나고, 새로고침이 끝나 띠가 접히는 동안 함께 흐려짐
    // (점을 띠 밖으로 내려 그리므로 띠가 거의 닫혀도 점이 남지 않게)
    final opacity =
        (widget.pulledExtent /
                (widget.mode == RefreshIndicatorMode.done
                    ? widget.indicatorExtent
                    : _appearExtent))
            .clamp(0.0, 1.0);
    // 띠 밖(상단 바 자리)까지 내려 그릴 수 있게 자르지 않음. 펼친 큰 제목 바는 배경이 투명이라 점이 보임
    final indicator = Transform.translate(
      offset: Offset(0, widget.indicatorOffset),
      child: Opacity(
        opacity: opacity,
        // 띠 위쪽(화면에 고정된 쪽)부터 새로고침 띠 높이 칸을 잡고 그 아래쪽에 둠:
        // 아무리 당겨도 점이 내용을 따라 내려가지 않고 새로고침 중 자리에 고정
        child: OverflowBox(
          alignment: Alignment.topCenter,
          minHeight: widget.indicatorExtent,
          maxHeight: widget.indicatorExtent,
          child: Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: const EdgeInsets.only(bottom: PassqlSpacing.xl),
              child: AnimatedBuilder(
                animation: _waveController,
                builder: (context, _) => CustomPaint(
                  key: _dotKey,
                  size: const Size(
                    _dotCount * _dotSize + (_dotCount - 1) * _dotGap,
                    _dotSize + _waveHeight * 2,
                  ),
                  painter: _WaveDotsPainter(
                    lit: isLoading ? 1 : pull,
                    wavePhase: isLoading ? _waveController.value : null,
                    dotCount: _dotCount,
                    dotSize: _dotSize,
                    dotGap: _dotGap,
                    waveHeight: _waveHeight,
                    startColor: colors.accent,
                    midColor: colors.passGradientEnd,
                    offColor: colors.fill,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
    // 새로고침 중에는 스크린리더가 '불러오는 중'으로 읽음
    return isLoading ? PassqlLoadingSemantics(child: indicator) : indicator;
  }
}

/// 빛 한 번: 점 자리에서 화면 끝까지 퍼진 뒤 [onDone] 으로 스스로 층을 걷음
class _GlowBurst extends StatefulWidget {
  const _GlowBurst({
    required this.center,
    required this.startRadius,
    required this.onDone,
  });

  final Offset center;
  final double startRadius;
  final VoidCallback onDone;

  @override
  State<_GlowBurst> createState() => _GlowBurstState();
}

class _GlowBurstState extends State<_GlowBurst>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller =
      AnimationController(vsync: this, duration: PassqlMotion.refreshGlowLoop)
        ..addStatusListener((status) {
          if (status == AnimationStatus.completed) widget.onDone();
        })
        ..forward();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) => PassqlGlow(
        progress: _controller.value,
        startRadius: widget.startRadius,
        center: widget.center,
      ),
    );
  }
}

/// 웨이브 점: 당긴 만큼 왼쪽부터 켜지고, 새로고침 중엔 차례로 솟았다 내려오며 물결처럼 지나감
class _WaveDotsPainter extends CustomPainter {
  _WaveDotsPainter({
    required this.lit,
    required this.wavePhase,
    required this.dotCount,
    required this.dotSize,
    required this.dotGap,
    required this.waveHeight,
    required this.startColor,
    required this.midColor,
    required this.offColor,
  });

  /// 0~1: 켜진 정도 (1이면 다섯 개 모두)
  final double lit;

  /// 0~1 물결 진행 (null 이면 물결 없음)
  final double? wavePhase;
  final int dotCount;
  final double dotSize;
  final double dotGap;
  final double waveHeight;
  final Color startColor;
  final Color midColor;
  final Color offColor;

  // 점 사이 물결 지연(한 주기 대비), 한 점이 솟았다 내려오는 구간(한 주기 대비), 꼭대기에서 커지는 비율, 꺼진 점 크기
  static const double _waveStagger = 0.09;
  static const double _bumpSpan = 0.6;
  static const double _bumpScale = 0.15;
  static const double _offScale = 0.7;

  @override
  void paint(Canvas canvas, Size size) {
    final centerY = size.height / 2;
    for (var index = 0; index < dotCount; index++) {
      // 이 점이 켜진 정도: 당긴 비율을 점마다 한 칸씩 나눠 0~1
      final on = (lit * dotCount - index).clamp(0.0, 1.0);
      // 가운데 점일수록 탑승권 보라에 가깝게
      final centerness =
          1 - ((index - (dotCount - 1) / 2).abs() / ((dotCount - 1) / 2));
      final litColor = Color.lerp(startColor, midColor, centerness)!;
      var bump = 0.0;
      final phase = wavePhase;
      if (phase != null) {
        final local = (phase - index * _waveStagger) % 1;
        if (local < _bumpSpan) bump = math.sin(math.pi * local / _bumpSpan);
      }
      final radius =
          dotSize /
          2 *
          (_offScale + (1 - _offScale) * on) *
          (1 + _bumpScale * bump);
      final x = dotSize / 2 + index * (dotSize + dotGap);
      final y = centerY - waveHeight * bump;
      canvas.drawCircle(
        Offset(x, y),
        radius,
        Paint()..color = Color.lerp(offColor, litColor, on)!,
      );
    }
  }

  @override
  bool shouldRepaint(_WaveDotsPainter oldDelegate) =>
      oldDelegate.lit != lit ||
      oldDelegate.wavePhase != wavePhase ||
      oldDelegate.startColor != startColor ||
      oldDelegate.midColor != midColor ||
      oldDelegate.offColor != offColor;
}
