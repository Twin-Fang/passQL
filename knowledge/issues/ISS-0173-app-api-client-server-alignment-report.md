---
type: completion-report
id: ISS-0173
created: 2026-10-02
topics: [dev-workflow, auth-member]
status: resolved
resolves: "[[ISS-0173-app-api-client-server-alignment]]"
related: ["[[DEC-0084-recommendation-exclusion-post-body-fifo]]"]
source: "https://github.com/Twin-Fang/passQL/issues/328"
---

# ISS-0173 완료 리포트: memberUuid 제거, 추천 POST, 앱 에러 코드 체계 공통화

GitHub #328 완료 댓글(2026-10-02, 커밋 `51c18e7`) 기준. `## 개요` 형식 리포트는 없음.

## 해결 방법
서버 계약 정합
- 모든 API에서 `memberUuid` 쿼리/헤더 제거(회원은 JWT로 식별), SSE 요청의 `X-Member-UUID` 헤더 제거, 서버에 없는 `/members/register` 제거.
- 추천 문제 `POST /questions/recommendations` 본문(`size`, `excludeQuestionUuids`).
- 답안 제출과 AI 코멘트 조회에 `sessionUuid`(선택) 추가. 설정 버전 표기의 `-MVP` 접미사 제거.

기반 구조
- `core/error`: 서버 `{errorCode, message}` 형식에 맞춘 `ErrorCode`, `AppException`, 변환기. 모르는 서버 코드도 상태코드로 분류하고 원문 코드 보존. 5xx와 프록시 HTML(502 등)은 사용자 문구로 대체.
- `core/network/api_providers.dart`: API 클라이언트를 Provider로 제공(호출마다 `XApiClient(dio)` 생성하던 13곳 정리).
- `core/network/safe_call.dart`: 중복 `_safe` 2개 통합, 인증 만료는 삼키지 않고 상위로 전달.

검증: `flutter analyze` 0건, 테스트 30개(에러 변환 12, API 계약 4 추가), 운영 `/meta/topics` 응답 필드와 앱 모델 일치.

## 근본 원인 (확정)
앱 API 정의가 구버전 서버 기준이었다.

## 재발 방지
API 계약 테스트 추가. 후속: 응답 모델 전체 대조는 로그인 가능해진 뒤 실서버 검증, 미사용 `member_store.dart`·`MemberRegisterResponse` 모델은 삭제 승인 후 정리.

## 교훈
(원본에 없음, 볼트 정리) 앱 화면이 항상 비어 있으면 호출 엔드포인트가 서버에서 제거·대체되지 않았는지 먼저 대조한다.
