import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../passql_theme.dart';
import '../tokens/passql_tokens.dart';

/// 모달 시트 공통 모양: 손잡이 + 가운데 제목. 긴 본문 가독성을 위해 글래스 대신 불투명 배경을 쓴다.
/// 닫기 X 는 두지 않음 (손잡이 드래그·바깥 탭·뒤로가기·본문 버튼으로 닫힘)
/// [title] 없음 > 머리 줄 없이 본문만 (본문이 제목을 직접 그리는 안내 시트용)
Future<T?> showPassqlSheet<T>(
  BuildContext context, {
  String? title,
  required WidgetBuilder builder,
}) {
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
          if (title != null)
            Padding(
              padding: const EdgeInsets.fromLTRB(
                PassqlSpacing.md,
                0,
                PassqlSpacing.md,
                PassqlSpacing.sm,
              ),
              child: Semantics(
                header: true,
                child: Text(
                  title,
                  textAlign: TextAlign.center,
                  style: PassqlTypography.headline.copyWith(
                    color: colors.label,
                  ),
                ),
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
