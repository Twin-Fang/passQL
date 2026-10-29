---
type: issue
id: ISS-0248
created: 2026-10-08
topics: [ops-infra, ci-deploy]
symptoms: [배포 시 로그 유실, "docker rm -f", "actuator/health 로그 노이즈", 요청 ID 없음, X-Request-Id, MDC, ANSI 색상 코드, suh-logger]
root_cause: "로그가 컨테이너 안(Synology db 로그 드라이버)에만 있어 배포 시 사라졌고, 헬스체크 로그 제외·요청 식별자·ANSI 끄기 설정이 없었다"
status: resolved
resolution: "[[ISS-0248-ops-log-retention-request-trace-report]]"
related: ["[[ISS-0249-suh-logger-2-0-3-upgrade]]"]
source: "https://github.com/Twin-Fang/passQL/issues/436"
---

# ISS-0248: 운영 로그 — 배포 시 유실, 헬스체크 노이즈, 요청 추적 불가, ANSI 혼입

GitHub #436 (원본: 이슈 본문, 배포 결과 댓글, 리포트 댓글, 정정 댓글).

## 증상
2026-10-08 운영 실측:
1. 배포마다 이전 로그가 사라진다 — blue/green 전환 시 구 컨테이너를 `docker rm -f` 하고 로그는 컨테이너 안(Synology `db` 로그 드라이버)에만 있다. 볼륨 `(NAS 경로 생략)`는 마운트돼 있지만 비어 있다. AI 컨테이너도 같은 상태.
2. 배포 직후 요청 로그 87건 중 86건이 `/actuator/health`(5초 간격, 요청 1건당 6줄 → 하루 약 10만 줄).
3. 로그 줄에 요청 ID·회원 ID·처리 시간이 없고, suh-logger 블록이 여러 줄이라 동시 요청과 섞인다.
4. ANSI 색상 코드가 로그에 섞여 grep·수집이 불편하다.

## 재현 조건
배포(구 컨테이너 제거) 시 1번, 평상시 운영 로그에서 2~4번.

## 조사 기록
- 2026-10-08: v0.3.0 배포 후 10분 로그에 ANSI 이스케이프 6줄 잔존. 리포트는 suh-logger 2.0.1이 `RESPONSE LOGGING` 블록을 직접 출력해 설정이 안 먹는다고 보고 "라이브러리 수정 필요"라 적었다.
- 2026-10-08 정정 댓글: 위 판단은 틀렸다. suh-logger 2.0.3(2026-07-04)이 이미 SLF4J 위임으로 전환(Cassiiopeia/suh-logger#53). passQL이 2.0.1을 써서 생긴 문제 → GitHub #438.

## 근본 원인
frontmatter `root_cause`와 같음. ANSI 잔존분은 suh-logger 2.0.1의 직접 출력(정정 댓글 기준 2.0.3으로 해결 가능).
