import 'dart:math' as math;

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../passql_theme.dart';
import '../tokens/passql_tokens.dart';

/// 모달 시트 공통 모양: 손잡이 + 제목 + 닫기. 긴 본문 가독성을 위해 글래스 대신 불투명 배경을 쓴다.
/// [title] 없음 > 머리 줄 없이 본문만 (본문이 제목을 직접 그리는 안내 시트용)
/// [hasCloseButton] false > 닫기 X 없음 (손잡이 드래그·바깥 탭·본문 버튼으로 닫힘)
Future<T?> showPassqlSheet<T>(
  BuildContext context, {
  String? title,
  bool hasCloseButton = true,
  required WidgetBuilder builder,
}) {
  final hasHeader = title != null || hasCloseButton;
  return showModalBottomSheet<T>(
    context: context,
    // 탭 화면 안에서 열어도 하단 탭 바 위에 뜨도록 최상위 Navigator 에 띄운다.
    useRootNavigator: true,
    isScrollControlled: true,
    useSafeArea: true,
    showDragHandle: true,
    // 배경색은 bottomSheetTheme (passql_theme.dart), 여기서 고정하면 열 때 색에 묶임
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(
        top: Radius.circular(PassqlRadius.lg),
      ),
    ),
    builder: (sheetContext) {
      // 색은 시트 context 에서 읽음 (열어 둔 채 테마 전환 대응)
      final colors = sheetContext.passqlColors;
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (hasHeader)
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
                      title ?? '',
                      style: PassqlTypography.headline.copyWith(
                        color: colors.label,
                      ),
                    ),
                  ),
                  if (hasCloseButton)
                    CupertinoButton(
                      padding: const EdgeInsets.all(PassqlSpacing.xs),
                      onPressed: () => Navigator.of(sheetContext).pop(),
                      child: Semantics(
                        label: '닫기',
                        child: Icon(
                          CupertinoIcons.xmark_circle_fill,
                          size: PassqlIconSize.sheetClose,
                          color: colors.iconSecondary,
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
      );
    },
  );
}
