---
type: decision
id: DEC-0097
created: 2026-10-06
reviewed: null
topics: [store-release, ci-deploy, security]
status: active
supersedes: null
superseded_by: null
related: ["[[ISS-0190-android-release-signing-key]]", "[[ISS-0190-android-release-signing-key-report]]"]
---

# DEC-0097: Android 릴리스 서명은 `key.properties` 기반, 키스토어·비밀번호는 저장소 밖(로컬·CI 시크릿)

## 문제 정의 (Context)
Android 릴리스 빌드가 디버그 키로 서명되어 Play Store에 올릴 수 없었다 (GitHub #345, #339 위험 2번).

## 결정 (Decision)
- 릴리스 서명 설정을 `key.properties` 기반으로 구성한다. 파일이 없으면 개발용으로 디버그 키로 빌드되고, 있으면 릴리스 키로 서명한다.
- 키스토어와 비밀번호는 저장소에 넣지 않고 로컬과 CI 시크릿으로만 관리한다. 분실에 대비해 안전한 곳에 백업한다.

## 검토한 대안 (Alternatives)
논의 기록 없음.

## 결과 (Consequences)
**긍정**
- 서명된 AAB를 Play 비공개 테스트에 게시했다 (완료 댓글).

**부정**
- 논의 기록 없음.

## 영향 범위 (Scope)
Android gradle 서명 구성, `key.properties`, 업로드 키스토어, Firebase Android 앱 SHA-1, CI 시크릿.

## 출처 (References)
- GitHub #345 이슈 본문 「해결 방안」, 완료 댓글(2026-10-07)
