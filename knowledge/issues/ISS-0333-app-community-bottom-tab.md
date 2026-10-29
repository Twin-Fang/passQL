---
type: issue
id: ISS-0333
created: 2026-10-18
topics: [community]
symptoms: [토론 접근성 낮음, 설정 안 내 의견, 하단 탭 토론 없음]
root_cause: "앱에서 커뮤니티(토론)는 설정 안의 \"내 의견\" 항목으로만 들어갈 수 있었다"
status: resolved
resolution: "[[ISS-0333-app-community-bottom-tab-report]]"
related: ["[[DEC-0157-community-bottom-tab]]"]
source: "https://github.com/Twin-Fang/passQL/issues/543"
---

# ISS-0333: 앱 하단 내비게이션에 토론 탭 추가

GitHub #543 (원본: 이슈 본문과 댓글).

## 증상
커뮤니티(토론)가 앱에서는 설정 안의 "내 의견" 항목으로만 들어갈 수 있어 접근성이 낮다. 웹은 이미 하단 탭에 "토론"이 있다.

## 재현 조건
앱에서 토론 피드로 가려면 설정 > 내 의견.

## 조사 기록
- 2026-10-26: 리포트 — v1.25.0에 처음 반영(`e341b6b1`).

## 근본 원인
이슈 본문 서술 그대로.
