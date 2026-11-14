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

/// 줄 전체가 괄호로 싸인 보조 설명 (괄호 포함 원문 그대로)
class StemNote extends StemBlock {
  const StemNote(this.text);
  final String text;
}

/// `?` 로 끝나는 질문 문장
class StemQuestion extends StemBlock {
  const StemQuestion(this.text);
  final String text;
}

/// 목록 항목: `용어: 설명` 이면 term 있음, 번호 목록이면 ordinal ("1.") 유지 (보기가 번호를 가리킴)
class StemListItem {
  const StemListItem({this.ordinal, this.term, required this.text});
  final String? ordinal;
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

/// 목록 줄: `- `, `• `, `* `, `1. ` (번호는 group 1)
final RegExp _listLineRe = RegExp(r'^(?:[-•*]|(\d+\.))\s+(.*)$');

/// 목록 용어: 콜론 앞 1~20자 + 콜론 + 공백
final RegExp _listTermRe = RegExp(r'^([^:：]{1,20})[:：]\s+(.+)$');

/// 보조 설명 줄: 줄 전체가 괄호
final RegExp _noteLineRe = RegExp(r'^\(.+\)$');

/// 문장 끝: . ? ! 뒤 공백
final RegExp _sentenceEndRe = RegExp(r'(?<=[.?!])\s+');

final RegExp _hangulRe = RegExp(r'[가-힣]');

/// 코드 라벨 주석 줄: `-- SQL 1`
final RegExp _codeLabelLineRe = RegExp(r'^--\s*(.+)$');

/// 캡션 끝 괄호 설명: `SQL 2 (결과 행 수를 C4 라 한다)` > 라벨 `SQL 2`
final RegExp _captionTrailingNoteRe = RegExp(r'^(.*?)\s*\([^()]*\)$');

/// 캡션 라벨 최대 길이 (넘으면 제약 설명 같은 코드 주석으로 봄)
const int _maximumCaptionLabelLength = 20;

/// 캡션 라벨에 있으면 코드 주석으로 보는 글: `:`·`(`·SQL 키워드 (예: `EMP.DEPT_NO : REFERENCES ...`)
final RegExp _codeCommentMarkerRe = RegExp(
  r'[:(]|\b(?:SELECT|FROM|WHERE|SET|UPDATE|INSERT|DELETE|REFERENCES|ON|CASCADE|CREATE|ALTER|DROP|NULL)\b',
  caseSensitive: false,
);

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
      listItems.add(_toListItem(listMatch.group(1), listMatch.group(2)!.trim()));
    } else if (_noteLineRe.hasMatch(line)) {
      flushParagraph();
      flushList();
      blocks.add(StemNote(line));
    } else {
      flushList();
      paragraphLines.add(line);
    }
  }
  flushParagraph();
  flushList();
  return blocks;
}

/// 목록 줄 글 > 번호·용어·설명 (용어 형식이 아니면 글 그대로)
StemListItem _toListItem(String? ordinal, String text) {
  final termMatch = _listTermRe.firstMatch(text);
  if (termMatch == null) return StemListItem(ordinal: ordinal, text: text);
  return StemListItem(
    ordinal: ordinal,
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

/// 코드 펜스 안 > 캡션별 코드 (맨 첫 줄·빈 줄·`;` 로 끝난 줄 다음의 짧은 이름표 `--` 주석만 캡션, 나머지 주석은 코드에 남김)
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
    final captionText = _codeLabelLineRe
        .firstMatch(line.trim())
        ?.group(1)
        ?.trim();
    if (isAtSegmentStart &&
        captionText != null &&
        _isCaptionLabel(captionText)) {
      flushCode();
      caption = captionText;
      isAtSegmentStart = false;
      continue;
    }
    // 새 SQL 시작: 빈 줄 다음 또는 앞 문장이 `;` 로 끝남 (빈 줄 없이 이어 쓴 `-- X`·`-- Y` 묶음)
    isAtSegmentStart = line.trim().isEmpty || line.trimRight().endsWith(';');
    codeLines.add(line);
  }
  flushCode();
  return codes;
}

/// 짧은 이름표 주석인지: 끝 괄호 설명 뺀 라벨 20자 이하 + `:`·`(`·SQL 키워드 없음 (`SQL 1`, `쿼리 A`)
bool _isCaptionLabel(String captionText) {
  final label =
      _captionTrailingNoteRe.firstMatch(captionText)?.group(1)?.trim() ??
      captionText;
  return label.isNotEmpty &&
      label.length <= _maximumCaptionLabelLength &&
      !_codeCommentMarkerRe.hasMatch(label);
}

/// 스키마 표 배치: 같은 표 지문 표 자리 대체(지문 표 하나에 한 번) > 없으면 첫 표·코드 앞 > 첫 질문 앞 > 맨 끝
List<StemBlock> _placeSchemaTables(
  List<StemBlock> blocks,
  List<QuestionSchemaTable> schemaTables,
) {
  final placed = List<StemBlock>.of(blocks);
  final replacedIndexes = <int>{};
  final unmatchedTables = <StemTable>[];
  for (final schemaTable in schemaTables) {
    final table = _toStemTable(schemaTable);
    var duplicateIndex = -1;
    for (var index = 0; index < placed.length; index++) {
      final block = placed[index];
      if (block is StemTable &&
          !replacedIndexes.contains(index) &&
          _isSameTable(block, table)) {
        duplicateIndex = index;
        break;
      }
    }
    if (duplicateIndex >= 0) {
      placed[duplicateIndex] = _withStemRowsIfSchemaEmpty(
        table,
        placed[duplicateIndex] as StemTable,
      );
      replacedIndexes.add(duplicateIndex);
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

/// 지문 표 <-> 스키마 표 같은 표인지: 양쪽 이름 있으면 이름(대소문자 무시), 없으면 컬럼 이름 목록
/// (컬럼만 보면 EMP(ID, DEPT_NO) 자리에 PROJ(ID, DEPT_NO) 가 들어가 EMP 데이터가 사라짐)
bool _isSameTable(StemTable stemTable, StemTable schemaTable) {
  final stemName = stemTable.name?.trim().toUpperCase() ?? '';
  final schemaName = schemaTable.name?.trim().toUpperCase() ?? '';
  if (stemName.isNotEmpty && schemaName.isNotEmpty) {
    return stemName == schemaName;
  }
  return stemTable.columnSignature == schemaTable.columnSignature;
}

/// 스키마 표에 예시 행이 없고 컬럼이 같으면 지문 표 행 유지 (지문 데이터 소실 방지)
StemTable _withStemRowsIfSchemaEmpty(
  StemTable schemaTable,
  StemTable stemTable,
) {
  final shouldKeepStemRows =
      schemaTable.rows.isEmpty &&
      stemTable.columnSignature == schemaTable.columnSignature;
  if (!shouldKeepStemRows) return schemaTable;
  return StemTable(
    name: schemaTable.name,
    columns: schemaTable.columns,
    rows: stemTable.rows,
  );
}

StemTable _toStemTable(QuestionSchemaTable table) => StemTable(
  name: table.tableName,
  columns: table.columns,
  rows: [for (final row in table.sampleRows) List<Object?>.of(row)],
);
