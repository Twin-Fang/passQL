import { memo, useMemo } from "react";
import InlineMarkdownText from "../aiExplanation/InlineMarkdownText";
import { SchemaViewer } from "../SchemaViewer";
import QuestionCodeBox from "./QuestionCodeBox";
import QuestionTable from "./QuestionTable";
import { toStemBlocks, type StemBlock, type StemListItem } from "../../lib/stemBlocks";
import type { QuestionSchemaTable } from "../../types/api";

interface StemBlocksProps {
  readonly stem: string;
  // 서버가 해석한 스키마 표 (지문 카드 안 같은 표 모양으로 배치)
  readonly schemaTables?: readonly QuestionSchemaTable[] | null;
  // 스키마 해석 실패 때만 지문 아래 원문으로
  readonly schemaDdl?: string | null;
  readonly schemaSampleData?: string | null;
}

/**
 * 문제 지문 (풀이·해설·결과 공통): 블록(단락·보조 설명·질문·목록·표·코드) 순서대로 (#903)
 * 블록 규칙 원본 lib/stemBlocks
 */
function StemBlocks({ stem, schemaTables, schemaDdl, schemaSampleData }: StemBlocksProps) {
  const stemBlocks = useMemo(() => toStemBlocks(stem, schemaTables), [stem, schemaTables]);
  const hasSchemaTables = (schemaTables?.length ?? 0) > 0;

  return (
    <div className="flex min-w-0 flex-col gap-3">
      {stemBlocks.map((block, blockIndex) => (
        <StemBlockView key={blockIndex} block={block} />
      ))}
      {hasSchemaTables ? null : <SchemaViewer schemaDdl={schemaDdl} schemaSampleData={schemaSampleData} />}
    </div>
  );
}

function StemBlockView({ block }: { readonly block: StemBlock }) {
  switch (block.kind) {
    case "paragraph":
      return (
        <p className="text-body whitespace-pre-line break-keep wrap-break-word">
          <InlineMarkdownText text={block.text} />
        </p>
      );
    case "note":
      return (
        <p className="text-footnote leading-normal text-text-secondary break-keep">
          <InlineMarkdownText text={block.text} />
        </p>
      );
    case "question":
      return (
        <p className="text-headline font-semibold leading-snug text-text-primary whitespace-pre-line break-keep">
          <InlineMarkdownText text={block.text} />
        </p>
      );
    case "list":
      return <StemList items={block.items} />;
    case "table":
      return <QuestionTable table={block.table} />;
    case "code":
      return <QuestionCodeBox caption={block.caption} code={block.code} />;
  }
}

/** 목록 상자: 항목 사이 구분선, 용어는 굵게 한 줄 + 설명 다음 줄 */
function StemList({ items }: { readonly items: readonly StemListItem[] }) {
  return (
    <ul className="divide-y divide-border rounded-xl bg-surface-card px-3.5">
      {items.map((item, itemIndex) => (
        <li key={itemIndex} className="flex gap-1.5 py-2.5 text-subheadline leading-normal text-text-primary break-keep">
          {item.ordinal ? <span className="shrink-0 font-semibold tabular-nums">{item.ordinal}</span> : null}
          <span className="flex min-w-0 flex-col gap-0.5">
            {item.term ? (
              <span className="font-semibold">
                <InlineMarkdownText text={item.term} />
              </span>
            ) : null}
            <InlineMarkdownText text={item.description} />
          </span>
        </li>
      ))}
    </ul>
  );
}

// 부모 리렌더(타이머·선택 상태)마다 지문 재분해 방지
export default memo(StemBlocks);
