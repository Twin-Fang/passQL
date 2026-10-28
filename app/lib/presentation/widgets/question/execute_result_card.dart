import 'package:flutter/material.dart';
import '../../../data/models/question/execute_result.dart';
import '../../design/design.dart';
import 'result_rows_table.dart';

/// SQL 실행 결과 카드. 성공이면 결과 테이블, 실패이면 에러 카드.
class ExecuteResultCard extends StatelessWidget {
  final ExecuteResult result;
  final VoidCallback? onAiExplainTap;

  /// 실행한 보기 표시 라벨(A~D). 있으면 머리에 "보기 B 실행 결과" 처럼 표시 (#554)
  final String? executedChoiceLabel;

  /// 머리 앞 주어 직접 지정 ("내 SQL"). 있으면 [executedChoiceLabel] 대신 씀 (#727)
  final String? subjectLabel;

  /// 바깥 여백. 이미 좌우 inset 이 있는 목록 안에서는 가로를 0 으로 줄인다.
  final EdgeInsetsGeometry margin;

  /// false: 카드 틀 없이 내용만 (다른 카드 안에 넣을 때 이중 여백 방지, #727)
  final bool shouldWrapInCard;

  const ExecuteResultCard({
    super.key,
    required this.result,
    this.onAiExplainTap,
    this.executedChoiceLabel,
    this.subjectLabel,
    this.shouldWrapInCard = true,
    this.margin = const EdgeInsets.symmetric(
      horizontal: PassqlSpacing.md,
      vertical: PassqlSpacing.xxs,
    ),
  });

  bool get _isError => result.errorCode != null && result.errorCode!.isNotEmpty;

  /// 결과 표시 문구: 주어가 있으면 앞에 붙임 ("보기 B · 실행 성공", "내 SQL · 실행 성공")
  String _markLabelOf(String outcomeLabel) {
    final subject =
        subjectLabel ??
        (executedChoiceLabel == null ? null : '보기 $executedChoiceLabel');
    return subject == null ? outcomeLabel : '$subject · $outcomeLabel';
  }

  @override
  Widget build(BuildContext context) {
    // 부모 Column 안에서 내용 폭으로 줄지 않게 선택지 카드와 같은 폭으로 편다(PassqlCard 가 width 를 채운다).
    final content = _isError
        ? _ErrorContent(
            result: result,
            onAiTap: onAiExplainTap,
            markLabel: _markLabelOf('실행 오류'),
          )
        : _SuccessContent(result: result, markLabel: _markLabelOf('실행 성공'));
    return Padding(
      padding: margin,
      child: shouldWrapInCard ? PassqlCard(child: content) : content,
    );
  }
}

/// 에러 결과: 에러 코드 + 메시지 + AI 해설 버튼.
class _ErrorContent extends StatelessWidget {
  final ExecuteResult result;
  final VoidCallback? onAiTap;
  final String markLabel;

  const _ErrorContent({
    required this.result,
    this.onAiTap,
    required this.markLabel,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.passqlColors;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        PassqlResultMark(isCorrect: false, label: markLabel),
        const SizedBox(height: PassqlSpacing.xs),
        Text(
          result.errorCode ?? 'ERROR',
          style: PassqlTypography.codeEmphasis.copyWith(
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
            isFullWidth: false,
          ),
        ],
      ],
    );
  }
}

/// 성공 결과: 행 수 요약 + 컬럼 헤더/데이터 행 표.
class _SuccessContent extends StatelessWidget {
  final ExecuteResult result;
  final String markLabel;
  const _SuccessContent({required this.result, required this.markLabel});

  @override
  Widget build(BuildContext context) {
    final colors = context.passqlColors;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        PassqlResultMark(isCorrect: true, label: markLabel),
        const SizedBox(height: PassqlSpacing.xxs),
        Text(
          // 실제 DB 에서 돌린 결과임을 드러냄 (#727)
          '실제 DB 실행 · ${result.rowCount ?? result.rows.length}행 반환'
          '${result.elapsedMs != null ? ' · ${result.elapsedMs}ms' : ''}',
          style: PassqlTypography.caption.copyWith(
            color: colors.secondaryLabel,
          ),
        ),
        if (result.columns.isNotEmpty) ...[
          const SizedBox(height: PassqlSpacing.xs),
          // 행이 0개여도 열 이름 헤더는 보여 준다. 위치 기준이라 같은 이름의 열도 모두 나온다.
          ResultRowsTable.positional(
            columns: result.columns,
            rows: [
              for (final row in result.rows)
                [for (final cellValue in row) cellValue],
            ],
          ),
        ],
      ],
    );
  }
}
