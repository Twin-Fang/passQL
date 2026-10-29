---
type: issue
id: ISS-0293
created: 2026-10-15
topics: [ci-deploy]
symptoms: [디버그 키 서명, 키스토어 없음, BACKEND_BASE_URL 빈 문자열, INTERNET 권한 미선언, 릴리스 빌드]
root_cause: "키스토어가 없으면 릴리스 빌드가 디버그 키로 조용히 서명했고, `BACKEND_BASE_URL`이 비어도 그대로 실행됐다"
status: resolved
resolution: "[[ISS-0293-release-build-safeguards-report]]"
related: []
source: "https://github.com/Twin-Fang/passQL/issues/487"
---

# ISS-0293: 앱 릴리스 빌드 안전장치 부재

GitHub #487 (원본: 이슈 본문, 구현 보고서 댓글).

## 증상
- 키스토어가 없으면 디버그 키로 조용히 서명.
- `BACKEND_BASE_URL`이 없으면 빈 문자열로 실행.
- AndroidManifest에 INTERNET 권한을 직접 선언하지 않음(원본: 확인 필요).
- 위치: `app/android/app/build.gradle.kts:58-62`, `app/lib/core/network/dio_client.dart:17`.

## 재현 조건
키스토어나 `BACKEND_BASE_URL` 없이 릴리스 빌드.

## 조사 기록
- 2026-10-15: 제안 — CI 릴리스 빌드는 키스토어 없으면 실패, 시작 시 base URL 비면 즉시 실패, INTERNET 권한 명시.

## 근본 원인
frontmatter `root_cause`와 같음.
