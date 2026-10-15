import 'package:flutter/material.dart';

import '../pq_theme.dart';

/// passQL 워드마크. 라이트/다크에 맞는 투명 배경 에셋을 고른다.
///
/// 다크 에셋은 원본 로고에서 'pass' 글자만 흰색으로 바꾼 것이다(QL 그라데이션은 그대로).
/// 배경이 투명하므로 블렌드·색 필터 없이 어느 배경 위에도 그대로 올린다.
class PqLogo extends StatelessWidget {
  const PqLogo({super.key, required this.height});

  final double height;

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      context.isDark ? 'assets/logo_dark.png' : 'assets/logo.png',
      height: height,
      semanticLabel: 'passQL',
    );
  }
}
