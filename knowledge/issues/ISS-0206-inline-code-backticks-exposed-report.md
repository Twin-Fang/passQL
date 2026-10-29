---
type: completion-report
id: ISS-0206
created: 2026-10-07
topics: [practice]
status: resolved
resolves: "[[ISS-0206-inline-code-backticks-exposed]]"
related: []
source: "https://github.com/Twin-Fang/passQL/issues/361"
---

# ISS-0206 완료 리포트: `InlineCodeText`로 백틱 숨김·배경 강조

GitHub #361 완료 댓글 기준 (2026-10-07). `## 개요` 형식 리포트는 없음.

## 해결 방법
- `InlineCodeText`: 백틱 구간의 백틱을 숨기고 배경 강조 (지문·선택지 적용).
- 목록 미리보기(홈 추천·오답 노트·비슷한 문제)는 백틱 제거.
- 지문 카드를 전체 폭으로.

## 근본 원인 (확정)
인라인 코드 처리 부재.

## 재발 방지
테스트 6건 통과(인라인 백틱 케이스 포함), `flutter analyze` 새 경고 없음.

## 교훈
(원본에 없음, 볼트 정리) 코드 펜스와 인라인 백틱은 별도 처리다 — 하나를 고칠 때 다른 하나도 확인한다.
