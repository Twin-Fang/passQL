import '../../../data/models/question/question_schema_column.dart';
import '../../../data/models/question/question_schema_table.dart';
import 'stem_markdown_table.dart';

/// 지문 블록 6종: 단락, 보조 설명, 질문, 목록, 표, 코드 (#903, 웹 stemBlocks.ts 와 같은 규칙)
sealed class StemBlock {
  const StemBlock();
}

/// 단락 (원문 줄바꿈 유지)
class StemParagraph extends StemBlock {
  const StemParagraph(this.text);
  final String text;
}

/// 줄 전체가 괄호로 싸인 보조 설명
class StemNote extends StemBlock {
  const StemNote(this.text);
  final String text;
}

/// `?` 로 끝나는 질문 문장
class StemQuestion extends StemBlock {
  const StemQuestion(this.text);
  final String text;
}

/// 목록 항목: `용어: 설명` 이면 term 있음, 아니면 text 만
class StemListItem {
  const StemListItem({this.term, required this.text});
  final String? term;
  final String text;
}

class StemList extends StemBlock {
  const StemList(this.items);
  final List<StemListItem> items;
}

/// 표: 지문 마크다운 표 또는 스키마 표 (그리는 모양은 하나)
class StemTable extends StemBlock {
  const StemTable({this.name, required this.columns, required this.rows});
  final String? name;
  final List<QuestionSchemaColumn> columns;
  final List<List<Object?>> rows;

  /// 컬럼 이름 목록 비교용 키 (대소문자 무시, 순서 유지)
  String get columnSignature =>
      columns.map((column) => column.name.trim().toUpperCase()).join('|');
}

/// 코드: caption 은 `-- 라벨` 주석에서 뗀 글 (없으면 null)
class StemCode extends StemBlock {
  const StemCode({this.caption, required this.code});
  final String? caption;
  final String code;
}

/// 지문 안 ```lang ... ``` 블록
final RegExp _fenceRe = RegExp(r'```[A-Za-z]*\r?\n?([\s\S]*?)```');

/// 표 이름 줄: `[EMP]`
final RegExp _tableNameLineRe = RegExp(r'^\[([A-Za-z0-9_]+)\]$');

/// 목록 줄: `- `, `• `, `* `, `1. `
final RegExp _listLineRe = RegExp(r'^(?:[-•*]|\d+\.)\s+(.*)$');

/// 목록 용어: 콜론 앞 1~20자 + 콜론 + 공백
final RegExp _listTermRe = RegExp(r'^([^:：]{1,20})[:：]\s+(.+)$');

/// 보조 설명 줄: 줄 전체가 괄호
final RegExp _noteLineRe = RegExp(r'^\((.+)\)$');

/// 문장 끝: . ? ! 뒤 공백
final RegExp _sentenceEndRe = RegExp(r'(?<=[.?!])\s+');

final RegExp _hangulRe = RegExp(r'[가-힣]');

/// 코드 라벨 주석 줄: `-- SQL 1`
final RegExp _codeLabelLineRe = RegExp(r'^--\s*(.+)$');

/// 지문 + 스키마 표 > 블록 목록: 코드 펜스 분리 > 글 블록 나누기 > 스키마 표 배치
List<StemBlock> parseStemBlocks(
  String stem, {
  List<QuestionSchemaTable> schemaTables = const [],
}) {
  final blocks = <StemBlock>[];
  var cursor = 0;
  for (final match in _fenceRe.allMatches(stem)) {
    blocks.addAll(_parseTextBlocks(stem.substring(cursor, match.start)));
    blocks.addAll(_parseCodeBlocks(match.group(1) ?? ''));
    cursor = match.end;
  }
  blocks.addAll(_parseTextBlocks(stem.substring(cursor)));
  return _placeSchemaTables(blocks, schemaTables);
}

/// 펜스 밖 글 > 표·목록·보조 설명·단락(질문 떼기) 블록
List<StemBlock> _parseTextBlocks(String text) {
  final blocks = <StemBlock>[];
  String? pendingTableName;
  for (final segment in splitStemMarkdownTables(text)) {
    if (segment is StemMarkdownTable) {
      blocks.add(
        StemTable(
          name: pendingTableName,
          columns: [
            for (final name in segment.columns) QuestionSchemaColumn(name: name),
          ],
          rows: segment.rows,
        ),
      );
      pendingTableName = null;
      continue;
    }
    final lines = (segment as String).split('\n');
    // 표 바로 앞 `[이름]` 줄은 표 이름으로 (글 블록에서 뺌)
    final lastNonEmptyIndex = lines.lastIndexWhere(
      (line) => line.trim().isNotEmpty,
    );
    if (lastNonEmptyIndex >= 0) {
      final nameMatch = _tableNameLineRe.firstMatch(
        lines[lastNonEmptyIndex].trim(),
      );
      if (nameMatch != null) {
        pendingTableName = nameMatch.group(1);
        lines.removeAt(lastNonEmptyIndex);
      }
    }
    blocks.addAll(_parseLines(lines));
  }
  return blocks;
}

