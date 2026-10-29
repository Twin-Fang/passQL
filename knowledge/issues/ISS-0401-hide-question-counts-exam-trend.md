---
type: issue
id: ISS-0401
created: 2026-10-25
topics: [question-bank, store-release]
symptoms: ["최신 경향 화면", "문제 총 N개", "250문항", "문항 수 노출", "표본 크기 노출"]
root_cause: "최신 경향 화면(앱·웹)과 서버 콘텐츠 JSON이 문제 보유량·표본 크기를 표시했다"
status: resolved
resolution: "[[ISS-0401-hide-question-counts-exam-trend-report]]"
related: ["[[ISS-0397-promo-site-overhaul-operator-notice]]"]
source: "https://github.com/Twin-Fang/passQL/issues/660"
---

# ISS-0401: 최신 경향 화면에서 문제 수·표본 크기 숨기기

GitHub #660 (원본: 이슈 본문과 댓글).

## 증상
최신 경향 화면이 문제 보유량·표본 크기를 보여 준다. 이슈 본문은 "문제량은 어디에도 노출하지 않는 방침과 어긋난다"고 적었다.
- 머리 카드: `최신 경향 문제 총 N개`
- 분석 근거 문구: `제58~62회 복원 250문항과 …`
- 과목별 비중: `10문항 · 20%`

## 재현 조건
앱·웹 최신 경향 화면 진입.

## 조사 기록
- 범위 밖(이슈 본문): 실제 시험 회차별 출제 문항 수 같은 시험 통계 문구는 유지.
- 2026-10-26: PR #661(화면), PR #662(스토어 홍보 이미지 2번)로 수정.

## 근본 원인
화면과 콘텐츠 JSON이 보유량 수치를 그대로 노출했다. 방침 자체가 정해진 이슈는 원본에 적혀 있지 않다(GitHub #636을 참조함).
