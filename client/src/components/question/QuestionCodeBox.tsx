interface QuestionCodeBoxProps {
  readonly code: string;
  // 코드 앞 -- 주석에서 뗀 캡션 (예: SQL 2 (결과 행 수를 C4 라 한다))
  readonly caption?: string | null;
}

// 캡션 끝 괄호 설명: "SQL 2 (설명)" > 제목 "SQL 2", 설명 "(설명)"
const CAPTION_TRAILING_NOTE_PATTERN = /^(.*?)\s*(\([^()]*\))$/;

/**
 * 지문 SQL 코드 상자: 캡션(강조색 굵게, 괄호 설명은 보통 굵기) > 테두리 상자 (#903)
 */
export default function QuestionCodeBox({ code, caption = null }: QuestionCodeBoxProps) {
  const captionNoteMatch = caption ? CAPTION_TRAILING_NOTE_PATTERN.exec(caption) : null;
  const captionTitle = captionNoteMatch?.[1] || caption;
  const captionNote = captionNoteMatch?.[1] ? captionNoteMatch[2] : null;

  return (
    <figure className="flex flex-col gap-1.5">
      {captionTitle ? (
        <figcaption className="text-footnote font-semibold text-brand break-keep">
          {captionTitle}
          {captionNote ? <span className="ml-1 font-normal text-text-secondary">{captionNote}</span> : null}
        </figcaption>
      ) : null}
      {code ? <pre className="sql-code-box">{code}</pre> : null}
    </figure>
  );
}
