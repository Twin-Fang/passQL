---
type: decision
id: DEC-0059
created: 2026-04-12
reviewed: null
topics: [design-system, home]
status: active
supersedes: null
superseded_by: null
related: ["[[ISS-0085-ai-question-terminology-sparkles]]", "[[ISS-0085-ai-question-terminology-sparkles-report]]"]
---

# DEC-0059: 사용자 화면의 "문제"를 "AI문제"로 통일하고 lucide `Sparkles`를 AI 표시 전용 아이콘으로 쓴다

## 문제 정의 (Context)
AI 기반 SQL 교육이 핵심 가치인데 UI 어디에도 AI 표현이 드러나지 않아 서비스 정체성과 맞지 않았다 (GitHub #149).

## 결정 (Decision)
- 홈 추천 섹션 제목: `"추천 문제"` → `✦ AI 추천문제`(Sparkles 아이콘 + 텍스트).
- 하단 네비게이션 탭: `"문제"` → `"AI문제"`.
- 문제 목록/상세 페이지 제목: `"문제"` → `"AI문제"`.
- lucide-react `Sparkles`는 AI 표시 전용 아이콘.

## 검토한 대안 (Alternatives)
논의 기록 없음.

## 결과 (Consequences)
**긍정**
- 화면에서 AI 기능임을 인지할 수 있다(이슈 본문의 목표).

**부정**
- 논의 기록 없음.

## 영향 범위 (Scope)
`client/src/pages/Home.tsx`, `client/src/components/AppLayout.tsx`, 문제 관련 페이지 제목. 이후 결과 화면 AI 분석 뱃지(GitHub #161)도 Sparkles를 쓴다.

## 출처 (References)
- GitHub #149 이슈 본문, "Stable 적용완료" 댓글 (2026-04-12)
- [[ISS-0085-ai-question-terminology-sparkles]]
