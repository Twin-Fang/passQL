---
type: issue
id: ISS-0405
created: 2026-10-26
topics: [home, ops-infra]
symptoms: ["홈 스켈레톤 3.5~4초", "홈 첫 로딩 느림", homeDataProvider, homeRecommendationsProvider, "추천 문제 직렬 대기", "요청 워터폴"]
root_cause: "홈이 세 묶음 모두 도착해야 그려졌고, 추천 문제는 등급 확인 뒤 요청하는 2단계 직렬 구조라 가장 늦어 홈 전체를 붙잡았다"
status: resolved
resolution: "[[ISS-0405-home-first-load-skeleton-wait-report]]"
related: ["[[DEC-0182-home-not-wait-recommendations]]"]
source: "https://github.com/Twin-Fang/passQL/issues/676"
---

# ISS-0405: 홈 첫 로딩 대기 시간 단축 — 지난 데이터 먼저 보여 주기

GitHub #676 (원본: 이슈 본문과 댓글).

## 증상
앱을 켜면 홈 화면이 3.5~4초 동안 스켈레톤으로만 보인다. 어떤 내용이 오는지, 얼마나 기다려야 하는지 알 수 없다.

## 재현 조건
앱 시작 후 홈 진입. 기기에 저장된 홈 데이터가 없어 매번 빈 상태에서 시작.

## 조사 기록
- 이슈 본문 원인 1: 홈은 인사말·시험 일정 / 진행 현황·오늘의 세트·히트맵 / 추천 문제 세 묶음이 **모두** 도착해야 그려진다. 추천은 등급 확인 뒤 요청하는 2단계 직렬 구조.
- 원인 2: 기기에 저장해 둔 홈 데이터가 없다.
- 제안: 1단계 먼저 도착한 섹션부터 그리기, 2단계 Stale-While-Revalidate(회원별 저장, 로그아웃·계정 전환 시 삭제).
- 2026-10-26 리포트: 1단계만 반영. 홈 내용 표시 평균 2476ms → 191ms(-92%, iPhone 16 Pro 시뮬레이터 디버그 빌드, 운영 API, 핫 리스타트 10회). 추천 표시까지는 2500ms → 2626ms로 그대로(오차 범위).

## 근본 원인
맨 아래 추천 섹션의 직렬 요청이 홈 첫 표시 조건에 묶여 있었다(리포트).
