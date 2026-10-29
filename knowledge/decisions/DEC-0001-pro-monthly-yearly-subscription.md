---
type: decision
id: DEC-0001
created: 2026-10-16
reviewed: null
topics: [billing]
status: superseded
supersedes: null
superseded_by: DEC-0002
related: []
---

# DEC-0001: Pro를 월간·연간 인앱 구독 + 크레딧 묶음 구매로 판다 (계획)

## 문제 정의 (Context)
등급과 크레딧 구조(#498)를 먼저 만들고 Pro는 관리자 부여로 시작했다. 사용자가 직접 Pro를 구독하거나 크레딧을 살 수단이 없었다 (GitHub #501).

## 결정 (Decision)
Pro 월간·연간 구독(App Store, Google Play 인앱 구독)과 크레딧 묶음 구매(소모성 인앱 상품)를 붙인다. 서버 영수증 검증, 구독 갱신·해지·환불 반영, 구매 복원·구독 관리 화면 연결. 가격은 사용자 결정 필요로 남김.

## 검토한 대안 (Alternatives)
논의 기록 없음.

## 결과 (Consequences)
**긍정**
- 논의 기록 없음

**부정**
- 논의 기록 없음

## 영향 범위 (Scope)
스토어 상품, 서버 영수증 검증·스토어 서버 알림, 앱 구매 화면. 구현되지 않았다.

## 출처 (References)
- GitHub #501 (이슈 본문, 2026-10-23 마지막 댓글: 이 결정으로 대체되어 취소로 닫음)
- #501 마지막 댓글은 이 계획이 2026-10-23 결정([[DEC-0003-one-and-three-month-pass]])으로 대체됐다고 적었다. #576(회차 패스, [[DEC-0002-exam-pass-until-next-sqld]])은 그 전인 2026-10-22에 나왔고, 원본에 #501과의 비교는 없다.
- 체인 메모: 템플릿은 대체 관계를 1:1로만 허용해 DEC-0001 → DEC-0002 → DEC-0003으로 이었다. 원본상 직접 대체 선언은 DEC-0001→DEC-0003, DEC-0002→DEC-0003 둘 다 2026-10-23이다.
