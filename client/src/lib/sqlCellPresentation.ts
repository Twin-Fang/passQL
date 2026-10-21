/** SQL NULL 셀 표시 문구 (스키마 표, 실행 결과, 결과형 보기 공통) */
export const SQL_NULL_CELL_LABEL = "NULL";

/** 셀 값이 SQL NULL 인지 (JSON null, 키 없음) */
export function isSqlNullCell(cell: unknown): boolean {
  return cell == null;
}

/** 셀 값 > 표시 문구 (NULL 은 빈칸이 아닌 NULL 로) */
export function toSqlCellText(cell: unknown): string {
  return isSqlNullCell(cell) ? SQL_NULL_CELL_LABEL : String(cell);
}
