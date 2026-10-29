---
type: issue
id: ISS-0164
created: 2026-04-25
topics: [home, design-system]
symptoms: ["섹션 타이틀 CSS 불일치", text-secondary, text-text-caption, progressError, heatmapError, "합격 준비도 제목 누락"]
root_cause: "홈 섹션 타이틀 클래스가 제각각이고 `text-secondary`(존재하지 않는 클래스) 오타, `progressError` 카드에 제목 누락"
status: resolved
resolution: "[[ISS-0164-home-section-title-css-unify-report]]"
related: []
source: "https://github.com/Twin-Fang/passQL/issues/307"
---

# ISS-0164: 홈 섹션 타이틀 CSS 통일 및 에러 상태 제목 누락

GitHub #307 (원본: 이슈 본문과 구현 완료 보고 댓글).

## 증상
홈 섹션 타이틀이 `text-secondary`(존재하지 않는 클래스), `text-text-caption`, `text-text-secondary`, `p`/`h2` 혼재. `progressError` 상태에서 "합격 준비도" 제목 없이 에러 메시지만 표시, `heatmapError` 카드 내부 구조도 불일치.

## 재현 조건
홈에서 진도 API 에러 상태(`progressError`)일 때 제목 누락.

## 조사 기록
- 2026-04-25: 대상 파일 `client/src/pages/Home.tsx`.

## 근본 원인
타이틀 스타일 기준 부재와 클래스 오타.
