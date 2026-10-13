import 'package:flutter/material.dart';

import '../../design/design.dart';

/// 앱 공통 토스트. 하단에 떠 있는 캡슐 하나로 통일한다(화면마다 SnackBar 를 꾸미지 않는다).
void showAppToast(BuildContext context, String message) {
  final c = context.pq;
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(
      SnackBar(
        content: Text(message,
            textAlign: TextAlign.center,
            style: PqType.subheadlineSemibold.copyWith(color: c.background)),
        // 배경과 반대 밝기의 캡슐이라 라이트/다크 어디서나 눈에 띈다.
        backgroundColor: c.label.withValues(alpha: 0.88),
        behavior: SnackBarBehavior.floating,
        elevation: 0,
        shape: const StadiumBorder(),
        margin: const EdgeInsets.fromLTRB(PqSpace.xxl, 0, PqSpace.xxl, PqSpace.md),
        duration: const Duration(seconds: 2),
      ),
    );
}
