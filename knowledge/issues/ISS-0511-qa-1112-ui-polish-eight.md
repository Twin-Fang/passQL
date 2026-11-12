---
type: issue
id: ISS-0511
created: 2026-11-12
topics: [design-system, practice, home, notification]
symptoms: ["환영해요 모달", "중요한 소식을 알려 드릴까요", "모의고사 순위 없음", "번개 아이콘 크레딧", "bolt_fill", "PK FK 글자", "★★★☆☆ 글자 별", "숫자 바로 표시", "과락 경고 상자", "노란 경고 상자"]
root_cause: "11/12 QA에서 나온 디자인 개선 요청 8건(결함 아님): 첫 실행 시트가 할 일·받는 알림을 보여 주지 못했고, 모의고사 결과에 내 위치가 없었으며, 크레딧 번개·글자 별·글자 PK FK·노란 과락 상자처럼 공통 부품을 거치지 않은 표시가 남아 있었다"
status: resolved
resolution: "[[ISS-0511-qa-1112-ui-polish-eight-report]]"
related: ["[[DEC-0301-mock-exam-ranking-first-attempt-top-percent]]", "[[DEC-0302-first-run-sheets-today-steps-notification-preview]]", "[[DEC-0303-display-parts-difficulty-stars-count-up-key-badge-cutoff]]", "[[ISS-0491-first-run-guide-home-next-step]]", "[[ISS-0493-first-launch-push-prompt-common-sense-fixes]]", "[[ISS-0507-credit-gem-3d-pro-asset]]"]
source: "https://github.com/Twin-Fang/passQL/issues/1041"
---

# ISS-0511: 11/12 QA UI 개선 8건 (환영 모달·알림 문구·모의고사 순위·크레딧 아이콘·PK FK·난이도 별·숫자 카운트업·과락 상자)

GitHub #1041. 원본 사본: `_sources/issues/ISS-0511-qa-1112-ui-polish-eight.md`(로컬).
11/12 QA(#999, #1035) 중 나온 UI 개선 요청. 요청 원문이 남아 있지 않아 이슈 본문에 항목별 **해석**을 함께 적었다. #945(첫 진입 소개·알림 안내)는 1·2번과 겹쳐 이 이슈에서 함께 처리.

## 증상
| # | 요청 | 지금 모습 |
|---|---|---|
| 1 | 환영해요 모달 | 홈 첫 진입 시트: 3D 그림 + `환영해요!` + 아이콘 3줄 + 시작하기, 무엇부터 할지 안 보임 |
| 2 | 알림 안내 문구 | `중요한 소식을 알려 드릴까요?` + 공지·점검이 첫 줄, 받는 이득이 안 보임 |
| 3 | 모의고사 순위 | 결과 화면에 내 점수만 있음 |
| 4 | 크레딧 아이콘 통일 | 3D 젬(#1013)과 번개(`bolt_fill`)가 섞여 있음 |
| 5 | PK·FK 표기 | 컬럼 이름 뒤 글자 `PK`·`FK` |
| 6 | 난이도 별 | 글자 `★★★☆☆`, 글꼴마다 모양·크기 다름 |
| 7 | 숫자 카운트업 | 점수·크레딧 숫자가 바로 찍힘 |
| 8 | 과락 상자 | 노란 경고 상자(삼각 아이콘), 오류처럼 보임 |

## 재현 조건
홈 첫 진입(환영 시트 > 알림 안내), 모의고사 결과·회차 목록 머리, 문제 지문 표, 홈 추천·프로필 통계·풀이 머리, 잠금화면 소개·온보딩.

## 조사 기록
- 2026-11-12: 항목별 2~3안 HTML 시안 댓글 게시, 추천안으로 바로 구현(사용자 위임, 사후 확인).
- 2026-11-13: PR #1042, 완료 보고서 댓글. 시뮬레이터 실측은 메모리 부족으로 못 함(브랜치 빌드로 확인 필요).

## 근본 원인
결함이 아니라 디자인 개선. 첫 실행 시트·알림 안내가 기능 나열에 그쳤고, 표시 요소 일부가 공통 부품(크레딧 아이콘·토큰) 밖에서 글자·경고색으로 그려져 있었다.
