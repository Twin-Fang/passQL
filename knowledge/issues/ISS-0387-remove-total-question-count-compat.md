---
type: issue
id: ISS-0387
created: 2026-10-24
topics: ["progress-stats", "dev-workflow"]
symptoms: ["totalQuestionCount", "topic-analysis", "TopicStat", "구버전 앱 파싱 오류", "app.minimum_version", "전체 문제 수 노출"]
root_cause: "구버전 앱이 `TopicStat.totalQuestionCount`를 필수값으로 읽어 서버가 필드를 바로 뺄 수 없다"
status: open
resolution: null
related: []
source: "https://github.com/Twin-Fang/passQL/issues/632"
---

# ISS-0387: 카테고리별 전체 문제 수(`totalQuestionCount`) 응답 제거 — 구버전 앱 호환 처리와 최소 버전 상향

GitHub #632 (원본: 이슈 본문과 진행 댓글 2개).

## 증상
GitHub #609로 앱 화면은 `totalQuestionCount`(카테고리별 전체 문제 수)를 더 이상 쓰지 않지만, 서버 응답 `GET /progress/topic-analysis`에는 아직 들어 있어 네트워크로 보인다. 목표는 사용자에게 전체 문제 양을 어디에서도 노출하지 않는 것. 구버전 앱은 `TopicStat.totalQuestionCount`를 필수값으로 읽고 막대 길이에 쓴다.

## 재현 조건
서버가 필드를 먼저 빼면 구버전 앱의 통계 화면이 파싱 오류로 깨진다(원본 서술).

## 조사 기록
- 2026-10-24: 순서 — 1) 앱 `totalQuestionCount`를 필수 아님(기본값 0) 2) 새 앱 빌드 스토어 배포 후 대기 3) 관리자 설정 `app.minimum_version.ios/android` 상향(구버전 차단, 사용자 승인 후에만) 4) 서버 `TopicStat` DTO·`ProgressControllerDocs`에서 필드 제거, `api-contract/openapi.json` 갱신, 웹 `gen:api` 재생성(3번 이후, 웹 `src/types/api`의 `TopicStat` 사용처 재확인).
- 2026-10-24: 1번 완료 — 앱 `TopicStat.totalQuestionCount` 기본값 0 처리(PR #633). 필드가 없는 응답도 읽히는 것을 확인. 아직 스토어 빌드에는 없음.
- 2026-10-24: 서버 호환 응답 배포(PR #635, deploy `30f0c518`, Blue-Green 무중단 배포) — `totalQuestionCount`에 전체 문제 수 대신 `solvedCount` 값을 담음. 구버전 앱도 오류 없이 푼 문제 수 막대가 나오고 전체 문제 수는 응답에서 사라짐. 실측: 헬스 200, `/api/progress/topic-analysis` 비로그인 401(응답 값은 로그인 없이 확인 못 함).
- 남은 것: 새 앱 빌드 배포 > 최소 버전 상향 > 필드 자체 제거. 이슈는 열려 있다(라벨 `작업중`).

## 근본 원인
구버전 앱이 이 필드를 필수값으로 파싱하기 때문에 서버에서 바로 제거할 수 없다(원본 「문제」). 해결 진행 중.
