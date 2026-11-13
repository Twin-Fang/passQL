import 'dart:math' as math;
import 'dart:ui' show lerpDouble;

import 'package:flutter/widgets.dart';

import '../passql_theme.dart';
import '../tokens/passql_motion.dart';

/// 젬 3D 연출 (#1014): 평면 이미지를 원근 회전으로 입체처럼. 크레딧·PRO 젬 공통
/// 연출 3개(조합 가능): 등장 스핀 + 빛 쓸기([isSpinningIn]·[spinInProgress]), 값 바뀔 때 작은 뒤집기([flipTrigger]), 손가락 드래그 기울기([canDragTilt])
/// 동작 줄이기면 모두 정지 (자식만 그대로)
class Passql3dTilt extends StatefulWidget {
  const Passql3dTilt({
    super.key,
    required this.child,
    this.isSpinningIn = false,
    this.spinInProgress,
    this.flipTrigger,
    this.canDragTilt = false,
  });

  final Widget child;

  /// 처음 그려질 때 자체 시간(PassqlMotion.gemSpinIn)으로 한 바퀴 스핀 + 빛 쓸기
  final bool isSpinningIn;

  /// 바깥 연출(보상 창 등)이 스핀 진행(0..1)을 정할 때. 주면 [isSpinningIn] 자체 시간은 쓰지 않음
  final Animation<double>? spinInProgress;

  /// 이 값이 바뀌면 한 번 살짝 뒤집힘 (예: 남은 크레딧 수)
  final Object? flipTrigger;

  /// 손가락으로 끌면 살짝 기울고, 떼면 제자리 (기기 기울기 센서 대신)
  final bool canDragTilt;

  @override
  State<Passql3dTilt> createState() => _Passql3dTiltState();
}

