---
type: issue
id: ISS-0221
created: 2026-10-07
topics: [ci-deploy]
symptoms: ["Artifact not found for name: project-files", PROJECT-FLUTTER-ANDROID-PLAYSTORE-CICD, upload-artifact, if-no-files-found, FLUTTER_ROOT, "Malformed root json google-services.json", key.jks]
root_cause: "`upload-artifact`가 `defaults.run.working-directory`(app)를 따르지 않아 레포 루트 기준 경로로 0건 업로드, `warn` 기본값으로 조용히 통과"
status: resolved
resolution: "[[ISS-0221-android-play-cicd-artifact-path-report]]"
related: []
source: "https://github.com/Twin-Fang/passQL/issues/376"
---

# ISS-0221: Android Play 배포 워크플로우가 `project-files` 산출물 경로 누락으로 실패

GitHub #376 (원본: 이슈 본문과 댓글 3개).

## 증상
`PROJECT-FLUTTER-ANDROID-PLAYSTORE-CICD`가 "Android AAB 빌드" 단계에서 실패.
```
Unable to download artifact(s): Artifact not found for name: project-files
```

## 재현 조건
Android Play 배포 워크플로우 실행 (실패 run 37594484160).

## 조사 기록
- 2026-10-07: 이슈 본문 — 준비 job `Upload project files`가 `pubspec.yaml`, `lib/`, `assets/`를 레포 루트 기준으로 찾음. 다운로드도 `path: .`. iOS TestFlight 워크플로우에서 같은 문제를 이미 고침(GitHub #348).
- 2026-10-07: 고치는 과정에서 단계별로 4~5개 문제가 연속으로 드러남(리포트 표).

## 근본 원인
`upload-artifact`는 `defaults.run.working-directory`(app)를 따르지 않으므로 0건 → 기본값 `warn`으로 조용히 통과 → 산출물 미생성. 이후 단계에서 `FLUTTER_ROOT` 덮어쓰기, 시크릿 누락, keystore 경로, Fastfile 부재가 이어졌다.
