import 'dart:ui' show ImageFilter;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../passql_theme.dart';
import '../tokens/passql_tokens.dart';

/// 뒤 콘텐츠를 흐리는 반투명 바탕. 고정 크롬(탭 바·상단 바·하단 액션 바)에만 쓴다 — 스크롤 목록 안에 넣으면 프레임이 떨어진다.
class PassqlGlass extends StatelessWidget {
  const PassqlGlass({
    super.key,
    required this.child,
    this.topHairline = false,
    this.bottomHairline = false,
  });
  final Widget child;
  final bool topHairline;
  final bool bottomHairline;

  @override
  Widget build(BuildContext context) {
    final colors = context.passqlColors;
    final side = BorderSide(color: colors.separator, width: PassqlSize.hairline);
    return ClipRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(
          sigmaX: PassqlSize.blurSigma,
          sigmaY: PassqlSize.blurSigma,
        ),
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: colors.glass,
            border: Border(
              top: topHairline ? side : BorderSide.none,
              bottom: bottomHairline ? side : BorderSide.none,
            ),
          ),
          child: child,
        ),
      ),
    );
  }
}
