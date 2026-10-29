---
type: issue
id: ISS-0383
created: 2026-10-24
topics: ["admin", "community"]
symptoms: ["건의사항 검색 없음", "건의사항 일괄 상태 변경", "회원 UUID 노출", "feedbacks.html", "건의 답변 알림"]
root_cause: "관리자 화면에 해당 운영 기능이 없었다"
status: resolved
resolution: null
related: ["[[ISS-0366-admin-question-quality-metrics-report]]"]
source: "https://github.com/Twin-Fang/passQL/issues/628"
---

# ISS-0383: 관리자 건의사항 검색·일괄 상태 변경·답변이 없고 회원이 UUID로만 보임

GitHub #628 (원본: 이슈 본문; 완료 내용은 GitHub #611 통합 리포트 댓글).

## 증상
건의사항 검색(내용·기간·회원)과 일괄 상태 변경이 없다. 회원 UUID가 그대로 노출돼 닉네임으로 식별이 안 된다(`feedbacks.html:44`). 회원에게 답변·알림을 보낼 수 없다.

## 재현 조건
해당 없음 (기능 이슈).

## 조사 기록
- 2026-10-24: 관리자 화면만으로 운영(DB 직접 조회 없이)하기 위한 관리자 개선 묶음(GitHub #611~#631) 중 하나로 등록. 공통 조건: 관리자 변경 작업은 기존 `AdminAuditLogService`로 감사 로그, 서버 API 변경 시 `api-contract/openapi.json` 갱신까지 한 커밋.
- 작업 범위: 내용 키워드·기간·회원 검색·일괄 상태 변경, 회원 닉네임 표시와 회원 상세 링크, 답변 작성 후 알림함 전달, CSV 내보내기.
- 2026-10-24: GitHub #611 통합 구현 보고서(PR #634, 운영 배포) 결과 — 건의사항 검색, 일괄 상태 변경, 답변 알림 완료. CSV 내보내기는 #612 남은 일(목록 화면 CSV 적용)에 건의 목록이 포함돼 있다. 이 이슈 자체에는 완료 댓글이 없어 완료 리포트는 #611 쪽에 있다.

## 근본 원인
기능 이슈. 해당 기능이 없었다(원본 「현재 문제점」 기준). 코드상 원인은 원본에 적혀 있지 않다.
