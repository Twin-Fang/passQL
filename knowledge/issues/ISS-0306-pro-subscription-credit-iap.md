---
type: issue
id: ISS-0306
created: 2026-10-16
topics: [billing]
symptoms: [인앱 결제 없음, Pro 구독, 크레딧 구매, 관리자 부여만 가능]
root_cause: "취소로 닫힘 — 기간제 이용권 결정으로 대체"
status: resolved
resolution: null
related: ["[[DEC-0001-pro-monthly-yearly-subscription]]"]
source: "https://github.com/Twin-Fang/passQL/issues/501"
---

# ISS-0306: Pro 구독과 크레딧 구매 인앱 결제 연동

GitHub #501 (원본: 이슈 본문과 댓글).

취소로 닫힘: 2026-10-23 결정(GitHub #578 댓글)으로 월간·연간 자동 갱신 구독·크레딧 대신 1개월·3개월 기간제 이용권(자동 갱신 없음)으로 정했고, 서버·Android는 GitHub #591로 반영·배포, iOS는 GitHub #578에서 진행. "이 이슈는 대체되어 취소로 닫는다."

## 증상
등급과 크레딧 구조(별도 이슈)를 먼저 만들고 Pro는 관리자 부여로 시작한다. 사용자가 직접 Pro를 구독하거나 크레딧을 살 수 없다.

제안: Pro 월간·연간 인앱 구독(App Store, Google Play), 크레딧 묶음 구매(소모성 상품), 서버 영수증 검증과 구독 갱신·해지·환불 반영(스토어 서버 알림), 구매 복원·구독 관리 화면 연결. 가격 결정은 사용자 결정 필요, 심사 제출은 별도 요청 시에만.

## 재현 조건
해당 없음 (기능 요청).

## 조사 기록
- 2026-10-16: 이슈 등록. 등급·크레딧 이슈 완료 후 진행 예정.
- 2026-10-23: 대체로 취소.

## 근본 원인
해당 없음 (기능 요청). 계획 내용은 [[DEC-0001-pro-monthly-yearly-subscription]].