/// 줄 목록 > 목록·보조 설명·단락 (빈 줄은 경계)
List<StemBlock> _parseLines(List<String> lines) {
  final blocks = <StemBlock>[];
  final paragraphLines = <String>[];
  final listItems = <StemListItem>[];

  void flushParagraph() {
    if (paragraphLines.isEmpty) return;
    blocks.addAll(_splitQuestions(paragraphLines));
    paragraphLines.clear();
  }

  void flushList() {
    if (listItems.isEmpty) return;
    blocks.add(StemList(List.of(listItems)));
    listItems.clear();
  }

  for (final rawLine in lines) {
    final line = rawLine.trim();
    final listMatch = _listLineRe.firstMatch(line);
    if (line.isEmpty) {
      flushParagraph();
      flushList();
    } else if (listMatch != null) {
      flushParagraph();
      listItems.add(_toListItem(listMatch.group(1)!.trim()));
    } else if (_noteLineRe.hasMatch(line)) {
      flushParagraph();
      flushList();
      blocks.add(StemNote(_noteLineRe.firstMatch(line)!.group(1)!.trim()));
    } else {
      flushList();
      paragraphLines.add(line);
    }
  }
  flushParagraph();
  flushList();
  return blocks;
}

/// 목록 줄 글 > 용어·설명 (용어 형식이 아니면 글 그대로)
StemListItem _toListItem(String text) {
  final termMatch = _listTermRe.firstMatch(text);
  if (termMatch == null) return StemListItem(text: text);
  return StemListItem(
    term: termMatch.group(1)!.trim(),
    text: termMatch.group(2)!.trim(),
  );
}

/// 단락 줄 > 질문 문장 떼기 (? 로 끝나고 한글 있는 문장), 앞뒤 글은 각자 단락 (줄바꿈 유지)
List<StemBlock> _splitQuestions(List<String> lines) {
  final blocks = <StemBlock>[];
  final paragraphLines = <String>[];

  void flushParagraph() {
    final text = paragraphLines.join('\n').trim();
    if (text.isNotEmpty) blocks.add(StemParagraph(text));
    paragraphLines.clear();
  }

  for (final line in lines) {
    final lineSentences = <String>[];
    for (final sentence in line.split(_sentenceEndRe)) {
      if (_isQuestionSentence(sentence)) {
        if (lineSentences.isNotEmpty) paragraphLines.add(lineSentences.join(' '));
        lineSentences.clear();
        flushParagraph();
        blocks.add(StemQuestion(sentence));
      } else if (sentence.isNotEmpty) {
        lineSentences.add(sentence);
      }
    }
    if (lineSentences.isNotEmpty) paragraphLines.add(lineSentences.join(' '));
  }
  flushParagraph();
  return blocks;
}

bool _isQuestionSentence(String sentence) =>
    sentence.endsWith('?') && _hangulRe.hasMatch(sentence);

/// 코드 펜스 안 > 캡션별 코드 (맨 첫 줄·빈 줄 다음 줄의 `--` 주석이 캡션)
List<StemCode> _parseCodeBlocks(String code) {
  final codes = <StemCode>[];
  String? caption;
  final codeLines = <String>[];

  void flushCode() {
    final body = codeLines.join('\n').trim();
    if (body.isNotEmpty) codes.add(StemCode(caption: caption, code: body));
    codeLines.clear();
  }

  var isAtSegmentStart = true;
  for (final line in code.trimRight().split('\n')) {
    final labelMatch = _codeLabelLineRe.firstMatch(line.trim());
    if (isAtSegmentStart && labelMatch != null) {
      flushCode();
      caption = labelMatch.group(1)!.trim();
      isAtSegmentStart = false;
      continue;
    }
    isAtSegmentStart = line.trim().isEmpty;
    codeLines.add(line);
  }
  flushCode();
  return codes;
}

/// 스키마 표 배치: 같은 컬럼 지문 표 자리 대체 > 없으면 첫 표·코드 앞 > 첫 질문 앞 > 맨 끝
List<StemBlock> _placeSchemaTables(
  List<StemBlock> blocks,
  List<QuestionSchemaTable> schemaTables,
) {
  final placed = List<StemBlock>.of(blocks);
  final unmatchedTables = <StemTable>[];
  for (final schemaTable in schemaTables) {
    final table = _toStemTable(schemaTable);
    final duplicateIndex = placed.indexWhere(
      (block) =>
          block is StemTable &&
          block.columnSignature == table.columnSignature,
    );
    if (duplicateIndex >= 0) {
      placed[duplicateIndex] = table;
    } else {
      unmatchedTables.add(table);
    }
  }
  if (unmatchedTables.isEmpty) return placed;

  var insertIndex = placed.indexWhere(
    (block) => block is StemTable || block is StemCode,
  );
  if (insertIndex < 0) {
    insertIndex = placed.indexWhere((block) => block is StemQuestion);
  }
  if (insertIndex < 0) insertIndex = placed.length;
  placed.insertAll(insertIndex, unmatchedTables);
  return placed;
}

StemTable _toStemTable(QuestionSchemaTable table) => StemTable(
  name: table.tableName,
  columns: table.columns,
  rows: [for (final row in table.sampleRows) List<Object?>.of(row)],
);
