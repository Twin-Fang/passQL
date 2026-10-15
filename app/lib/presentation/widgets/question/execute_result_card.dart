import 'package:flutter/material.dart';
import '../../../data/models/question/execute_result.dart';
import '../../design/design.dart';
import 'result_rows_table.dart';

/// SQL 실행 결과 카드. 성공이면 결과 테이블, 실패이면 에러 카드.
class ExecuteResultCard extends StatelessWidget {
  final ExecuteResult result;
  final VoidCallback? onAiExplainTap;

  /// 바깥 여백. 이미 좌우 inset 이 있는 목록 안에서는 가로를 0 으로 줄인다.
  final EdgeInsetsGeometry margin;

  const ExecuteResultCard({
    super.key,
    required this.result,
    this.onAiExplainTap,
    this.margin = const EdgeInsets.symmetric(
      horizontal: PassqlSpacing.md,
      vertical: PassqlSpacing.xxs,
    ),
  });

  bool get _isError => result.errorCode != null && result.errorCode!.isNotEmpty;

  @override
  Widget build(BuildContext context) {
    // 부모 Column 안에서 내용 폭으로 줄지 않게 선택지 카드와 같은 폭으로 편다(PassqlCard 가 width 를 채운다).
    return Padding(
      padding: margin,
      child: PassqlCard(
        child: _isError
            ? _ErrorContent(result: result, onAiTap: onAiExplainTap)
            : _SuccessContent(result: result),
      ),
    );
  }
}

/// 에러 결과: 에러 코드 + 메시지 + AI 해설 버튼.
class _ErrorContent extends StatelessWidget {
  final ExecuteResult result;
  final VoidCallback? onAiTap;

  const _ErrorContent({required this.result, this.onAiTap});

  @override
  Widget build(BuildContext context) {
    final colors = context.passqlColors;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const PassqlResultMark(correct: false, label: '실행 오류'),
        const SizedBox(height: PassqlSpacing.xs),
        Text(
          result.errorCode ?? 'ERROR',
          style: PassqlTypography.code.copyWith(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: colors.wrongText,
          ),
        ),
        const SizedBox(height: PassqlSpacing.xxs),
        Text(
          result.errorMessage ?? '알 수 없는 오류',
          style: PassqlTypography.footnote.copyWith(color: colors.wrongText),
        ),
        if (onAiTap != null) ...[
          const SizedBox(height: PassqlSpacing.xs),
          PassqlButton(
            label: 'AI에게 물어보기',
            onPressed: onAiTap,
            variant: PassqlButtonVariant.plain,
            size: PassqlButtonSize.small,
            expand: false,
          ),
        ],
      ],
    );
  }
}

/// 성공 결과: 행 수 요약 + 컬럼 헤더/데이터 행 표.
class _SuccessContent extends StatelessWidget {
  final ExecuteResult result;
  const _SuccessContent({required this.result});

  @override
  Widget build(BuildContext context) {
    final colors = context.passqlColors;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const PassqlResultMark(correct: true, label: '실행 성공'),
        const SizedBox(height: PassqlSpacing.xxs),
        Text(
          '${result.rowCount ?? result.rows.length}행 반환'
          '${result.elapsedMs != null ? ' · ${result.elapsedMs}ms' : ''}',
          style: PassqlTypography.caption.copyWith(color: colors.secondaryLabel),
        ),
        if (result.columns.isNotEmpty) ...[
          const SizedBox(height: PassqlSpacing.xs),
          // 행이 0개여도 열 이름 헤더는 보여 준다. 위치 기준이라 같은 이름의 열도 모두 나온다.
          ResultRowsTable.positional(
            columns: result.columns,
            rows: [
              for (final row in result.rows) [for (final cellValue in row) cellValue ?? 'NULL'],
            ],
          ),
        ],
      ],
    );
  }
}
