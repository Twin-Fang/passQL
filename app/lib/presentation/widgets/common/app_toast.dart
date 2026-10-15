import 'package:flutter/material.dart';

import '../../design/design.dart';

/// 앱 공통 토스트. 하단에 떠 있는 캡슐 하나로 통일한다(화면마다 SnackBar 를 꾸미지 않는다).
/// [actionLabel]·[onAction]: 둘 다 있으면 오른쪽 버튼 + 표시 시간 연장 (예: 푸시 알림 '보기')
void showAppToast(
  BuildContext context,
  String message, {
  String? actionLabel,
  VoidCallback? onAction,
}) {
  final hasAction = actionLabel != null && onAction != null;
  final colors = context.passqlColors;
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(
      SnackBar(
        content: Text(message,
            textAlign: TextAlign.center,
            style: PassqlTypography.subheadlineSemibold.copyWith(color: colors.background)),
        // 배경과 반대 밝기의 캡슐이라 라이트/다크 어디서나 눈에 띈다.
        backgroundColor: colors.label.withValues(alpha: 0.88),
        behavior: SnackBarBehavior.floating,
        elevation: 0,
        shape: const StadiumBorder(),
        margin: const EdgeInsets.fromLTRB(PassqlSpacing.xxl, 0, PassqlSpacing.xxl, PassqlSpacing.md),
        duration: Duration(seconds: hasAction ? _actionToastSeconds : _toastSeconds),
        action: hasAction
            ? SnackBarAction(label: actionLabel, textColor: colors.background, onPressed: onAction)
            : null,
        // 버튼이 있어도 시간이 지나면 닫음 (기본값은 버튼 있으면 계속 표시)
        persist: false,
      ),
    );
}

// 토스트 표시 시간 (초): 기본, 버튼 있을 때
const int _toastSeconds = 2;
const int _actionToastSeconds = 4;
