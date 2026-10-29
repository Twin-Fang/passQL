---
type: issue
id: ISS-0299
created: 2026-10-16
topics: [dev-workflow]
symptoms: [API 계약 사본, 서버 DTO 웹 앱 불일치, required nullable 없음, "웹이 모든 필드를 값이 있다고 믿음", freezed 모델, openapi.json]
root_cause: "API 계약을 서버·웹·앱이 각자 손으로 쓴 사본으로 갖고 있었고, 스펙에 required·nullable 정보가 없어 생성 타입이 null 가능성을 표현하지 못했다"
status: resolved
resolution: "[[ISS-0299-openapi-spec-accuracy-app-contract-test-report]]"
related: ["[[DEC-0134-response-fields-required-nullable-marked]]", "[[DEC-0135-app-models-checked-not-generated]]"]
source: "https://github.com/Twin-Fang/passQL/issues/493"
---

# ISS-0299: API 계약 단일 원본 — 스펙에 required·nullable이 없고 앱 모델은 스펙과 대조되지 않음

GitHub #493 (원본: 이슈 본문, 설계·진행 댓글, 진행 방향 변경 댓글, `# ... (#493)` 리포트 댓글). GitHub #458 남은 일.

## 증상
- API 계약을 서버(DTO 약 136개 파일), 웹(`client/src/types/api.ts`, 타입 65개), 앱(`app/lib/data/models` freezed 36개)이 각자 손으로 쓴 사본으로 가짐. 서버 DTO를 바꾸면 웹·앱이 따로 어긋나고 빌드에서 잡히지 않음.
- 서버 springdoc 스펙(`/docs/api-docs`)은 있으나 파일로 보관하지 않아 비교 기준이 없음(이슈 작성 시점).
- DTO에 nullable·required 표시가 없어 생성하면 모든 필드가 선택 값이 됨.

## 재현 조건
해당 없음(기능 개선).

## 조사 기록
- 2026-10-16 05:29: 첫 브랜치에서 `server/openapi/openapi.json`, `OpenApiSpecSnapshotTest`, 웹 `api:generate`·`api:check`로 구현. 앱은 소유자 결정("생성")과 달리 검사로 바꿈(이유는 [[DEC-0135-app-models-checked-not-generated]]). 원본: "확인 필요".
- 2026-10-16 08:17: 다른 세션이 같은 목표를 `api-contract/openapi.json`, `npm run gen:api`, `OpenApiContractTest`로 먼저 main에 병합·1.3.0 배포. 두 방식을 함께 두면 원본이 둘로 갈라지므로 첫 브랜치는 버리고, main에 없던 두 가지(스펙 정확도, 앱 계약 테스트)만 새 브랜치로 옮겨 PR #494. 이 볼트의 기존 결정 DEC-0123(계약 원본 `api-contract/openapi.json`)과 같은 경로다.
- 첫 브랜치 `20261016_#493_기능개선_공통_API_계약_단일_원본_OpenAPI_스펙에서_웹과_앱_타입_생성`은 원격에 남아 있고 삭제는 사용자 확인 필요(원본).

## 근본 원인
frontmatter `root_cause`와 같음.
