---
type: completion-report
id: ISS-0336
created: 2026-10-20
topics: [question-bank]
status: resolved
resolves: "[[ISS-0336-sqld-2026-trend-question-pool-refresh]]"
related: ["[[DEC-0158-new-questions-concept-only-curated]]"]
source: "https://github.com/Twin-Fang/passQL/issues/548"
---

# ISS-0336 완료 리포트: 신규 143문제 등록, 기존 32문제 수정, 40문제 비활성화

GitHub #548 리포트 댓글(`## 개요`)과 운영 반영 결과 댓글(2026-10-20) 기준.

## 해결 방법
- 경향 정리·유형 목록(암호화본)에 새 템플릿 12개(T29~T40): 서브쿼리 연산자, 제약조건 아래 DML 성공 판정, GROUP BY/HAVING 결과 해석 등. 정답이 확정되지 않은 문항은 원 정답을 쓰지 않고 주제만 쓴다.
- 문제 묶음: batch04a(22), batch04b(27), batch04c(29), batch04d(28), batch04e(37), batch05(기존 수정본 32 — 정답 오류 9, 개선 23, 기존 UUID 유지).
- 신규는 모두 `CONCEPT_ONLY` + `CURATED_ONLY`(고정 보기)로 등록 — [[DEC-0158-new-questions-concept-only-curated]].
- 관리자 API(`/admin/questions/import`, `/admin/questions/bulk`, `/admin/questions/latest-trend`)로 운영 반영:
  - 백업: 반영 전 활성 206건 (`docs/sqld-research/audit/backup-production-before-548.json`, 암호화본 커밋)
  - 신규 143건 등록(검증 실패 0), 기존 32건 갱신(내보내기 대조 불일치 0), 감사 RETIRE 40건 비활성화(중복·범위 밖·복구 불가, 회원 기록 보존), 최신 경향 158건 지정(신규 126 + 수정 32)
  - 반영 후 활성 309건 (보기 고정 212, AI 보기 55, 결과 비교 24, 다른 하나 18)
- 서버 `sqld-latest-trend.json`의 출제 경향 화면 문구 갱신. PR #556 병합 후 배포.

## 근본 원인 (확정)
원본에 별도 원인 서술은 없다. 이슈 본문의 "경향 근거가 얕았다"가 출발점이다.

## 재발 방지
- 검증 도구 Oracle verify: 묶음별 전부 통과. GitHub #559에서 XE 21c로 전체 재검증 통과.
- 같은 UUID로 다시 가져오면 고정 보기 세트가 통째로 교체된다. 수정본을 다시 올릴 때는 최신 YAML에서 내보낸 JSON을 쓴다. 되돌릴 때는 백업 JSON을 같은 API로 넣는다(수정 32건 복원, 신규·비활성화분은 UUID로 처리).
- 배포는 main을 `deploy`에 병합해 push하는 방식(develop 없음). 운영 컨테이너(1.26.0, healthy) jar 안의 경향 JSON을 직접 확인.

## 교훈
(원본에 없음, 볼트 정리) 문제 풀을 대량 수정하기 전에는 운영 활성 문제를 백업 JSON으로 내보내 두고, 기존 문제는 UUID를 유지해 풀이 기록을 보존한다.
