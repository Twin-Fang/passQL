---
type: completion-report
id: ISS-0262
created: 2026-10-16
topics: [ci-deploy]
status: resolved
resolves: "[[ISS-0262-issue-comment-app-test-build-fail]]"
related: ["[[DEC-0117-secret-files-nas-backup]]"]
source: "https://github.com/Twin-Fang/passQL/issues/456"
---

# ISS-0262 완료 리포트: 테스트 빌드 워크플로를 projectops 4.49.0 템플릿으로 교체, App Distribution 배포까지 확인

GitHub #456 구현 보고서(2026-10-15)와 후속 보고(2026-10-16) 기준.

## 해결 방법
- 두 워크플로를 **projectops 4.49.0 템플릿**으로 교체(`permissions`, `APP_ROOT` 경로, 시각 기반 빌드 번호 `build_number.py`, 실제 있는 `deploy` lane).
- passQL 값: 공통 `APP_ROOT: "app"`. Android `JAVA_VERSION: "17"`, App Distribution 앱 ID(com.coldredrice.passql), 테스터 그룹 별칭 `testers`, 키스토어를 `android/app/keystore`에 생성. iOS `GoogleService-Info.plist` 생성 단계 추가, 프로젝트 파일 아티팩트를 `APP_ROOT`에 풀도록 수정(#348과 같은 경로 문제). 커밋 `cb3878a`, `6417e8e`.
- 후속(2026-10-16): Firebase `passql`의 `PassQL-Android-Prod`에서 App Distribution 시작, `testers` 그룹 생성·테스터 추가, Secret `FIREBASE_SERVICE_ACCOUNT_JSON_BASE64` 등록, NAS 백업 워크플로에도 추가(`.../github_secret/app/firebase-app-distribution-service-account.json`).

## 근본 원인 (확정)
이슈 노트와 같음.

## 재발 방지
- 검증: Android run `38682423801` 성공(0.9.2(87971845)), iOS run `38682423979` 성공(0.9.2(87972608) TestFlight), `actionlint` 오류 없음. 후속 `PROJECT-FLUTTER-ANDROID-TEST-APK` run `38859305744` 성공, App Distribution 릴리스 `1.2.1`(빌드 88063571) 확인.
- 주의(원본): `repository_dispatch` 빌드는 **main에 있는 워크플로 정의**로 실행 — 고친 뒤 main 반영 필요. Android 테스트 빌드는 Flutter 3.38.9(스토어 Android는 3.35.5, 맞출지는 따로). 키스토어 경로는 `build.gradle.kts`의 `file()` 기준에 묶여 템플릿을 다시 덮어쓰면 되돌아감. iOS 실패 댓글 "사유" 칸 추출 로직 문제는 projectops 쪽에서 수정 필요. 이슈 댓글 경로 실사용 확인은 다음 사용 때.

## 교훈
(원본에 없음, 볼트 정리) 모노레포에서 템플릿 워크플로가 실패하면 작업 디렉터리(`APP_ROOT`)와 `permissions`부터 본다.
