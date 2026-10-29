---
type: completion-report
id: ISS-0313
created: 2026-10-16
topics: [question-bank, practice]
status: resolved
resolves: "[[ISS-0313-sqld-2026-trend-curated-choices]]"
related: ["[[DEC-0141-curated-only-oracle-verified-choices]]", "[[DEC-0142-encrypt-sqld-research-materials]]"]
source: "https://github.com/Twin-Fang/passQL/issues/511"
---

# ISS-0313 완료 리포트: `CURATED_ONLY` 고정 보기, 로컬 Oracle 검증 하네스, 조사 자료 암호화

GitHub #511 보고 댓글 기준 (2026-10-16 개요, 2026-10-17 후속 3건).

## 해결 방법
- 서버: `ChoiceSetResolver`가 `CURATED_ONLY`면 실행 모드보다 먼저 분기해 관리자 고정 세트(`ADMIN_SEED`·`ADMIN_CURATED`, OK)를 실전·연습 모두 그대로 출제, AI 호출·프리페치 소비 없음. 고정 세트가 없으면 기존 AI 경로로 대체하고 warn 로그. `ChoiceOrderShuffler`·`QuestionService`가 풀이 응답에서만 순서를 섞고 순번 1..N 재부여(DB·채점 `choiceKey` 그대로). `PrefetchService`는 CURATED_ONLY면 프리페치 생략. `CuratedChoiceSetWriter`, `ChoiceExplanationService`(고정 세트 해설은 AI 생성·덮어쓰기 안 함).
- 가져오기: `QuestionExportDto`에 `choices`, `CuratedChoiceValidator`(보기 4개, 정답 1개 등)를 검증·등록 단계 모두에서 검사. 관리자 직접 등록에서는 `CURATED_ONLY` 차단(옵션 제거 + 400).
- 하네스 `tools/sqld-question-harness/`: 문제 YAML을 Oracle Free 컨테이너의 문제별 격리 스키마에서 실행, 통과한 문제만 가져오기 JSON 생성.
- 운영 반영: 비활성화 23개(중복 개념형 21, `WITH RECURSIVE` 1, 정답 오류 `8eefc3e3` 1, 플래그만 꺼서 복구 가능), 신규 누적 37문항(1차 8 + 2차 15 + 3차 14).
- 후속: `V0_10_52__drop_member_auth_provider_default.sql`로 `member.auth_provider` 기본값 `'ANONYMOUS'` 제거(V0_0_155에서 ANONYMOUS 정리 후 enum에서 빠져 있어 공급자 없는 행 조회 시 500). 운영 적용 확인.

## 근본 원인 (확정)
이슈 노트와 같음. 하네스는 `8eefc3e3` 같은 정답 표시 오류와 정답 2개 문제를 FAIL로 걸러냄을 확인.

## 재발 방지
- 고정 세트 판정은 "정책 + 출처"를 함께 본다(`QuestionService.isCuratedChoiceSet` 한 곳). 출처만 보면 AI_ONLY 시드 세트까지 섞인다.
- `ChoiceExplanationService`의 고정 세트 분기를 없애면 검증 해설이 AI 해설로 영구히 덮어써진다.
- CURATED_ONLY 문제는 JSON 가져오기로만 등록하고, 하네스 출력은 `CONCEPT_ONLY` + `CURATED_ONLY`.
- 실측(로컬, 운영과 같은 main 코드): 연습·실전 회원 모두 `ADMIN_CURATED` 세트 반환, 6회 조회마다 순서가 섞임, 서버 로그 `[resolver] curated HIT` 3회, AI 보기 생성 0회.
- 보류: 리뷰 Minor 8건(웹 상세 재조회 시 재셔플, 동시 가져오기 시 OK 세트 2개 가능, 내보내기 N+1 등). 앱 보기 라벨은 GitHub #512로 분리.

## 교훈
(원본에 없음, 볼트 정리) 샌드박스 엔진과 다른 문법(Oracle)의 계산형 문제는 AI 실시간 생성 보기에 맡기지 말고, 실제 엔진에서 실행 검증한 고정 보기로 낸다.
