---
type: completion-report
id: ISS-0249
created: 2026-10-08
topics: [ops-infra]
status: resolved
resolves: "[[ISS-0249-suh-logger-2-0-3-upgrade]]"
related: ["[[ISS-0248-ops-log-retention-request-trace]]"]
source: "https://github.com/Twin-Fang/passQL/issues/438"
---

# ISS-0249 완료 리포트: suh-logger `2.0.1` → `2.0.3`, 요청 로그 블록 ANSI 0건

GitHub #438 `## 개요` 리포트 댓글 기준 (v0.3.1, PR #439).

## 해결 방법
`server/PQL-Common/build.gradle`: `kr.suhsaechan:suh-logger:2.0.1` → `2.0.3`. 의존성 버전만 올렸다.

## 근본 원인 (확정)
2.0.1은 출력을 SLF4J로 넘기지 않았다. 2.0.3은 SLF4J로 넘긴다(Cassiiopeia/suh-logger#53).

## 재발 방지
운영(v0.3.1, `passql-back-blue`)에서 `X-Request-Id: qa-438-check-01`로 확인: 요청 로그 블록 6줄 모두 `INFO [qa-438-check-01|-] …` 형식, 같은 요청 `[req]` 줄과 묶임, 배포 후 15분 ANSI 0건(전에는 6줄). 2.0.3에도 남은 문제는 Cassiiopeia/suh-logger#55(마스킹 기본 꺼짐), #56(요청 1건 6줄, 처리 시간·기본 제외 규칙 없음). passQL은 `exclude-patterns`로 인증 응답과 헬스체크를 계속 직접 제외해야 한다.

## 교훈
(원본에 없음, 볼트 정리) 로그 설정이 일부 블록에만 안 먹으면 그 블록이 로깅 프레임워크를 거치는지(직접 `System.out` 출력인지) 확인한다.
