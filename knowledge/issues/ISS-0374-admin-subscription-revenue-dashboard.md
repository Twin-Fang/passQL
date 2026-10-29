---
type: issue
id: ISS-0374
created: 2026-10-24
topics: ["admin", "billing"]
symptoms: ["매출 현황 항상 0", "구매 금액 통화 비어 있음", "StorePurchaseRecorder", "PRO 회원 수", "부여 회수 사유", "play order price unavailable"]
root_cause: "구매 기록 코드가 스토어 결제 금액·통화를 저장하지 않아 매출 현황이 항상 0이었다"
status: resolved
resolution: "[[ISS-0374-admin-subscription-revenue-dashboard-report]]"
related: ["[[ISS-0366-admin-question-quality-metrics-report]]", "[[DEC-0175-record-store-paid-amount-nonblocking]]"]
source: "https://github.com/Twin-Fang/passQL/issues/619"
---

# ISS-0374: 관리자에 구독·매출 현황이 없고, 구매 기록에 금액·통화가 저장되지 않음

GitHub #619 (원본: 이슈 본문, GitHub #611 통합 리포트, 2026-10-26 완료 리포트 댓글).

## 증상
PRO 회원 수, 만료 임박, 매출·전환율을 볼 곳이 없다. 회원 목록에 PRO 필터가 없고 구매 금액·통화 표시가 없다. 이용권 부여·회수 시 사유 입력이 없어 감사 로그에 이유가 남지 않는다. #611 통합 구현 뒤에도 구매 금액·통화 값이 비어 매출 현황이 항상 0이었다.

## 재현 조건
해당 없음 (기능 이슈). 금액 미기록은 구매 확인 시 기록 코드가 금액·통화를 저장하지 않아 모든 구매 행에서 발생(2026-10-26 리포트 기준).

## 조사 기록
- 2026-10-24: 관리자 화면만으로 운영(DB 직접 조회 없이)하기 위한 관리자 개선 묶음(GitHub #611~#631) 중 하나로 등록. 공통 조건: 관리자 변경 작업은 기존 `AdminAuditLogService`로 감사 로그, 서버 API 변경 시 `api-contract/openapi.json` 갱신까지 한 커밋.
- 작업 범위: 구독·매출 현황 화면(PRO 수, 7일 내 만료, 환불·회수 건수, 상품별 판매량, 무료>PRO 전환율), 회원 목록 PRO·만료 임박 필터, 구매 이력 금액·통화 컬럼, 부여·회수 사유 입력과 감사 로그 반영, 이용권 변동 타임라인.
- 2026-10-24: GitHub #611 통합 리포트(PR #634) — 구독·매출 화면, 부여·회수 사유, 변동 타임라인은 들어갔으나 "일부: 구매 금액·통화 값이 비어 있음". 남은 일로 "Play·App Store 검증 응답의 가격을 `StorePurchaseRecorder`에서 저장".
- 2026-10-26: 완료 리포트(PR #665, 릴리스 #666).

## 근본 원인
구매 이력에 금액·통화 칸과 관리자 표시는 있었지만, 실제 구매를 기록하는 코드가 값을 저장하지 않았다(2026-10-26 리포트).
