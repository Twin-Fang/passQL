import 'dart:math' as math;

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../pq_theme.dart';
import '../tokens/pq_metrics.dart';
import '../tokens/pq_type.dart';

/// 모달 시트 공통 모양: 손잡이 + 제목 + 닫기. 긴 본문 가독성을 위해 글래스 대신 불투명 배경을 쓴다.
Future<T?> showPqSheet<T>(
  BuildContext context, {
  required String title,
  required WidgetBuilder builder,
}) {
  final c = context.pq;
  return showModalBottomSheet<T>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    showDragHandle: true,
    backgroundColor: c.cardElevated,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(PqRadius.lg)),
    ),
    builder: (sheetContext) => Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(
            PqSpace.md,
            0,
            PqSpace.xs,
            PqSpace.xs,
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  title,
                  style: PqType.headline.copyWith(color: c.label),
                ),
              ),
              CupertinoButton(
                padding: const EdgeInsets.all(PqSpace.xs),
                onPressed: () => Navigator.of(sheetContext).pop(),
                child: Semantics(
                  label: '닫기',
                  child: Icon(
                    CupertinoIcons.xmark_circle_fill,
                    size: 28,
                    color: c.tertiaryLabel,
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
