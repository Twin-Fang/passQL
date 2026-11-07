import type { QuestionSchemaTable } from "../types/api";
import { SQL_NULL_CELL_LABEL } from "./sqlCellPresentation";
import { placeSchemaTables } from "./stemSchemaTablePlacement";

/**
 * 문제 지문 > 블록(단락·보조 설명·질문·목록·표·코드) 나누기 + 스키마 표 배치 (#903)
 * 앱 stem 블록 규칙과 같은 계약 (docs/superpowers/specs/2026-11-07-stem-readability-design.md 1~8)
 */

export interface StemTableColumn {
  readonly name: string;
  readonly isPrimaryKey: boolean;
  readonly isForeignKey: boolean;
}

/** 지문 표·스키마 표 공통 모양 (셀 null = SQL NULL) */
export interface StemTable {
  readonly name: string | null;
  readonly columns: readonly StemTableColumn[];
  readonly rows: readonly (readonly (string | null)[])[];
}

/** 목록 항목: `용어: 설명` 이면 term 있음, 번호 목록이면 ordinal ("1.") 유지 */
export interface StemListItem {
  readonly ordinal: string | null;
  readonly term: string | null;
  readonly description: string;
}

export type StemBlock =
  | { readonly kind: "paragraph"; readonly text: string }
  | { readonly kind: "note"; readonly text: string }
  | { readonly kind: "question"; readonly text: string }
  | { readonly kind: "list"; readonly items: readonly StemListItem[] }
  | { readonly kind: "table"; readonly table: StemTable }
  | { readonly kind: "code"; readonly caption: string | null; readonly code: string };

// 코드 펜스 여는 줄 (```sql), 닫는 줄 (```)
const CODE_FENCE_OPEN_PATTERN = /^\s*```\s*[\w+-]*\s*$/;
const CODE_FENCE_CLOSE_PATTERN = /^\s*```\s*$/;
// 표 머리·본문 줄은 | 로 시작, 구분 줄은 | --- | :---: |
const TABLE_ROW_PATTERN = /^\s*\|/;
const TABLE_SEPARATOR_PATTERN = /^\s*\|?\s*:?-{3,}:?\s*(\|\s*:?-{3,}:?\s*)*\|?\s*$/;
// 표 이름 줄: [EMP], [TAB1] (영문·숫자·_)
const TABLE_NAME_PATTERN = /^\s*\[([A-Za-z0-9_]+)\]\s*$/;
// 목록 표시 4종: - • * 숫자.
const LIST_ITEM_PATTERN = /^\s*(?:[-•*]|(\d+\.))\s+(.*)$/;
// 용어: 설명 (콜론 앞 1~20자, 콜론 뒤 공백)
const LIST_TERM_PATTERN = /^([^:]{1,20}):\s+(.+)$/;
// 보조 설명: 줄 전체가 괄호
const NOTE_LINE_PATTERN = /^\s*\(.*\)\s*$/;
// 코드 캡션 주석 (-- SQL 1)
const CODE_CAPTION_PATTERN = /^\s*--\s+(.*\S)\s*$/;
// 문장 경계: . ? ! 뒤 공백
const SENTENCE_BOUNDARY_PATTERN = /[.?!](?=\s)/g;
const HANGUL_PATTERN = /[가-힣]/;

/** 지문 + 스키마 표 > 그릴 블록 목록 (작성 순서 유지, 스키마 표 자리만 정함) */
export function toStemBlocks(
  stem: string,
  schemaTables: readonly QuestionSchemaTable[] | null | undefined = [],
): StemBlock[] {
  const stemBlocks = splitStemIntoBlocks(stem);
  return placeSchemaTables(stemBlocks, schemaTables ?? []);
}

/** 접힌 지문 한 줄 미리보기 (코드 > [SQL], 표 > [표]) */
export function toStemPreviewLine(stem: string): string {
  return splitStemIntoBlocks(stem)
    .map(toPreviewText)
    .join(" ")
    .replace(/\s+/g, " ")
    .trim();
}

function toPreviewText(block: StemBlock): string {
  switch (block.kind) {
    case "table":
      return "[표]";
    case "code":
      return "[SQL]";
    case "list":
      return block.items.map((item) => [item.ordinal, item.term, item.description].filter(Boolean).join(" ")).join(" ");
    default:
      return block.text;
  }
}

