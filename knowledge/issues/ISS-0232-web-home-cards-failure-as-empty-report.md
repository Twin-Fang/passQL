---
type: completion-report
id: ISS-0232
created: 2026-10-07
topics: [home]
status: resolved
resolves: "[[ISS-0232-web-home-cards-failure-as-empty]]"
related: []
source: "https://github.com/Twin-Fang/passQL/issues/399"
---

# ISS-0232 완료 리포트: 일정·데일리 카드에 로딩 스켈레톤과 "불러오지 못했어요" + 재시도

GitHub #399 완료 댓글 기준 (PR #407, 운영 v0.0.247). `## 개요` 형식 리포트는 없음.

## 해결 방법
시험 일정·데일리 세트 카드: 로딩 스켈레톤 / "불러오지 못했어요" + 재시도. 빈 응답(200)은 기존처럼 "선택된 일정 없음".

## 근본 원인 (확정)
실패와 빈 응답을 구분하지 않았다.

## 재발 방지
API 500을 연출한 로컬 프리뷰 캡처로 확인. 실제 로그인 상태의 운영 화면은 자격증명이 없어 연출로 대체했다(원본). 인사말 처리 결과는 원본에 적혀 있지 않다.

## 교훈
(원본에 없음, 볼트 정리) 같은 문제가 앱(GitHub #375)과 웹(GitHub #399)에 따로 있었다. 한쪽 플랫폼을 고치면 다른 쪽도 확인한다.
