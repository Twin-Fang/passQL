import 'stem_text.dart';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../core/app_colors.dart';
import '../../../core/text_styles.dart';
import '../../../data/models/question/choice_item.dart';

/// 개별 선택지 카드. kind="SQL"이면 코드 블록, kind="TEXT"이면 텍스트.
/// TEXT 이면서 본문이 결과 행 JSON 배열이면(실행 결과형, RESULT_MATCH) 작은 표로 보여 준다.
/// isSelected=true이면 인디고 테두리 강조.
class ChoiceCard extends StatelessWidget {
  final ChoiceItem item;
  final bool isSelected;
  final VoidCallback onTap;

  const ChoiceCard({
    super.key,
    required this.item,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final resultRows = item.kind == 'SQL' ? null : parseResultRows(item.body);
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 20.w, vertical: 4.h),
        padding: EdgeInsets.all(14.w),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.accentLight : AppColors.cardBg,
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(
            color: isSelected ? AppColors.brandIndigo : AppColors.borderDefault,
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 선택지 키 (A/B/C/D) - 라디오 스타일
            Container(
              width: 22.w,
              height: 22.w,
              margin: EdgeInsets.only(right: 10.w, top: 1.h),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isSelected ? AppColors.brandIndigo : AppColors.cardBg,
                border: Border.all(
                  color: isSelected
                      ? AppColors.brandIndigo
                      : AppColors.borderMuted,
                  width: 2,
                ),
              ),
              child: Center(
                child: Text(
                  item.key,
                  style: AppTextStyles.tag10Bold.copyWith(
                    color: isSelected
                        ? AppColors.cardBg
                        : AppColors.textSecondary,
                  ),
                ),
              ),
            ),

            // 선택지 내용
            Expanded(
              child: item.kind == 'SQL'
                  ? _SqlBody(sql: item.body, isSelected: isSelected)
                  : resultRows != null
                  ? ResultRowsTable(rows: resultRows)
                  : InlineCodeText(item.body),
            ),
          ],
        ),
      ),
    );
  }
}

class _SqlBody extends StatelessWidget {
  final String sql;
  final bool isSelected;

  const _SqlBody({required this.sql, required this.isSelected});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(10.w),
      decoration: BoxDecoration(
        color: AppColors.codeBg,
        borderRadius: BorderRadius.circular(8.r),
      ),
      child: Text(
        sql,
        style: TextStyle(
          fontFamily: 'JetBrainsMono',
          fontSize: 13.sp,
          color: AppColors.textPrimary,
          height: 1.5,
        ),
      ),
    );
  }
}

/// 선택지 본문이 결과 행 JSON 배열(`[{"COL": 값, ...}]`)이면 행 목록을, 아니면 null 을 돌려준다.
/// 웹(ResultMatchTable)과 같은 판별 기준을 쓴다.
List<Map<String, dynamic>>? parseResultRows(String body) {
  final text = body.trim();
  if (!text.startsWith('[')) return null;
  try {
    final decoded = jsonDecode(text);
    if (decoded is! List) return null;
    if (decoded.any((e) => e is! Map)) return null;
    return [for (final e in decoded) Map<String, dynamic>.from(e as Map)];
  } catch (_) {
    return null;
  }
}

/// 실행 결과형 선택지 표. 열이 많아도 잘리지 않게 가로로 스크롤한다.
class ResultRowsTable extends StatelessWidget {
  const ResultRowsTable({super.key, required this.rows});

  final List<Map<String, dynamic>> rows;

  @override
  Widget build(BuildContext context) {
    if (rows.isEmpty) {
      return Text(
        '(결과 없음)',
        style: AppTextStyles.paragraph_14.copyWith(
          color: AppColors.textSecondary,
        ),
      );
    }
    // 열 순서는 첫 행의 키 순서를 따른다(JSON 순서 유지).
    final columns = rows.first.keys.toList();
    final head = AppTextStyles.tag12Semibold.copyWith(
      color: AppColors.textSecondary,
    );
    final cell = TextStyle(
      fontFamily: 'JetBrainsMono',
      fontSize: 12.sp,
      color: AppColors.textPrimary,
    );

    Widget box(String text, TextStyle style) => Padding(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
      child: Text(text, style: style),
    );

    return ClipRRect(
      borderRadius: BorderRadius.circular(8.r),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.cardBg,
          border: Border.all(color: AppColors.borderDefault),
          borderRadius: BorderRadius.circular(8.r),
        ),
        // 열이 적어 표가 카드보다 좁으면 오른쪽이 비어 보이므로, 최소 폭을 카드 폭에 맞춰 남는 폭을 열에 나눠 준다.
        child: LayoutBuilder(
          builder: (context, constraints) => SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: ConstrainedBox(
              constraints: BoxConstraints(minWidth: constraints.maxWidth),
              child: Table(
                defaultColumnWidth: const IntrinsicColumnWidth(),
                border: const TableBorder(
                  horizontalInside: BorderSide(color: AppColors.borderDefault),
                ),
                children: [
                  TableRow(
                    decoration: const BoxDecoration(color: AppColors.codeBg),
                    children: [for (final c in columns) box(c, head)],
                  ),
                  for (final r in rows)
                    TableRow(
                      children: [
                        for (final c in columns) box('${r[c] ?? ''}', cell),
                      ],
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
