import 'result_rows_table.dart';

/// 지문 속 마크다운 표 1개: 머리 열 이름, 본문 행(NULL 문구는 null)
class StemMarkdownTable {
  const StemMarkdownTable({required this.columns, required this.rows});

  final List<String> columns;
  final List<List<Object?>> rows;
}

/// 표 구분 줄 (| --- | :---: |)
final RegExp _separatorRowRe = RegExp(r'^\|?\s*:?-{3,}:?\s*(\|\s*:?-{3,}:?\s*)*\|?$');

bool _isTableRowLine(String line) => line.trim().startsWith('|');

bool _isSeparatorLine(String line) => _separatorRowRe.hasMatch(line.trim());

/// 표 한 줄 > 칸 목록 (앞뒤 | 제거, 칸 앞뒤 공백 제거)
List<String> _toCells(String line) {
  var trimmed = line.trim();
  if (trimmed.startsWith('|')) trimmed = trimmed.substring(1);
  if (trimmed.endsWith('|')) trimmed = trimmed.substring(0, trimmed.length - 1);
  return [for (final cell in trimmed.split('|')) cell.trim()];
}

/// 칸 글자 > 표 값 (NULL 문구 > null, 모자란 칸 > 빈칸)
Object? _toCellValue(List<String> cells, int column) {
  if (column >= cells.length) return '';
  final cell = cells[column];
  return cell == sqlNullCellLabel ? null : cell;
}

/// 지문 글 > 글 조각(String)과 표(StemMarkdownTable) 순서 목록
/// 표 조건: | 로 시작하는 머리 줄 + 구분 줄(| --- |) + 본문 줄 0개 이상
List<Object> splitStemMarkdownTables(String text) {
  final lines = text.split('\n');
  final segments = <Object>[];
  final pendingTextLines = <String>[];

  void flushText() {
    if (pendingTextLines.isEmpty) return;
    segments.add(pendingTextLines.join('\n'));
    pendingTextLines.clear();
  }

  var index = 0;
  while (index < lines.length) {
    final hasTableStart =
        index + 1 < lines.length &&
        _isTableRowLine(lines[index]) &&
        _isSeparatorLine(lines[index + 1]);
    if (!hasTableStart) {
      pendingTextLines.add(lines[index]);
      index++;
      continue;
    }

    // 머리 > 구분 줄 건너뜀 > 본문 줄 (열 수에 맞춰 자르거나 빈칸 채움)
    final columns = _toCells(lines[index]);
    index += 2;
    final rows = <List<Object?>>[];
    while (index < lines.length && _isTableRowLine(lines[index])) {
      final cells = _toCells(lines[index]);
      rows.add([
        for (var column = 0; column < columns.length; column++)
          _toCellValue(cells, column),
      ]);
      index++;
    }
    flushText();
    segments.add(StemMarkdownTable(columns: columns, rows: rows));
  }
  flushText();
  return segments;
}
