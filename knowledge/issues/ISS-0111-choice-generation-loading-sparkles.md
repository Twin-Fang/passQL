---
type: issue
id: ISS-0111
created: 2026-04-12
topics: [practice, ai]
symptoms: ["선택지 생성 중", "로딩 UI", spinner, Sparkles, animate-pulse-fast, QuestionDetail]
root_cause: "AI 선택지 생성 로딩이 단순 spinner와 텍스트뿐이라 AI 작업 중임이 드러나지 않았다"
status: resolved
resolution: null
related: []
source: "https://github.com/Twin-Fang/passQL/issues/196"
---

# ISS-0111: 선택지 생성 중 로딩 UI를 Sparkles 아이콘·문구로 개선

GitHub #196 (원본: 이슈 본문과 이미지 댓글 하나. 텍스트 완료 기록 없음).

## 증상
AI 선택지 생성 중 로딩 UI가 단순 spinner + "선택지 생성 중..."이라 사용자가 AI가 작업 중임을 직관적으로 알기 어렵다.

## 재현 조건
해당 없음 (기능 개선).

## 조사 기록
- 2026-04-12: 이슈 등록. 제안: spinner → lucide `Sparkles`(프로젝트 AI UI 통일 기준), 문구 "AI가 선택지를 만들고 있어요", `animate-pulse-fast`(1.2s). 관련 파일 `client/src/pages/QuestionDetail.tsx`, `client/src/styles/components.css`.
- 같은 날 이미지 댓글. 구현 내용 텍스트는 원본에 없다.

## 근본 원인
원본에 적혀 있지 않다 (UI 개선 요청).
