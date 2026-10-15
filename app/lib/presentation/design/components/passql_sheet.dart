import 'dart:math' as math;

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../passql_theme.dart';
import '../tokens/passql_tokens.dart';

/// 모달 시트 공통 모양: 손잡이 + 제목 + 닫기. 긴 본문 가독성을 위해 글래스 대신 불투명 배경을 쓴다.
Future<T?> showPassqlSheet<T>(
  BuildContext context, {
  required String title,
  required WidgetBuilder builder,
}) {
  final colors = context.passqlColors;
  return showModalBottomSheet<T>(
    context: context,
    // 탭 화면 안에서 열어도 하단 탭 바 위에 뜨도록 최상위 Navigator 에 띄운다.
    useRootNavigator: true,
    isScrollControlled: true,
    useSafeArea: true,
    showDragHandle: true,
    backgroundColor: colors.cardElevated,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(
        top: Radius.circular(PassqlRadius.lg),
      ),
    ),
    builder: (sheetContext) => Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(
            PassqlSpacing.md,
            0,
            PassqlSpacing.xs,
            PassqlSpacing.xs,
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  title,
                  style: PassqlTypography.headline.copyWith(
                    color: colors.label,
                  ),
                ),
              ),
              CupertinoButton(
                padding: const EdgeInsets.all(PassqlSpacing.xs),
                onPressed: () => Navigator.of(sheetContext).pop(),
                child: Semantics(
                  label: '닫기',
                  child: Icon(
                    CupertinoIcons.xmark_circle_fill,
                    size: PassqlIconSize.sheetClose,
                    color: colors.tertiaryLabel,
                  ),
                ),
              ),
            ],
          ),
        ),
        // 하단 여백은 여기서 한 번만: 키보드가 올라오면 키보드 높이, 아니면 홈 인디케이터 높이.
        Flexible(
          child: Padding(
            padding: EdgeInsets.only(
              bottom: math.max(
                MediaQuery.viewInsetsOf(sheetContext).bottom,
                MediaQuery.viewPaddingOf(sheetContext).bottom,
              ),
            ),
            child: builder(sheetContext),
          ),
        ),
      ],
    ),
  );
}
