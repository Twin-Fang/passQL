---
type: issue
id: ISS-0270
created: 2026-10-15
topics: [ops-infra, admin, notification]
symptoms: [점검 모드 없음, 강제 업데이트 없음, 최소 버전, 공지 없음, "/api/meta/app-config", SERVICE_UNDER_MAINTENANCE, 구버전 앱 차단]
root_cause: "서버 `app_setting`에 최소 버전·점검·공지 키가 없고 앱은 `/meta/topics`, `/meta/legal`만 호출해 구버전 앱을 막거나 안내할 방법이 없었다"
status: resolved
resolution: "[[ISS-0270-maintenance-force-update-notices-report]]"
related: ["[[ISS-0247-web-withdrawal-app-release-banner]]"]
source: "https://github.com/Twin-Fang/passQL/issues/464"
---

# ISS-0270: 점검·강제/권장 업데이트·공지 수단이 없음

GitHub #464 (원본: 이슈 본문과 구현 보고서).

## 증상
서버 `app_setting`에 최소 버전, 점검, 공지 키가 없다. 앱은 `/meta/topics`, `/meta/legal`만 호출. API를 깨는 배포나 점검 때 구버전 앱을 막거나 안내할 방법이 없다.

## 재현 조건
해당 없음 (기능 부재).

## 조사 기록
- 2026-10-15: 제안 — 최소/권장 버전·점검·공지를 `app_setting`과 공지 테이블로, 공개 API `/meta/app-config` 하나로 내려줌(스토어 이동은 기존 `store.*_url`), 관리자 화면, 앱 강제 업데이트·권장 안내·점검·공지.

## 근본 원인
frontmatter `root_cause`와 같음.
