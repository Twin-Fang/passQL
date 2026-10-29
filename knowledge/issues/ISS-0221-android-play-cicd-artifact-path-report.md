---
type: completion-report
id: ISS-0221
created: 2026-10-07
topics: [ci-deploy]
status: resolved
resolves: "[[ISS-0221-android-play-cicd-artifact-path]]"
related: []
source: "https://github.com/Twin-Fang/passQL/issues/376"
---

# ISS-0221 완료 리포트: Android Play 배포 5단계 수정, 내부 테스트 트랙 자동 업로드 연결

GitHub #376 처리 결과·최종 빌드·자동 업로드 연결 댓글 기준 (2026-10-07). `## 개요` 형식 리포트는 없음.

## 해결 방법
| 단계 | 증상 | 원인 | 수정 |
|---|---|---|---|
| 1 | `Artifact not found: project-files` | 업로드 경로가 레포 루트 기준, 0건이 warn으로 통과 | 경로 앞에 앱 폴더, `if-no-files-found: error`, 다운로드 경로도 앱 폴더 |
| 2 | `flutter pub get` 실패(`dev/a11y_assessments`) | `subosito/flutter-action`이 `FLUTTER_ROOT`를 Flutter SDK 경로로 덮어씀 | 앱 경로 변수를 `APP_DIR`로 분리 |
| 3 | `Malformed root json google-services.json` | 레포 이전(Twin-Fang) 때 Android 시크릿이 빠짐 | 사용자 승인 후 시크릿 5개 등록 |
| 4 | `Keystore file .../app/app/keystore/key.jks not found` | `storeFile`이 app 모듈 기준인데 `app/` 접두사 | `storeFile=keystore/key.jks`, 로그에 비밀번호가 찍히던 `cat key.properties`를 키 이름만 보이게 |
| 5 | `Copy Fastfile for Play Store` 실패 | `app/android/fastlane/Fastfile.playstore` 없음 | playstore-wizard 템플릿으로 생성(internal 트랙, 승급 기본 꺼짐) |

- 처음엔 Play 서비스 계정이 없어 CI가 만든 AAB를 Play Console에서 직접 올려 내부 테스트에 240 (0.0.240), 이어 GitHub #378 포함 최종 빌드 243 (0.0.243) 게시.
- 자동 업로드: GCP 프로젝트 `passql`에 서비스 계정을 만들고 Play Console에 passQL 앱만, 읽기 전용 2종 + 테스트 트랙 출시 권한으로 초대(프로덕션 출시 권한 없음). JSON 키를 시크릿 `GOOGLE_PLAY_SERVICE_ACCOUNT_JSON_BASE64`로 등록. CI run 37617730561이 업로드까지 성공, 0.0.244 자동 게시.

## 근본 원인 (확정)
`upload-artifact`가 작업 디렉터리 기본값을 따르지 않는 점과 조용한 0건 업로드. 나머지는 위 표의 단계별 원인.

## 재발 방지
`if-no-files-found: error`로 조용한 실패를 막았다. 로그에 비밀번호가 찍히던 단계를 고쳤다.

## 교훈
(원본에 없음, 볼트 정리) 모노레포 하위 폴더 앱의 워크플로우에서는 `uses:` 액션의 경로가 `defaults.run.working-directory`를 따르지 않는다. iOS(GitHub #348)와 Android에서 같은 문제가 반복됐다.
