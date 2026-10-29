---
type: decision
id: DEC-0128
created: 2026-10-15
reviewed: null
topics: [ops-infra]
status: active
supersedes: null
superseded_by: null
related: ["[[ISS-0282-json-logs-rotation-activity-events]]"]
---

# DEC-0128: prod 로그는 JSON 한 줄, Docker `json-file` 20m×5 로테이션, 회원 행동 이벤트는 개인 내용 없이 6종

## 문제 정의 (Context)
운영 로그가 사람이 읽는 평문뿐이고, Docker 로그 크기 제한이 없었고, 회원 행동 기록이 없었다 (GitHub #476).

## 결정 (Decision)
- prod 프로필은 `logback-spring.xml`로 JSON 한 줄(`rid`, `mid` 포함). 그 외 프로필은 기존 패턴.
- 배포 `docker run`: `--log-driver json-file --log-opt max-size=20m --log-opt max-file=5`.
- 회원 행동 이벤트는 `MemberActivityLogger` 한 곳에서 6종(`login`, `answer_submitted`, `daily_set_completed`, `question_reported`, `feedback_submitted`, `member_withdrawn`)만. 이메일·답안 원문·신고 상세·건의 본문은 남기지 않는다.

## 검토한 대안 (Alternatives)
논의 기록 없음.

## 결과 (Consequences)
**긍정**
- 로그 크기 상한, 필드 단위 검색, 행동 이벤트 추적.

**부정**
- NAS 기본 드라이버 `db`에서 바뀌어 Container Manager 로그 탭에 안 보일 수 있다.
- 평문 전제 grep 습관을 `event=`, `rid` 필드 기준으로 바꿔야 한다.

## 영향 범위 (Scope)
`server/PQL-Web/src/main/resources/logback-spring.xml`, `PROJECT-SPRING-SYNOLOGY-PASSQL-CICD.yaml`의 `docker run`, `MemberActivityLogger` 호출 지점(로그인·제출·세트 완료·신고·건의·탈퇴).

## 출처 (References)
- GitHub #476 이슈 본문, 구현 보고서 댓글(2026-10-15)
- [[ISS-0282-json-logs-rotation-activity-events]]
