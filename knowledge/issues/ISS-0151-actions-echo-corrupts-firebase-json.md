---
type: issue
id: ISS-0151
created: 2026-04-22
topics: [ci-deploy, auth-member]
symptoms: [MalformedJsonException, "firebase-service-account.json 손상", "echo 큰따옴표 제거", "서버 기동 불가", "CORS 에러", "preflight 응답 없음", "GitHub Actions secret"]
root_cause: "배포 워크플로우가 `echo \"${{ secrets... }}\"`로 시크릿 JSON을 파일에 써서 큰따옴표가 사라진 무효 JSON이 됨"
status: resolved
resolution: "[[ISS-0151-actions-echo-corrupts-firebase-json-report]]"
related: []
source: "https://github.com/Twin-Fang/passQL/issues/280"
---

# ISS-0151: GitHub Actions `echo`가 Firebase JSON을 손상시켜 서버가 뜨지 않음

GitHub #280 (원본: 이슈 본문과 완료 보고 댓글).

## 증상
`firebase-service-account.json`이 `{ type: service_account, project_id: passql, ...}`처럼 큰따옴표 없이 저장돼 Spring Boot 기동 시 Firebase SDK 파싱 실패, 서버 전체가 뜨지 않는다. `docker logs passql-back`:
```
com.google.gson.stream.MalformedJsonException: Use JsonReader.setStrictness(Strictness.LENIENT)
to accept malformed JSON at line 2 column 4 path $.
```
CORS 에러는 서버가 죽어 preflight에 응답하지 못한 2차 증상.

## 재현 조건
`deploy` 브랜치 push → 배포 워크플로우 → 컨테이너 `app.jar`의 `BOOT-INF/classes/firebase-service-account.json` 확인.

## 조사 기록
- 2026-04-22: 문제 코드 `.github/workflows/PROJECT-SPRING-SERVER-DEPLOY.yml:28` — `echo "${{ secrets.FIREBASE_SERVICE_ACCOUNT_JSON }}" > server/PQL-Web/src/main/resources/firebase-service-account.json`.

## 근본 원인
shell의 큰따옴표 처리로 JSON 따옴표가 사라졌다.
