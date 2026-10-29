---
type: completion-report
id: ISS-0282
created: 2026-10-15
topics: [ops-infra]
status: resolved
resolves: "[[ISS-0282-json-logs-rotation-activity-events]]"
related: ["[[DEC-0128-prod-json-logs-activity-events]]"]
source: "https://github.com/Twin-Fang/passQL/issues/476"
---

# ISS-0282 완료 리포트: prod JSON 로그, `json-file` 로그 드라이버 로테이션, `MemberActivityLogger`

GitHub #476 구현 보고서 댓글 기준 (1차 통합 main `0bc1ed5`, 서버 0.11.0).

## 해결 방법
- `logback-spring.xml`: prod는 JSON 한 줄(`rid`, `mid` 포함), 그 외 프로필은 기존 패턴.
- 배포 워크플로 `docker run`에 `--log-driver json-file --log-opt max-size=20m --log-opt max-file=5`.
- `MemberActivityLogger`: 행동 이벤트 6종 공통 지점(`login`, `answer_submitted`, `daily_set_completed`, `question_reported`, `feedback_submitted`, `member_withdrawn`). 이메일·답안 원문·신고 상세·건의 본문은 남기지 않음.
- 검증: `LogFormatTest` 2건, 서버 전체 96개 중 95개 통과. 운영 컨테이너 로그 드라이버 `json-file`(max-size 20m, max-file 5)과 JSON 로그 출력 확인.

## 근본 원인 (확정)
이슈 본문과 같음.

## 재발 방지
주의(원본): NAS 기본 로그 드라이버가 `db`였다. `json-file`로 바뀌어 Container Manager 로그 탭에는 안 보일 수 있고 `docker logs`로는 그대로 본다. prod 로그가 JSON이라 평문 전제 grep은 `event=`, `rid` 필드 기준으로 바꿔야 한다.

## 교훈
(원본에 없음, 볼트 정리) 운영 로그를 찾을 때는 prod가 JSON 한 줄 형식이라는 점을 먼저 떠올리고 `rid`·`event` 필드로 거른다.