// ── 규칙 1: 코드 펜스 구간 분리 ──────────────────────────────

function splitStemIntoBlocks(stem: string): StemBlock[] {
  const blocks: StemBlock[] = [];
  let proseLines: string[] = [];
  let codeLines: string[] | null = null;

  for (const line of stem.replace(/\r\n/g, "\n").split("\n")) {
    if (codeLines === null && CODE_FENCE_OPEN_PATTERN.test(line)) {
      blocks.push(...splitProseIntoBlocks(proseLines));
      proseLines = [];
      codeLines = [];
    } else if (codeLines !== null && CODE_FENCE_CLOSE_PATTERN.test(line)) {
      blocks.push(...splitCodeIntoCaptionedBlocks(codeLines));
      codeLines = null;
    } else if (codeLines !== null) {
      codeLines.push(line);
    } else {
      proseLines.push(line);
    }
  }
  // 닫히지 않은 펜스는 끝까지 코드
  if (codeLines !== null) blocks.push(...splitCodeIntoCaptionedBlocks(codeLines));
  blocks.push(...splitProseIntoBlocks(proseLines));
  return blocks;
}

// ── 규칙 2~6: 펜스 밖 글 > 표·목록·보조 설명·단락(질문 떼기) ──────────

function splitProseIntoBlocks(lines: readonly string[]): StemBlock[] {
  const blocks: StemBlock[] = [];
  let paragraphLines: string[] = [];
  let listItems: StemListItem[] = [];

  const flushParagraph = () => {
    if (paragraphLines.length > 0) blocks.push(...splitParagraphAtQuestions(paragraphLines.join("\n")));
    paragraphLines = [];
  };
  const flushList = () => {
    if (listItems.length > 0) blocks.push({ kind: "list", items: listItems });
    listItems = [];
  };

  for (let lineIndex = 0; lineIndex < lines.length; lineIndex++) {
    const line = lines[lineIndex];
    const listItemMatch = LIST_ITEM_PATTERN.exec(line);

    // 빈 줄 = 블록 경계
    if (line.trim() === "") {
      flushParagraph();
      flushList();
    } else if (isTableStart(lines, lineIndex)) {
      // 바로 앞 줄 [이름] 은 표 이름으로 옮기고 단락에서 지움
      const previousLine = paragraphLines[paragraphLines.length - 1];
      const tableNameMatch = previousLine === undefined ? null : TABLE_NAME_PATTERN.exec(previousLine);
      if (tableNameMatch) paragraphLines.pop();
      flushParagraph();
      flushList();
      const tableEndIndex = findTableEndIndex(lines, lineIndex);
      blocks.push({ kind: "table", table: parseMarkdownTable(lines.slice(lineIndex, tableEndIndex), tableNameMatch?.[1] ?? null) });
      lineIndex = tableEndIndex - 1;
    } else if (listItemMatch) {
      flushParagraph();
      listItems.push(toListItem(listItemMatch[1] ?? null, listItemMatch[2]));
    } else if (NOTE_LINE_PATTERN.test(line)) {
      flushParagraph();
      flushList();
      blocks.push({ kind: "note", text: line.trim() });
    } else {
      flushList();
      paragraphLines.push(line);
    }
  }
  flushParagraph();
  flushList();
  return blocks;
}

function isTableStart(lines: readonly string[], lineIndex: number): boolean {
  const nextLine = lines[lineIndex + 1];
  return TABLE_ROW_PATTERN.test(lines[lineIndex]) && nextLine !== undefined && TABLE_SEPARATOR_PATTERN.test(nextLine);
}

/** 머리 줄·구분 줄 다음 | 로 시작하는 줄이 끝나는 위치 (끝 줄 다음 인덱스) */
function findTableEndIndex(lines: readonly string[], tableStartIndex: number): number {
  let endIndex = tableStartIndex + 2;
  while (endIndex < lines.length && TABLE_ROW_PATTERN.test(lines[endIndex])) endIndex++;
  return endIndex;
}

