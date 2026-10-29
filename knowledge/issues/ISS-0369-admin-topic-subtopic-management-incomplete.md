---
type: issue
id: ISS-0369
created: 2026-10-24
topics: ["admin", "question-bank"]
symptoms: ["서브토픽 수정 버튼 동작 안 함", "topics.html", "서브토픽 PUT 없음", "토픽 삭제", "토픽 순서 변경"]
root_cause: "서브토픽 수정 버튼에 클릭 핸들러와 서버 PUT API가 없었다 (`topics.html:139-142`)"
status: resolved
resolution: null
related: ["[[ISS-0366-admin-question-quality-metrics-report]]"]
source: "https://github.com/Twin-Fang/passQL/issues/614"
---

# ISS-0369: 관리자 토픽·서브토픽 관리 미완성 — 서브토픽 수정 버튼이 동작하지 않음 (버그)

GitHub #614 (원본: 이슈 본문; 완료 내용은 GitHub #611 통합 리포트 댓글).

## 증상
서브토픽 수정 버튼이 핸들러·서버 PUT 없이 동작하지 않는다(`topics.html:139-142`). 토픽·서브토픽 삭제와 순서 변경이 없다.

## 재현 조건
관리자 토픽 화면에서 서브토픽 수정 버튼 클릭 → 아무 동작 없음(원본 서술 기준).

## 조사 기록
- 2026-10-24: 관리자 화면만으로 운영(DB 직접 조회 없이)하기 위한 관리자 개선 묶음(GitHub #611~#631) 중 하나로 등록. 공통 조건: 관리자 변경 작업은 기존 `AdminAuditLogService`로 감사 로그, 서버 API 변경 시 `api-contract/openapi.json` 갱신까지 한 커밋.
- 작업 범위: 서브토픽 수정 PUT API와 버튼 연결, 토픽·서브토픽 삭제(소속 문제가 있으면 막고 안내), 순서 변경, 토픽별 문제 수 표시.
- 2026-10-24: GitHub #611 통합 구현 보고서(PR #634, 운영 배포) 결과 — 서브토픽 수정 버튼 복구, 삭제, 순서 변경, 문제 수 완료. 이 이슈 자체에는 완료 댓글이 없어 완료 리포트는 #611 쪽에 있다.

## 근본 원인
서브토픽 수정 버튼에 핸들러와 서버 PUT API가 없었다(`topics.html:139-142`, 원본 「현재 문제점」). 그 밖의 원인 설명은 원본에 적혀 있지 않다.
