---
type: completion-report
id: ISS-0275
created: 2026-10-15
topics: [admin]
status: resolved
resolves: "[[ISS-0275-admin-audit-log-legal-history]]"
related: []
source: "https://github.com/Twin-Fang/passQL/issues/469"
---

# ISS-0275 완료 리포트: `AdminAuditEvent` → 커밋 후 `admin_audit_log`, 약관 `legal_history`

GitHub #469 구현 보고서(2026-10-15) 기준. 3차 통합 main `c46b9e6`(0.13.0).

## 해결 방법
- JPA auditor: 관리자 세션이면 관리자 아이디, 그 외(회원 API, 스케줄러)는 `system`.
- 기록 공통 지점 하나: 서비스가 `AdminAuditEvent` 발행 → `AdminAuditLogService`가 커밋 후 별도 트랜잭션으로 `admin_audit_log` 저장(롤백된 변경은 남지 않고, 기록 실패가 원래 요청에 영향 없음).
- 대상: 문제(등록·수정·비활성화·복구·가져오기), 선택지, 토픽, 앱 설정(민감 키 마스킹), 약관, 회원 제재·해제·탈퇴, 신고 처리·기각, 건의, 프롬프트, 시험 일정, 개념 문서, 일일 챌린지, 관리자 계정, 앱 공지.
- 조회 화면 `/admin/audit-logs`(관리자·대상 종류·기간 필터, 페이지네이션). 약관 수정 시 이전 본문을 `legal_history`에 보관(최근 20건 열람). 제재 이력에 `acted_by_admin_username`, 자동 해제는 `system`. 마이그레이션 `V0_10_11`.

## 근본 원인 (확정)
이슈 노트와 같음.

## 재발 방지
검증: `AdminAuditRecordTest`, 서버 108개 중 107개 통과(기존 dev DB 외래키 테스트 1개 실패), 배포 run `38820038302`, 운영 감사 로그 화면 200·콘솔 오류 0.

## 교훈
원본에 적혀 있지 않다.
