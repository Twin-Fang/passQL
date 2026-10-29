---
type: issue
id: ISS-0249
created: 2026-10-08
topics: [ops-infra]
symptoms: [suh-logger 2.0.1, RESPONSE LOGGING, ANSI 색상 코드, "[rid|mid] 미적용", JUL 포맷터, System.out]
root_cause: "suh-logger 2.0.1이 요청 로그 블록을 자체 JUL 포맷터로 System.out에 직접 출력해 #436의 로그 설정이 적용되지 않음"
status: resolved
resolution: "[[ISS-0249-suh-logger-2-0-3-upgrade-report]]"
related: ["[[ISS-0248-ops-log-retention-request-trace]]"]
source: "https://github.com/Twin-Fang/passQL/issues/438"
---

# ISS-0249: suh-logger 요청 로그 블록에 ANSI가 남고 요청 ID가 붙지 않음

GitHub #438 (원본: 이슈 본문과 리포트 댓글).

## 증상
suh-logger 2.0.1의 `RESPONSE LOGGING` 블록에 GitHub #436 설정이 안 먹는다.
- `spring.output.ansi.enabled: never`가 적용되지 않아 ANSI 색상 코드가 남는다 (배포 후 10분 동안 6줄).
- `logging.pattern.level`의 `[rid|mid]`가 붙지 않아 같은 요청의 `[req]` 줄과 짝지을 수 없다.

## 재현 조건
suh-logger 2.0.1 사용 중 요청 로그 블록이 찍힐 때.

## 조사 기록
- 2026-10-08: suh-logger 2.0.3(2026-07-04)이 SLF4J 위임으로 전환됨을 확인 (Cassiiopeia/suh-logger#53).

## 근본 원인
frontmatter `root_cause`와 같음.
