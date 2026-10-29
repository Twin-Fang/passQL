---
type: issue
id: ISS-0275
created: 2026-10-15
topics: [admin]
symptoms: [JPA auditor system 고정, 변경 이력 없음, 약관 본문 덮어씀, admin_audit_log, 제재 처리 관리자 미기록]
root_cause: "JPA auditor가 항상 `system`으로 고정이고 설정·약관·문제·제재 변경 이력을 남기는 곳이 없었으며 약관은 이전 본문을 덮어썼다"
status: resolved
resolution: "[[ISS-0275-admin-audit-log-legal-history-report]]"
related: []
source: "https://github.com/Twin-Fang/passQL/issues/469"
---

# ISS-0275: 관리자 변경에 누가 언제 무엇을 바꿨는지 남지 않음

GitHub #469 (원본: 이슈 본문과 구현 보고서).

## 증상
- JPA auditor가 항상 `system`으로 고정
- 설정, 약관, 문제, 제재 변경에 누가 언제 무엇을 바꿨는지 남지 않음. 약관은 이전 본문을 덮어씀

## 재현 조건
해당 없음 (기능 부재). 관련 위치: `server/PQL-Web/.../config/JpaConfig.java:15`, `AppSettingService.save`, `LegalService.update`, `MemberSuspendHistory`.

## 조사 기록
- 2026-10-15: 제안 — auditor를 로그인한 관리자 이름으로, `admin_audit_log`(관리자·대상·동작·변경 전후 값·IP·시각)와 조회 화면, 약관 버전 이력, 제재 이력에 처리 관리자.

## 근본 원인
frontmatter `root_cause`와 같음.
