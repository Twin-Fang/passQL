---
type: issue
id: ISS-0011
created: 2026-04-07
topics: [dev-workflow, design-system]
symptoms: ["화면 명세", "API 매핑", "디자인 시안 변형", 컷오프, "하단 탭 불일치"]
root_cause: "디자인 시안 변형이 많고 화면-API 계약과 FE/BE 책임이 명문화되지 않았다 (문서 이슈)"
status: resolved
resolution: null
related: ["[[DEC-0017-fullscreen-result-screen]]", "[[DEC-0018-four-tab-bottom-navigation]]", "[[DEC-0015-zero-business-logic-in-frontend]]", "[[DEC-0016-auto-execute-on-choice-click]]"]
source: "https://github.com/Twin-Fang/passQL/issues/8"
---

# ISS-0011: 전체 화면 명세 및 API 매핑

GitHub #8 (원본: 이슈 본문. 댓글 없음).

## 증상
공유된 디자인 시안 9장의 변형이 많았다 — 하단 탭 구성이 화면마다 다르고, 결과 화면이 3가지 스타일, 일부는 PRD 범위 밖 요소 포함. FE/BE가 같은 화면-API 계약을 공유해야 병렬 작업이 가능했고, 화면별 API 호출 시점과 FE/BE 책임이 명문화되지 않았다.
본문 내용: 구현 화면 6개 확정(홈, 문제 목록, 문제 상세, 결과 풀스크린, 통계, 설정), API 15개(P0 13 / P1 2), 컷오프 14개와 사유, 핵심 원칙 4개(비즈니스 로직 제로, 선택지 자동 실행, 결과 화면 풀스크린, 4탭). 상세 명세는 `.report/20260407_프론트_화면_명세_및_API_매핑.md`에 보관한다고 적었다.
컷오프 표의 "사이드바 데스크탑 — 모바일 우선 단일"은 이후 GitHub #9에서 Desktop 사이드바가 구현되었다 (원본 기록 그대로).

## 재현 조건
해당 없음 (문서 이슈).

## 조사 기록
- 댓글 없음.

## 근본 원인
해당 없음 (문서 이슈).
