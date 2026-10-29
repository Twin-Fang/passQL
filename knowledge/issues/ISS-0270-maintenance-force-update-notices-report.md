---
type: completion-report
id: ISS-0270
created: 2026-10-15
topics: [ops-infra, admin, notification]
status: resolved
resolves: "[[ISS-0270-maintenance-force-update-notices]]"
related: []
source: "https://github.com/Twin-Fang/passQL/issues/464"
---

# ISS-0270 완료 리포트: `GET /api/meta/app-config`로 점검·강제/권장 업데이트·공지 제어

GitHub #464 구현 보고서 기준 (1차 통합 main `0bc1ed5`, 서버 0.11.0).

## 해결 방법
- 서버: 공개 API `GET /api/meta/app-config`(인증 불필요, 점검 중에도 응답) — 플랫폼별 최소/권장 버전, 스토어 링크, 점검 여부·문구, 노출 중 공지. 설정 키 6개(`app.minimum_version.ios/android`, `app.recommended_version.ios/android`, `app.maintenance.enabled/message`)는 `AppSettingKeys` 한 곳. 공지 테이블 `app_notice`. 마이그레이션 `V0_10_1`(초기값, 차단 없음), `V0_10_2`(공지). 점검 중이면 `/api/**`를 503 `SERVICE_UNDER_MAINTENANCE`로 차단(예외 `/api/meta/**`, `/api/auth/**`, 관리자).
- 관리자: 사이드바 "앱 운영" — 점검 토글·문구, 플랫폼별 버전(x.y.z 검증), 공지 등록·수정·비활성.
- 앱: 시작 시 1회 조회(최대 4초, 실패하면 막지 않음), 판정 순서 점검 > 최소 버전 미만(강제 업데이트) > 정상, 권장 업데이트 안내(같은 버전 1회), 홈 공지 배너.
- 웹: 시작 시 조회, 점검 화면, 사용 중 503 수신 시 점검 화면, 로그인 후 공지 배너·모달.

## 근본 원인 (확정)
이슈 노트와 같음.

## 재발 방지
- 검증: 서버 96개 중 95개 통과(기존 dev DB 외래키 테스트 1개 실패), 로컬 복사 DB에서 잘못된 버전·공지 기간 400·점검 중 회원 API 503·관리자 200, 앱 271개, 웹 vitest 28개. 운영 `flyway_schema_history`에 0.10.1·0.10.2 성공.
- 주의(원본): **최소·권장 버전은 새 버전이 스토어에 실제로 나온 뒤에 올린다** — 먼저 올리면 업데이트할 수 없는 사용자가 차단된다. iOS·Android는 출시 시점이 달라 따로 둔다. 현재 출시된 앱은 이 기능을 몰라 점검을 켜면 일반 오류로 보인다. 운영 `storeUrl`이 모두 null이라 관리자 앱 설정에 스토어 링크를 넣어야 스토어 이동 버튼이 나온다.

## 교훈
원본 주의사항(버전 상향 시점)과 같음.
