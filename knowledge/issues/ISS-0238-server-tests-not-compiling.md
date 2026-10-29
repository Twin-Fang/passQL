---
type: issue
id: ISS-0238
created: 2026-10-07
topics: [dev-workflow, ci-deploy]
symptoms: [GreetingServiceTest, "cannot find symbol memberService.register()", compileTestJava, "-x test", "서버 테스트 미실행", PassqlApplication]
root_cause: "테스트 4곳이 사라진 API·다른 모듈의 `PassqlApplication`을 참조해 컴파일되지 않았고, CI는 `-x test`로 테스트를 건너뛰었다"
status: resolved
resolution: "[[ISS-0238-server-tests-not-compiling-report]]"
related: []
source: "https://github.com/Twin-Fang/passQL/issues/405"
---

# ISS-0238: `GreetingServiceTest` 컴파일 실패로 서버 테스트가 실행되지 않음

GitHub #405 (원본: 이슈 본문과 완료 댓글).

## 증상
`PQL-Application`의 `GreetingServiceTest`가 JWT 전환 때 사라진 `memberService.register()`를 호출해 테스트 컴파일이 실패한다. `./gradlew build`(테스트 포함)가 깨지고, CI는 `-x test`로 테스트를 건너뛰어 서버 테스트가 사실상 돌지 않는다.

## 재현 조건
`cd server && ./gradlew compileTestJava` → `GreetingServiceTest.java:89: error: cannot find symbol memberService.register()`.

## 조사 기록
- 2026-10-07: `.github/workflows/PROJECT-SPRING-PASSQL-CI.yaml`: `./gradlew clean build -x test`.
- 2026-10-08: 깨진 곳은 하나가 아니라 4곳(리포트).

## 근본 원인
CI가 테스트를 건너뛰는 동안 API 변경·모듈 구조 변경에 테스트가 따라가지 못했다.
