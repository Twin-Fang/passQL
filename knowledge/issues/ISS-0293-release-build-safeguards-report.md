---
type: completion-report
id: ISS-0293
created: 2026-10-15
topics: [ci-deploy]
status: resolved
resolves: "[[ISS-0293-release-build-safeguards]]"
related: []
source: "https://github.com/Twin-Fang/passQL/issues/487"
---

# ISS-0293 완료 리포트: `verifyReleaseKeystore` 검사, base URL 즉시 실패, INTERNET 권한 명시

GitHub #487 구현 보고서 댓글 기준 (2차 통합본).

## 해결 방법
- 키스토어가 없으면 디버그 키로 서명하던 릴리스 빌드를 검사 작업(`verifyReleaseKeystore`)으로 실패시킴. 로컬 디버그 빌드는 그대로.
- `BACKEND_BASE_URL`이 비면 앱 시작 시 즉시 오류.
- AndroidManifest에 INTERNET 권한 명시.
- 검증: `flutter analyze` 경고 0, `flutter test` 292개 통과. Play 내부·비공개 테스트 업로드 run `38817746746` 성공(CI 키스토어 경로와 일치, 검사 작업 통과).

## 근본 원인 (확정)
이슈 본문과 같음.

## 재발 방지
주의(원본): CI가 키스토어를 `android/app/keystore`에 만들어야 한다. 경로가 바뀌면 릴리스 빌드가 실패한다.

## 교훈
(원본에 없음, 볼트 정리) 릴리스 빌드에서 필수 입력이 없을 때 조용히 대체값을 쓰지 말고 실패시킨다.