/** 마크다운 표 줄 > 표 (구분 줄 제외, 셀 글자 NULL > SQL NULL) */
function parseMarkdownTable(tableLines: readonly string[], tableName: string | null): StemTable {
  const [headerLine, , ...bodyLines] = tableLines;
  const columns = splitTableCells(headerLine).map((name) => ({ name, isPrimaryKey: false, isForeignKey: false }));
  const rows = bodyLines.map((bodyLine) =>
    splitTableCells(bodyLine).map((cell) => (cell === SQL_NULL_CELL_LABEL ? null : cell)),
  );
  return { name: tableName, columns, rows };
}

function splitTableCells(tableLine: string): string[] {
  return tableLine
    .trim()
    .replace(/^\|/, "")
    .replace(/\|$/, "")
    .split("|")
    .map((cell) => cell.trim());
}

function toListItem(ordinal: string | null, itemText: string): StemListItem {
  const termMatch = LIST_TERM_PATTERN.exec(itemText.trim());
  const term = termMatch?.[1].trim();
  if (termMatch && term) return { ordinal, term, description: termMatch[2].trim() };
  return { ordinal, term: null, description: itemText.trim() };
}

/** 단락 > 한글 있는 ? 문장만 질문으로 떼고, 앞뒤 글은 각자 단락 (줄바꿈 유지) */
function splitParagraphAtQuestions(paragraphText: string): StemBlock[] {
  const blocks: StemBlock[] = [];
  let pendingText = "";
  const flushPendingParagraph = () => {
    if (pendingText.trim()) blocks.push({ kind: "paragraph", text: pendingText.trim() });
    pendingText = "";
  };

  for (const sentence of splitSentencesKeepingSpacing(paragraphText)) {
    const trimmedSentence = sentence.trim();
    if (trimmedSentence.endsWith("?") && HANGUL_PATTERN.test(trimmedSentence)) {
      flushPendingParagraph();
      blocks.push({ kind: "question", text: trimmedSentence });
    } else {
      pendingText += sentence;
    }
  }
  flushPendingParagraph();
  return blocks;
}

/** 문장 경계(. ? ! 뒤 공백)에서 자름, 경계 뒤 공백은 다음 문장 앞에 남겨 원문 그대로 이어 붙일 수 있게 */
function splitSentencesKeepingSpacing(text: string): string[] {
  const sentences: string[] = [];
  let sentenceStart = 0;
  for (const boundary of text.matchAll(SENTENCE_BOUNDARY_PATTERN)) {
    const sentenceEnd = (boundary.index ?? 0) + 1;
    sentences.push(text.slice(sentenceStart, sentenceEnd));
    sentenceStart = sentenceEnd;
  }
  if (sentenceStart < text.length) sentences.push(text.slice(sentenceStart));
  return sentences;
}

// ── 규칙 7: 코드 캡션 (맨 첫 줄·빈 줄 다음 -- 주석) ──────────────

function splitCodeIntoCaptionedBlocks(codeLines: readonly string[]): StemBlock[] {
  const sections: { caption: string | null; lines: string[] }[] = [{ caption: null, lines: [] }];

  codeLines.forEach((line, lineIndex) => {
    const isAfterBlankLine = lineIndex === 0 || codeLines[lineIndex - 1].trim() === "";
    const captionMatch = isAfterBlankLine ? CODE_CAPTION_PATTERN.exec(line) : null;
    if (captionMatch) sections.push({ caption: captionMatch[1], lines: [] });
    else sections[sections.length - 1].lines.push(line);
  });

  return sections
    .map((section) => ({ caption: section.caption, code: trimBlankEdgeLines(section.lines) }))
    .filter((section) => section.caption !== null || section.code !== "")
    .map((section): StemBlock => ({ kind: "code", caption: section.caption, code: section.code }));
}

/** 앞뒤 빈 줄만 지움 (들여쓰기 유지) */
function trimBlankEdgeLines(lines: readonly string[]): string {
  let startIndex = 0;
  let endIndex = lines.length;
  while (startIndex < endIndex && lines[startIndex].trim() === "") startIndex++;
  while (endIndex > startIndex && lines[endIndex - 1].trim() === "") endIndex--;
  return lines.slice(startIndex, endIndex).join("\n");
}
