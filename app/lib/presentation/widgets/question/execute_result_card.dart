import 'package:flutter/material.dart';
import '../../../data/models/question/execute_result.dart';
import '../../design/design.dart';
import 'choice_card.dart';

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
      horizontal: PqSpace.md,
      vertical: PqSpace.xxs,
    ),
  });

  bool get _isError => result.errorCode != null && result.errorCode!.isNotEmpty;

  @override
  Widget build(BuildContext context) {
    // 부모 Column 안에서 내용 폭으로 줄지 않게 선택지 카드와 같은 폭으로 편다(PqCard 가 width 를 채운다).
    return Padding(
      padding: margin,
      child: PqCard(
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
    final c = context.pq;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const PqResultMark(correct: false, label: '실행 오류'),
        const SizedBox(height: PqSpace.xs),
        Text(
          result.errorCode ?? 'ERROR',
          style: PqType.code.copyWith(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: c.wrongText,
          ),
        ),
        const SizedBox(height: PqSpace.xxs),
        Text(
          result.errorMessage ?? '알 수 없는 오류',
          style: PqType.footnote.copyWith(color: c.wrongText),
        ),
        if (onAiTap != null) ...[
          const SizedBox(height: PqSpace.xs),
          PqButton(
            label: 'AI에게 물어보기',
            onPressed: onAiTap,
            variant: PqButtonVariant.plain,
            size: PqButtonSize.small,
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
    final c = context.pq;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const PqResultMark(correct: true, label: '실행 성공'),
        const SizedBox(height: PqSpace.xxs),
        Text(
          '${result.rowCount ?? result.rows.length}행 반환'
          '${result.elapsedMs != null ? ' · ${result.elapsedMs}ms' : ''}',
          style: PqType.caption.copyWith(color: c.secondaryLabel),
        ),
        if (result.columns.isNotEmpty) ...[
          const SizedBox(height: PqSpace.xs),
          // 행이 0개여도 열 이름 헤더는 보여 준다. 위치 기준이라 같은 이름의 열도 모두 나온다.
          ResultRowsTable.positional(
            columns: result.columns,
            rows: [
              for (final r in result.rows) [for (final v in r) v ?? 'NULL'],
            ],
          ),
        ],
      ],
    );
  }
}
