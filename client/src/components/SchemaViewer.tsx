import QuestionCodeBox from "./question/QuestionCodeBox";

interface SchemaViewerProps {
  readonly schemaDdl?: string | null;
  readonly schemaSampleData?: string | null;
}

/**
 * 스키마 원문 상자: 서버가 표로 해석하지 못한 DDL·샘플 INSERT 원문 (해석된 표는 지문 블록 안 QuestionTable)
 * DDL 없으면 렌더하지 않음
 */
export function SchemaViewer({ schemaDdl, schemaSampleData }: SchemaViewerProps) {
  if (!schemaDdl?.trim()) return null;

  return (
    <section className="flex flex-col gap-3" aria-label="문제 테이블 원문">
      <QuestionCodeBox code={schemaDdl} />
      {schemaSampleData?.trim() ? <QuestionCodeBox code={schemaSampleData} /> : null}
    </section>
  );
}
