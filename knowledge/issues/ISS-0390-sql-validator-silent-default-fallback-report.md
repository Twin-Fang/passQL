---
type: completion-report
id: ISS-0390
created: 2026-10-24
topics: ["practice", "ops-infra"]
status: resolved
resolves: "[[ISS-0390-sql-validator-silent-default-fallback]]"
related: []
source: "https://github.com/Twin-Fang/passQL/issues/640"
---

# ISS-0390 완료 리포트: 설정 조회 실패 시 경고 로그 한 줄 추가 (기본값 대체 동작 유지)

GitHub #640 완료 리포트 댓글(2026-10-24) 기준. PR #641, 서버 배포(run 40090643182 성공, 헬스 200).

## 해결 방법
`SqlSafetyValidator.java`: `@Slf4j` 추가, `catch`에서 `[sql validate] max length setting unavailable, using default : default=2000, cause=<예외 종류>` 경고. 예외 원문 메시지는 남기지 않음. 기본값 대체 동작은 그대로.

## 근본 원인 (확정)
`catch`가 로그 없이 기본값(2000)을 반환해 설정 저장소 장애가 운영에서 보이지 않았다.

## 재발 방지
컴파일 성공. 로그 문구는 설정 저장소가 실제로 깨져야 나오므로 운영에서 실측하지 못함.

## 교훈
(원본에 없음, 볼트 정리) SQL 길이 제한이 예상과 다르게 동작하면 서버 로그에서 `max length setting unavailable`부터 찾는다.
