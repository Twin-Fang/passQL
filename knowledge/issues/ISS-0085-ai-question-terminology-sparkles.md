---
type: issue
id: ISS-0085
created: 2026-04-12
topics: [design-system, home]
symptoms: ["AI 표현 부재", "추천 문제", "AI 추천문제", "AI문제", "하단 탭 문제", Sparkles]
root_cause: "기능 개선 — UI 전반에 AI 표현이 없어 AI 기반 SQL 교육이라는 서비스 정체성이 드러나지 않았다"
status: resolved
resolution: "[[ISS-0085-ai-question-terminology-sparkles-report]]"
related: ["[[DEC-0059-ai-question-terminology]]"]
source: "https://github.com/Twin-Fang/passQL/issues/149"
---

# ISS-0085: 서비스 전반 "문제" → "AI문제" 용어 통일 및 Sparkles 아이콘

GitHub #149 (원본: 이슈 본문과 댓글).

## 증상
passQL의 핵심 가치는 AI 기반 SQL 교육인데 UI에 "AI" 표현이 없다. 홈 추천 섹션은 "추천 문제", 하단 탭은 "문제", 문제 관련 페이지 제목에도 AI 브랜딩이 없다.

## 재현 조건
해당 없음 (기능 개선).

## 조사 기록
- 2026-04-12: 이슈 본문 작업 내용 — `client/src/pages/Home.tsx:263` 섹션 제목 + Sparkles, `client/src/components/AppLayout.tsx` 탭 문구, 문제 페이지 제목 일괄 변경.
- 2026-04-12: "Stable 적용완료" 댓글.

## 근본 원인
해당 없음 (기능 개선).
