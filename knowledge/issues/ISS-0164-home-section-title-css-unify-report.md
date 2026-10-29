---
type: completion-report
id: ISS-0164
created: 2026-04-26
topics: [home, design-system]
status: resolved
resolves: "[[ISS-0164-home-section-title-css-unify]]"
related: []
source: "https://github.com/Twin-Fang/passQL/issues/307"
---

# ISS-0164 완료 리포트: 섹션 타이틀을 `text-sm text-text-secondary`로 통일

GitHub #307 구현 완료 보고 댓글(2026-04-26) 기준. 커밋 `036ae56`.

## 해결 방법
- `text-secondary` → `text-text-secondary` 오타 수정 2곳(학습 현황, AI 추천문제 헤더).
- 오늘의 문제 완료/없음 상태 타이틀 `text-text-caption` → `text-text-secondary`.
- `progressError` 카드 구조 변경 + "합격 준비도" 제목 추가.
- 기준: 카드 내부 `<p>`, 독립 헤더 `<h2>` 모두 `text-sm text-text-secondary`.

## 근본 원인 (확정)
섹션마다 다른 클래스와 존재하지 않는 클래스(`text-secondary`) 사용, 에러 카드 제목 누락.

## 재발 방지
원본에 적혀 있지 않다(위 통일 기준 외).

## 교훈
(원본에 없음, 볼트 정리) 에러 상태 카드도 정상 카드와 같은 제목 구조를 갖는지 확인한다.
