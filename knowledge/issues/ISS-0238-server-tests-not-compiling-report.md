---
type: completion-report
id: ISS-0238
created: 2026-10-08
topics: [dev-workflow, ci-deploy]
status: resolved
resolves: "[[ISS-0238-server-tests-not-compiling]]"
related: []
source: "https://github.com/Twin-Fang/passQL/issues/405"
---

# ISS-0238 완료 리포트: 깨진 테스트 4곳 수정, 단위 테스트 32개 통과

GitHub #405 완료 댓글 기준 (PR #415). `## 개요` 형식 리포트는 없음.

## 해결 방법
- `GreetingServiceTest`: 소셜 로그인 전환으로 사라진 `register()` 대신 `Member.signUp`으로 테스트 회원 생성.
- `AuthServiceTest`·`MemberAdminServiceTest`·`ProgressServiceTest`: 도메인 모듈 테스트가 PQL-Web의 `PassqlApplication`을 참조해 컴파일 불가 → `PQL-Web`을 테스트 의존으로 가진 PQL-Application으로 이동. `AuthServiceTest`는 DTO 패키지 이동과 `Optional` 반환 변경도 반영.
- `ReadinessCalculatorTest`: 숫자로 시작하는 메서드명(`1문제만_...`) 수정.

## 근본 원인 (확정)
테스트가 사라진 API와 다른 모듈의 애플리케이션 클래스를 참조했다.

## 재발 방지
`./gradlew compileTestJava` 통과, `./gradlew test` 단위 테스트 32개 통과. `@SpringBootTest` 통합 테스트 12개는 로컬 전용 `application-dev.yml`(gitignore, DB 접속 정보)이 있어야 실행된다. 남은 제안(별도 판단): CI가 `-x test`로 빌드한다. 단위 테스트만이라도 돌리려면 통합 테스트에 `@Tag("integration")`을 붙이고 기본 실행에서 제외하는 설정이 필요하다 — 결정되지 않았다.

## 교훈
(원본에 없음, 볼트 정리) CI가 테스트를 건너뛰면 테스트 코드는 조용히 썩는다. GitHub #373에서도 같은 이유로 테스트를 다른 모듈에 두었다.
