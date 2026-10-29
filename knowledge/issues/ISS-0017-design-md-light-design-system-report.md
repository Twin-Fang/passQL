---
type: completion-report
id: ISS-0017
created: 2026-04-08
topics: [design-system]
status: resolved
resolves: "[[ISS-0017-design-md-light-design-system]]"
related: ["[[DEC-0022-design-md-single-source-of-truth]]"]
source: "https://github.com/Twin-Fang/passQL/issues/20"
---

# ISS-0017 완료 리포트: Design.md를 라이트 모드로 교체하고 tokens·components·typography와 동기화

GitHub #20 프론트 담당 작업 보고 댓글(2026-04-08) 기준, 2026-04-22 완료 보고 보충.

## 해결 방법
- `.claude/rules/Design.md`: Linear 다크 모드 → passQL 라이트 모드. Pretendard Variable(UI) + JetBrains Mono(코드), `#FAFAFA` 배경, `#4F46E5` 인디고, `#E5E7EB` 보더, 그림자 없음(배경색 차이로 elevation).
- `src/styles/tokens.css`: surface/brand/text/border/semantic/heatmap 토큰, 4px base 7단계 스페이싱(4/8/12/16/20/24/32px), `cubic-bezier(0.4, 0, 0.2, 1)`.
- `typography.css`: `.text-h1` `letter-spacing: -0.5px`, `.text-h2` `-0.3px`, body `line-height: 1.7`.
- `components.css`: 12개 클래스 정비(카드 16px/24px, 코드 블록 12px + 좌측 4px 보더, hover `translateY(-1px)`).
- 페이지: CTA 순서 통일, box-shadow 제거, 유니코드 심볼 → lucide-react.
- UX 라이팅: 토스 라이팅 원칙 적용, `.claude/rules/TOSS_UI_UX_DESIGN.md` 추가.
- `VITE_USE_MOCK` 환경변수로 mock on/off, `src/api/mock-data.test.ts` 21건.
- 2026-04-22 보고: daisyUI 클래스 전면 적용, card-base → Tailwind 유틸리티, 에러 상태 UI 개선, 전체 화면 UI 통일.

## 근본 원인 (확정)
원본에 별도 기록 없음 (이슈 본문의 문제점 참조).

## 재발 방지
리포트: Design.md(문서) → tokens.css → components.css / typography.css 3곳이 같은 값을 참조하도록 정합성 확보. 다크 모드는 미지원 — 필요 시 Design.md에 다크 토큰 섹션 추가.

## 교훈
원본에 적혀 있지 않다.
