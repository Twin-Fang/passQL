---
type: completion-report
id: ISS-0239
created: 2026-10-08
topics: [security, ops-infra]
status: resolved
resolves: "[[ISS-0239-api-error-format-and-auth-failure-logs]]"
related: ["[[DEC-0106-unified-error-body-for-security-errors]]"]
source: "https://github.com/Twin-Fang/passQL/issues/406"
---

# ISS-0239 완료 리포트: 401·403·404도 `errorCode`·`message` 형식, 인증 실패 WARN 로그

GitHub #406 완료 댓글 기준 (v0.0.251, PR #416). `## 개요` 형식 리포트는 없음.

## 해결 방법
| 경우 | 전 | 후 |
|---|---|---|
| `/api/**` 미인증 | 401 본문 없음 | 401 `{"errorCode":"UNAUTHORIZED","message":"로그인이 필요합니다."}` |
| `/api/**` 권한 없음 | 403 기본 처리 | 403 `ACCESS_DENIED` |
| 컨트롤러 밖 오류(없는 경로, 관리자 CSRF 403 등) | `{timestamp,status,error,path}` | `{status,path,errorCode,message}` |
| 인증 실패·관리자 로그인 실패 | 로그 없음 | WARN (메서드·경로·IP / 관리자는 IP·사유, 아이디 미기록) |

- 대응 컨트롤러 없는 `/api/admin/**` 규칙 제거.
- 웹(`client.ts`)·앱(`auth_interceptor.dart`, `ErrorCodeMapper`)은 상태 코드로 분기 → 호환. 앱은 4xx 서버 문구를 그대로 보여주므로 한국어 사용자 문구로 둠.

## 근본 원인 (확정)
보안 필터 단계 오류가 공통 형식을 거치지 않았고 로그가 없었다.

## 재발 방지
운영 실측: 미인증 `/api/members/me` → 401 `UNAUTHORIZED` 본문, `WARN c.p.web.config.ApiSecurityErrorHandler : [auth] 인증 실패: GET /api/members/me ip=(마스킹)`. 단위 테스트 `ErrorFormatTest` 3개 통과.
범위 밖으로 남긴 것: 신고 처리자를 `X-Member-UUID` 헤더로 받는 문제. 관리자는 회원 테이블에 없어 처리자 컬럼 설계 변경이 필요하다. 관리자 화면은 이 헤더를 보내지 않아 현재 처리자는 null로 기록된다.

## 교훈
(원본에 없음, 볼트 정리) 오류 형식을 통일할 때는 컨트롤러 예외 처리기뿐 아니라 보안 필터 단계(인증 진입점·접근 거부 처리기)도 함께 본다.
