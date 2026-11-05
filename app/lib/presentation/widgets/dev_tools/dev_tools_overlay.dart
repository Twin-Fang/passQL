import 'package:flutter/cupertino.dart';

import '../../../core/config/app_build_flavor.dart';
import '../../../router/app_router.dart';
import '../../design/design.dart';
import 'dev_tools_sheet.dart';

/// 개발자 도구 오버레이 (#809): 끌어서 옮기는 플로팅 버튼 > 도구 시트
/// MaterialApp.router builder 에서 한 번만 감쌈 (화면 코드 그대로), 운영 빌드는 감싸지 않음
class DevToolsOverlay extends StatefulWidget {
  const DevToolsOverlay({super.key, required this.child});

  final Widget child;

  /// builder 연결: 디버그·개발용 빌드 + .env APP_SHOW_DEV_TOOLS=true 일 때만 감쌈
  static Widget wrap(BuildContext context, Widget child) =>
      AppBuildFlavor.shouldShowDevTools ? DevToolsOverlay(child: child) : child;

  @override
  State<DevToolsOverlay> createState() => _DevToolsOverlayState();
}

class _DevToolsOverlayState extends State<DevToolsOverlay> {
  // 버튼 지름 (누르는 영역 최소 크기)
  static const double _buttonDiameter = PassqlSize.minTouchTarget;

  /// 버튼 위치 (처음 그릴 때 오른쪽 아래로 정함)
  Offset? _buttonOffset;

  // 시트가 열려 있는 동안 버튼 숨김 (시트 위 행을 가리지 않게, 중복 열기 방지)
  bool _isSheetOpen = false;

  /// 도구 시트 열기 (라우터보다 위라 최상위 Navigator 로 띄움) > 닫히면 버튼 다시 표시
  Future<void> _openSheet() async {
    final navigatorContext = AppRouter.rootNavigatorKey.currentContext;
    if (navigatorContext == null || _isSheetOpen) return;
    setState(() => _isSheetOpen = true);
    await showPassqlSheet<void>(
      navigatorContext,
      title: '개발자 도구',
      builder: (_) => const DevToolsSheet(),
    );
    if (mounted) setState(() => _isSheetOpen = false);
  }

  /// 끌기: 화면 안으로만 (안전 영역 안쪽)
  void _moveButton(Offset delta, Size screenSize, EdgeInsets safePadding) {
    final current = _buttonOffset ?? Offset.zero;
    setState(() {
      _buttonOffset = Offset(
        (current.dx + delta.dx).clamp(
          safePadding.left,
          screenSize.width - safePadding.right - _buttonDiameter,
        ),
        (current.dy + delta.dy).clamp(
          safePadding.top,
          screenSize.height - safePadding.bottom - _buttonDiameter,
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final screenSize = mediaQuery.size;
    final safePadding = mediaQuery.padding;
    final colors = context.passqlColors;
    final buttonOffset = _buttonOffset ??= Offset(
      screenSize.width - safePadding.right - _buttonDiameter - PassqlSpacing.md,
      screenSize.height * 0.6,
    );
    return Stack(
      children: [
        widget.child,
        if (!_isSheetOpen)
          Positioned(
            left: buttonOffset.dx,
            top: buttonOffset.dy,
            child: GestureDetector(
              onPanUpdate: (details) =>
                  _moveButton(details.delta, screenSize, safePadding),
              child: PassqlPressable(
                onTap: _openSheet,
                semanticLabel: '개발자 도구',
                child: Container(
                  width: _buttonDiameter,
                  height: _buttonDiameter,
                  decoration: BoxDecoration(
                    color: colors.accent,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    CupertinoIcons.hammer_fill,
                    size: PassqlIconSize.lg,
                    color: colors.onAccent,
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}
