import 'package:flutter/material.dart';

import '../../design/design.dart';

/// 공지 본문 시트 (홈 배너·알림함 공지 탭 공통)
Future<void> showNoticeBodySheet(
  BuildContext context, {
  required String title,
  required String body,
}) => showPassqlSheet<void>(
  context,
  title: title,
  builder: (sheetContext) => SingleChildScrollView(
    padding: const EdgeInsets.fromLTRB(
      PassqlSpacing.md,
      0,
      PassqlSpacing.md,
      PassqlSpacing.lg,
    ),
    child: Text(
      body,
      style: PassqlTypography.legalBody.copyWith(
        color: sheetContext.passqlColors.label,
      ),
    ),
  ),
);
