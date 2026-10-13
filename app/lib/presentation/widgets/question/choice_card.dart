import 'dart:convert';

import 'package:flutter/material.dart';
import '../../../data/models/question/choice_item.dart';
import '../../../data/models/question/submit_result.dart';
import '../../design/design.dart';
import 'stem_text.dart';

/// 개별 선택지 카드. kind="SQL"이면 코드 블록, kind="TEXT"이면 텍스트.
/// TEXT 이면서 본문이 결과 행 JSON 배열이면(실행 결과형, RESULT_MATCH) 작은 표로 보여 준다.
/// 선택·채점 상태의 모양은 [PqChoiceCard]가 정한다.
class ChoiceCard extends StatelessWidget {
  final ChoiceItem item;
  final PqChoiceState state;
  final VoidCallback onTap;

  const ChoiceCard({
    super.key,
    required this.item,
    required this.state,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final resultRows = item.kind == 'SQL' ? null : parseResultRows(item.body);
    final Widget body = item.kind == 'SQL'
        // 선택 가능한 코드면 카드 탭과 길게 누르기가 겹치므로 선택은 끈다.
        ? PqCodeBlock(code: item.body, selectable: false)
        : resultRows != null
        ? ResultRowsTable(rows: resultRows)
        : InlineCodeText(item.body);
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: PqSpace.md,
        vertical: PqSpace.xxs,
      ),
      child: PqChoiceCard(
        keyLabel: item.key,
        state: state,
        onTap: onTap,
        child: body,
      ),
    );
  }
}

/// 선택 키와 채점 결과로 선택지 상태를 정한다.
/// 채점 전: 고른 것만 selected. 채점 후: 정답 correct, 틀린 내 선택 wrong, 나머지 dimmed.
PqChoiceState choiceStateFor({
  required String key,
  String? selectedKey,
  SubmitResult? result,
}) {
  if (result == null) {
    return key == selectedKey ? PqChoiceState.selected : PqChoiceState.idle;
  }
  if (key == result.correctKey) return PqChoiceState.correct;
  if (key == selectedKey && !result.isCorrect) return PqChoiceState.wrong;
  return PqChoiceState.dimmed;
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
    final c = context.pq;
    if (rows.isEmpty) {
      return Text(
        '(결과 없음)',
        style: PqType.subheadline.copyWith(color: c.secondaryLabel),
      );
    }
    // 열 순서는 첫 행의 키 순서를 따른다(JSON 순서 유지).
    final columns = rows.first.keys.toList();
    final head = PqType.captionSemibold.copyWith(color: c.secondaryLabel);
    final cell = PqType.code.copyWith(fontSize: 12, color: c.label);

    Widget box(String text, TextStyle style) => Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: PqSpace.xs + 2,
        vertical: PqSpace.xxs + 2,
      ),
      child: Text(text, style: style),
    );

    return ClipRRect(
      borderRadius: const BorderRadius.all(Radius.circular(PqRadius.sm)),
      child: Container(
        decoration: BoxDecoration(
          color: c.card,
          border: Border.all(color: c.separator),
          borderRadius: const BorderRadius.all(Radius.circular(PqRadius.sm)),
        ),
        // 열이 적어 표가 카드보다 좁으면 오른쪽이 비어 보이므로, 최소 폭을 카드 폭에 맞춰 남는 폭을 열에 나눠 준다.
        child: LayoutBuilder(
          builder: (context, constraints) => SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: ConstrainedBox(
              constraints: BoxConstraints(minWidth: constraints.maxWidth),
              child: Table(
                defaultColumnWidth: const IntrinsicColumnWidth(),
                border: TableBorder(
                  horizontalInside: BorderSide(color: c.separator),
                ),
                children: [
                  TableRow(
                    decoration: BoxDecoration(color: c.fill),
                    children: [for (final col in columns) box(col, head)],
                  ),
                  for (final r in rows)
                    TableRow(
                      children: [
                        for (final col in columns) box('${r[col] ?? ''}', cell),
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
