---
type: completion-report
id: ISS-0126
created: 2026-04-13
topics: [community]
status: resolved
resolves: "[[ISS-0126-connect-feedback-api-chat-ui]]"
related: []
source: "https://github.com/Twin-Fang/passQL/issues/229"
---

# ISS-0126 완료 리포트: 건의사항 404 fallback 제거와 채팅 버블 UI 적용

GitHub #229 리포트 댓글(2026-04-13) 기준.

## 해결 방법
- `src/hooks/useFeedback.ts`: `queryFn`의 404 catch 분기 제거. 에러는 React Query `isError`로 올라가 `ErrorFallback`이 렌더링된다. `staleTime: 0` 설정 — 원본 사유: 상태(`PENDING → REVIEWED → APPLIED`)는 관리자 액션으로 바뀌어 프론트가 시점을 예측할 수 없으므로 매 진입마다 재확인.
- `src/components/SubpageLayout.tsx`: `fullHeight` prop 추가(헤더 고정 + 콘텐츠 스크롤 + 하단 입력 고정).
- `src/pages/SettingsFeedback.tsx`: 오프라인 배너(`WifiOff`) + 버블 목록 + 하단 고정 입력창 구조.
- `src/components/FeedbackItem.tsx`: 상태별 버블 스타일, 상대 시간·상태 pill, `toDateKey()` 헬퍼 export.
- `src/components/FeedbackList.tsx`: 최신순 응답을 reverse, 날짜 바뀌는 지점에 `DateDivider`, 스켈레톤·빈 상태·에러 처리.
- `src/components/FeedbackForm.tsx`: 글자수 카운터(0/500), 전송 실패 인라인 에러 + 재시도, 성공 시 목록 캐시 무효화, 오프라인 비활성.
- `be-api-docs.json`에 `/feedback`, `/feedback/me` 스펙 추가.

## 근본 원인 (확정)
임시 404 fallback이 남아 있었다. 함께 발견한 버그: 날짜 구분선이 ISO 문자열 앞 10자(UTC 기준)를 날짜 키로 써서 KST 자정 전후 9시간 동안 날짜가 어긋났다. `toDateKey()`가 `getFullYear`/`getMonth`/`getDate` 로컬 메서드를 쓰도록 수정.

## 재발 방지
검증 항목(원본): 제출 → 자동 refetch → 새 버블, 상태별 색상·pill, 오프라인 배너·입력 비활성, UTC 00:00 = KST 09:00 전후 구분선 정확성.

## 교훈
(원본에 없음, 볼트 정리) 날짜 키를 ISO 문자열 슬라이스로 만들면 UTC 기준이 된다 — 로컬 날짜 비교는 로컬 메서드로.