class _Passql3dTiltState extends State<Passql3dTilt>
    with TickerProviderStateMixin {
  // 원근 세기 (값이 클수록 가까이서 보는 것처럼 많이 휨)
  static const double _perspective = 0.0015;
  // 스핀 진행 구간 (0..1 기준): 처음 15% 나타남, 60%까지 0.3 > 1배 튀며 커짐, 75%까지 한 바퀴, 55% 이후 빛 쓸기
  static const double _fadeInEnd = 0.15;
  static const double _scaleEnd = 0.6;
  static const double _startScale = 0.3;
  static const double _turnEnd = 0.75;
  static const double _shineStart = 0.55;
  // 빛 띠 반폭(대각선 길이 비율)·밝기
  static const double _shineHalfWidth = 0.18;
  static const double _shineAlpha = 0.7;
  // 값 바뀔 때 뒤집기 최대 각도 (40°)
  static const double _flipMaxRadians = 40 * math.pi / 180;
  // 드래그: 1px 당 기울기, 최대 12°
  static const double _dragRadiansPerPixel = 0.01;
  static const double _maxDragTiltRadians = 12 * math.pi / 180;

  late final AnimationController _spinController = AnimationController(
    vsync: this,
    duration: PassqlMotion.gemSpinIn,
    value: widget.isSpinningIn ? 0 : 1,
  );
  late final AnimationController _flipController = AnimationController(
    vsync: this,
    duration: PassqlMotion.gemFlip,
  );
  late final AnimationController _releaseController = AnimationController(
    vsync: this,
    duration: PassqlMotion.gemTiltRelease,
    value: 1,
  );

  bool _hasStartedSpin = false;
  bool _isDragging = false;
  // 기울기 (dx: 세로축 회전, dy: 가로축 회전, 라디안)
  Offset _dragTilt = Offset.zero;
  Offset _releaseStartTilt = Offset.zero;

  bool get _hasSpinIn => widget.isSpinningIn || widget.spinInProgress != null;

  Animation<double> get _spinSource => widget.spinInProgress ?? _spinController;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_hasStartedSpin || !widget.isSpinningIn) return;
    _hasStartedSpin = true;
    if (PassqlMotion.isReduced(context)) {
      _spinController.value = 1;
    } else {
      _spinController.forward();
    }
  }

  @override
  void didUpdateWidget(covariant Passql3dTilt oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.flipTrigger != oldWidget.flipTrigger &&
        !PassqlMotion.isReduced(context)) {
      _flipController.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _spinController.dispose();
    _flipController.dispose();
    _releaseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (PassqlMotion.isReduced(context)) return widget.child;
    final shineColor = context.passqlColors.onAccent;
    Widget result = AnimatedBuilder(
      animation: Listenable.merge([
        _spinSource,
        _flipController,
        _releaseController,
      ]),
      child: widget.child,
      builder: (_, child) => _buildTransformed(child!, shineColor),
    );
    if (widget.canDragTilt) {
      result = GestureDetector(
        onPanStart: (_) => _startDrag(),
        onPanUpdate: (details) => _updateDrag(details.delta),
        onPanEnd: (_) => _releaseDrag(),
        onPanCancel: _releaseDrag,
        child: result,
      );
    }
    return result;
  }

  /// 진행값 > 원근 회전(스핀 + 뒤집기 + 기울기)·크기·투명도·빛 (트리 모양은 설정마다 고정, 이미지 다시 읽지 않게)
  Widget _buildTransformed(Widget child, Color shineColor) {
    final spinProgress = _hasSpinIn ? _spinSource.value : 1.0;
    final tilt = _currentTilt();
    final angleY =
        _spinAngleOf(spinProgress) +
        _flipMaxRadians * math.sin(math.pi * _flipController.value) +
        tilt.dx;
    final transform = Matrix4.identity()
      ..setEntry(3, 2, _perspective)
      ..rotateX(-tilt.dy)
      ..rotateY(angleY);
    // 뒷면이 보이는 동안 좌우 뒤집어 앞면 그림 유지 (번개·무한대가 거울상으로 보이지 않게)
    if (math.cos(angleY) < 0) {
      transform.multiply(Matrix4.diagonal3Values(-1, 1, 1));
    }
    Widget transformed = Transform(
      alignment: Alignment.center,
      transform: transform,
      child: _hasSpinIn ? _buildShine(child, spinProgress, shineColor) : child,
    );
    if (!_hasSpinIn) return transformed;
    return Opacity(
      opacity: (spinProgress / _fadeInEnd).clamp(0.0, 1.0),
      child: Transform.scale(
        scale: _spinScaleOf(spinProgress),
        child: transformed,
      ),
    );
  }

  /// 한 바퀴 (2π > 0, 끝에서 느려짐)
  double _spinAngleOf(double progress) {
    final turnProgress = (progress / _turnEnd).clamp(0.0, 1.0);
    return 2 * math.pi * (1 - PassqlMotion.curve.transform(turnProgress));
  }

  /// 0.3 > 1배 (살짝 넘쳤다 돌아옴)
  double _spinScaleOf(double progress) {
    final scaleProgress = (progress / _scaleEnd).clamp(0.0, 1.0);
    return lerpDouble(
      _startScale,
      1,
      PassqlMotion.springCurve.transform(scaleProgress),
    )!;
  }

  /// 빛 쓸기: 왼쪽 위 > 오른쪽 아래로 흰 띠 한 번, 젬 불투명 부분에만 (srcATop)
  Widget _buildShine(Widget child, double spinProgress, Color shineColor) {
    final shineProgress = ((spinProgress - _shineStart) / (1 - _shineStart))
        .clamp(0.0, 1.0);
    // 띠 중심: 화면 밖(-반폭) > 반대편 밖(1+반폭), 끝나면 완전히 빠짐
    final center = -_shineHalfWidth + (1 + 2 * _shineHalfWidth) * shineProgress;
    final transparent = shineColor.withValues(alpha: 0);
    return ShaderMask(
      blendMode: BlendMode.srcATop,
      shaderCallback: (bounds) => LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          transparent,
          shineColor.withValues(alpha: _shineAlpha),
          transparent,
        ],
        stops: [
          (center - _shineHalfWidth).clamp(0.0, 1.0),
          center.clamp(0.0, 1.0),
          (center + _shineHalfWidth).clamp(0.0, 1.0),
        ],
      ).createShader(bounds),
      child: child,
    );
  }

  /// 끄는 중이면 손가락 기울기, 뗀 뒤면 제자리로 돌아가는 중간값
  Offset _currentTilt() {
    if (_isDragging) return _dragTilt;
    return Offset.lerp(
      _releaseStartTilt,
      Offset.zero,
      PassqlMotion.curve.transform(_releaseController.value),
    )!;
  }

  void _startDrag() {
    final startTilt = _currentTilt();
    _releaseController.stop();
    setState(() {
      _isDragging = true;
      _dragTilt = startTilt;
    });
  }

  void _updateDrag(Offset delta) {
    final next = _dragTilt + delta * _dragRadiansPerPixel;
    setState(() {
      _dragTilt = Offset(
        next.dx.clamp(-_maxDragTiltRadians, _maxDragTiltRadians),
        next.dy.clamp(-_maxDragTiltRadians, _maxDragTiltRadians),
      );
    });
  }

  void _releaseDrag() {
    if (!_isDragging) return;
    setState(() {
      _isDragging = false;
      _releaseStartTilt = _dragTilt;
      _dragTilt = Offset.zero;
    });
    _releaseController.forward(from: 0);
  }
}
