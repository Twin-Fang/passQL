import type { QuestionSchemaTable } from "../types/api";
import type { StemBlock, StemTable } from "./stemBlocks";

/**
 * 지문 블록 + 스키마 표 > 스키마 표 배치 (#903, 지문 블록 규칙 8)
 * 같은 컬럼 지문 표 자리 대체(중복 제거), 없으면 첫 표·코드 앞 > 첫 질문 앞 > 맨 끝
 */

/** 스키마 표 > 지문 표 모양 (자료형 버림, 셀 null = SQL NULL 유지) */
function toStemTableFromSchema(schemaTable: QuestionSchemaTable): StemTable {
  return {
    name: schemaTable.tableName,
    columns: schemaTable.columns.map((column) => ({
      name: column.name,
      isPrimaryKey: column.isPrimaryKey,
      isForeignKey: column.isForeignKey,
    })),
    rows: schemaTable.sampleRows.map((row) => row.map((cell) => (cell == null ? null : String(cell)))),
  };
}

/** 스키마 표마다: 같은 컬럼 지문 표 대체, 남은 표는 한 자리에 작성 순서대로 */
export function placeSchemaTables(
  stemBlocks: readonly StemBlock[],
  questionSchemaTables: readonly QuestionSchemaTable[],
): StemBlock[] {
  const schemaTables = questionSchemaTables.map(toStemTableFromSchema);
  const placedBlocks = [...stemBlocks];
  const replacedBlockIndexes = new Set<number>();
  const unmatchedSchemaTables: StemTable[] = [];

  // 같은 컬럼 구성의 지문 표 자리 > 스키마 표로 대체 (중복 제거)
  for (const schemaTable of schemaTables) {
    const matchedIndex = placedBlocks.findIndex(
      (block, blockIndex) =>
        block.kind === "table" && !replacedBlockIndexes.has(blockIndex) && hasSameColumnNames(block.table, schemaTable),
    );
    if (matchedIndex >= 0) {
      placedBlocks[matchedIndex] = { kind: "table", table: schemaTable };
      replacedBlockIndexes.add(matchedIndex);
    } else {
      unmatchedSchemaTables.push(schemaTable);
    }
  }

  if (unmatchedSchemaTables.length > 0) {
    const insertIndex = findSchemaInsertIndex(placedBlocks);
    placedBlocks.splice(insertIndex, 0, ...unmatchedSchemaTables.map((table): StemBlock => ({ kind: "table", table })));
  }
  return placedBlocks;
}

/** 컬럼 이름 목록 비교 (대소문자 무시, 순서 같음) */
function hasSameColumnNames(stemTable: StemTable, schemaTable: StemTable): boolean {
  if (stemTable.columns.length !== schemaTable.columns.length) return false;
  return stemTable.columns.every(
    (column, columnIndex) => column.name.toUpperCase() === schemaTable.columns[columnIndex].name.toUpperCase(),
  );
}

/** 넣을 자리: 첫 표·코드 앞 > 첫 질문 앞 > 맨 끝 */
function findSchemaInsertIndex(blocks: readonly StemBlock[]): number {
  const firstTableOrCodeIndex = blocks.findIndex((block) => block.kind === "table" || block.kind === "code");
  if (firstTableOrCodeIndex >= 0) return firstTableOrCodeIndex;
  const firstQuestionIndex = blocks.findIndex((block) => block.kind === "question");
  return firstQuestionIndex >= 0 ? firstQuestionIndex : blocks.length;
}
