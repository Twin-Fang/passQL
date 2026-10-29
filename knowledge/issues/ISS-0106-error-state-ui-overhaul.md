---
type: issue
id: ISS-0106
created: 2026-04-12
topics: [design-system]
symptoms: [ErrorFallback, errorType, "에러 상태 UI", btn-compact, "홈 인라인 에러", "헤딩 사라짐", AnswerFeedback, error-card]
root_cause: "에러 상태 UI가 화면마다 일관성 없고 미완성 상태였다"
status: resolved
resolution: null
related: []
source: "https://github.com/Twin-Fang/passQL/issues/190"
---

# ISS-0106: 에러 상태 UI 전면 개선 (ErrorFallback·홈 인라인 에러·버튼 통일)

GitHub #190 (원본: 이슈 본문만. 댓글 없음).

## 증상
- `ErrorFallback`: 텍스트 한 줄 + 재시도 버튼뿐, 원인 안내 없음.
- 홈 인라인 에러 버튼이 daisyUI `btn btn-xs btn-outline btn-primary`로 크게 표시. 홈 카드가 daisyUI `card bg-white ...`와 혼용.
- 히트맵·통계 에러 레이아웃이 불안정. `Stats`, `CategoryCards`는 에러 시 헤딩 없이 카드만 반환.
- `AnswerFeedback` SQL 실행 에러가 스타일 없이 나열. 오늘의 문제 없음 문구 "AI문제 풀기 / SQL AI문제를 풀어보세요"가 홍보 문구처럼 어색.

## 재현 조건
API 오류 상태에서 홈·통계·문제 화면 진입.

## 조사 기록
- 2026-04-12: 이슈 등록. 제안: `ErrorFallback`을 `card-base` + 아이콘 + 제목 + 설명 + `btn-compact` 재시도로, `errorType`(`network`/`server`/`auth`/`generic`) prop — 원인을 모르면 기본값 `generic`("데이터를 불러올 수 없어요"), 원인 추측 하드코딩 금지. 헤딩 항상 렌더링, `error-card` + `AlertCircle`/`RefreshCw`, 문구 "오늘의 문제 / 오늘은 등록된 문제가 없어요". 후속 고려: `ApiError.status` 기반 분류(401 → auth, 5xx → server, network error → network).
- 구현·완료 기록은 원본에 없다(이슈는 completed로 닫힘). GitHub #187 리포트가 `ErrorFallback.tsx`의 `card-base` 사용처를 교체했다고 적었다.

## 근본 원인
원본에 적혀 있지 않다 (디자인 개선 요청).
