---
type: decision
id: DEC-0234
created: 2026-11-01
reviewed: null
topics: [store-release]
status: active
supersedes: null
superseded_by: null
related: ["[[DEC-0233-store-images-accent-keyword-style]]", "[[ISS-0438-store-promo-images-v2]]", "[[ISS-0361-billing-switch-final-checks]]"]
---

# DEC-0234: 스토어 이미지에 PRO 표시를 넣지 않고, 유료 기능 안내는 설명 문구로 한다

## 문제 정의 (Context)
결제 스위치를 켜면 이미지에 나오는 일부 기능(SQL 실행, 실전 모드, 출제 경향 등)이 프로 전용이 된다. App Store 심사 기준 2.3.2는 유료 기능 안내를 요구한다 (GitHub #776, #576, #596).

## 결정 (Decision)
- 이미지에는 PRO 표시를 넣지 않는다. 앱의 PRO 칩과 이용권 줄도 찍히지 않도록 `SHOT_PLAN=off`로 촬영한다.
- 결제 스위치를 켤 때 스토어 설명 문구에 무료, 프로 구분을 반드시 함께 추가한다.

## 검토한 대안 (Alternatives)
논의 기록 없음.

## 결과 (Consequences)
**긍정**
- 결제 스위치를 켜도 이미지를 다시 만들 필요가 없다.

**부정**
- 스위치 작업에서 설명 문구 수정을 빠뜨리면 심사 기준 2.3.2 대응이 비게 된다.

## 영향 범위 (Scope)
`app/docs/store/descriptions/`, `app/docs/store/README.md`, `app/tool/store_shots/capture_store_set.sh`, 결제 스위치 작업(#596).

## 출처 (References)
- GitHub #776 이슈 본문, 리포트 댓글 6557293292 (2026-11-01)
