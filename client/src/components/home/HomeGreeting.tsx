import type { ReactNode } from "react";
import type { GreetingResponse } from "../../types/api";

interface HomeGreetingProps {
  readonly greeting: GreetingResponse | undefined;
  // 인사말을 받기 전 대체 이름 (닉네임, 없으면 UUID 앞 8자리)
  readonly displayName: string;
  readonly firstLineClassName: string;
  readonly restLinesClassName: string;
}

/**
 * greeting 메시지의 {nickname}을 강조 span으로 치환하고
 * \n 기준으로 줄을 분리한 ReactNode 배열을 반환한다.
 * 닉네임 강조는 백엔드 플레이스홀더 위치를 그대로 사용 — 프론트 비즈니스 로직 최소화.
 */
function parseGreetingLines(message: string, nickname: string): ReactNode[] {
  const lines = message.split("\n");
  return lines.map((line, lineIdx) => {
    const parts = line.split("{nickname}");
    if (parts.length === 1) return <span key={lineIdx}>{line}</span>;
    return (
      <span key={lineIdx}>
        {parts[0]}
        <span className="greeting-nickname">{nickname}</span>
        {parts[1]}
      </span>
    );
  });
}

/**
 * 홈 인사말 2단: 첫 줄 > 나머지 줄 + 시험 임박 서브메시지(EXAM_DAY/URGENT)
 */
export default function HomeGreeting({ greeting, displayName, firstLineClassName, restLinesClassName }: HomeGreetingProps) {
  return (
    <>
      {/* ① 그리팅 줄1: 첫 번째 줄만 렌더링 */}
      {/* CSS variable(--stagger-delay) 주입 — Tailwind로 표현 불가하여 style prop 예외 허용 */}
      <section className={`mb-1 ${firstLineClassName}`}>
        <h1 className="text-h2 leading-snug">
          {greeting ? (
            parseGreetingLines(greeting.message, greeting.nickname).map((line, i) =>
              i === 0 ? <span key={i} className="block">{line}</span> : null
            )
          ) : (
            // 이름을 모를 때 "안녕하세요,"처럼 쉼표만 남지 않게 한다 (#399)
            <span>{displayName ? `안녕하세요, ${displayName}` : "안녕하세요"}</span>
          )}
        </h1>
      </section>

      {/* ② 그리팅 줄2 + 서브메시지(EXAM_DAY/URGENT) */}
      <section className={`mb-6 ${restLinesClassName}`}>
        <h1 className="text-h2 leading-snug">
          {greeting &&
            parseGreetingLines(greeting.message, greeting.nickname).map((line, i) =>
              i > 0 ? <span key={i} className="block">{line}</span> : null
            )}
        </h1>
        {greeting?.messageType === "EXAM_DAY" && (
          <p className="text-sm font-medium mt-1 text-semantic-error-text">
            오늘 시험이에요!
          </p>
        )}
        {greeting?.messageType === "URGENT" && (
          <p className="text-sm font-medium mt-1 text-semantic-warning-text">
            시험이 얼마 남지 않았어요
          </p>
        )}
      </section>
    </>
  );
}
