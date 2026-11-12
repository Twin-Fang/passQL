---
type: decision
id: DEC-0292
created: 2026-11-12
reviewed: null
topics: [admin, billing]
status: active
supersedes: null
superseded_by: null
related: ["[[ISS-0495-admin-app-operation-settings]]", "[[DEC-0026-sensitive-settings-masked-readonly]]", "[[DEC-0011-code-freeze-tunables-via-admin]]"]
---

# DEC-0292: 최소·권장 버전과 결제 켜기 준비는 관리자 앱 운영 화면(`/admin/app-operation`) 한 곳에서 바꾸고, 최소 버전 경고는 스토어 공개 버전 대신 서버 빌드 버전과 비교한다

## 문제 정의 (Context)
최소·권장 버전 키를 앱 운영 화면과 일반 설정 표 두 곳에서 편집할 수 있었고, 결제 켜기 전 준비 상태를 모아 보는 곳이 없었다 (GitHub #961, [[ISS-0495-admin-app-operation-settings]]).

## 결정 (Decision)
- 앱 운영 화면을 앱 운영 설정의 단일 입구로 둔다. 일반 설정 표에서 앱 운영 전용 키 10개는 읽기 전용 + "앱 운영 화면에서 수정" 링크.
- 앱 운영 화면에 결제 영역(결제 스위치, 미리보기 회원, 켜기 전 점검표)을 둔다. 점검표는 읽기 전용이고 비밀 값은 "설정됨/미설정" 배지로만 보인다.
- 결제 스위치를 켤 때 점검표에서 빠진 항목은 확인 창에 알리기만 하고 막지 않는다.
- 최소 버전 저장 전 확인 창은 변경 전후 값과 영향을 보이고, 올리려는 값이 **서버 빌드 버전**보다 높으면 경고한다.
- 일반 설정 저장 API는 운영 스크립트 호환을 위해 전용 키도 계속 받는다. 막는 것은 화면뿐이다.

## 검토한 대안 (Alternatives)
- 스토어 공개 버전과 비교(이슈 제안): 서버가 스토어 공개 버전을 알 방법이 없어 서버 빌드 버전 비교로 대신했다(리포트 「구현 때 정한 것」).
- 일반 설정 저장 API에서도 전용 키 거부: 운영 스크립트 호환 때문에 화면에서만 막았다(같은 절).
- 그 밖의 논의 기록 없음.

## 결과 (Consequences)
**긍정**
- 결제 켜기 전 준비 상태를 한 화면에서 본다. 비밀 설정을 값으로 오해하지 않는다.

**부정**
- 일반 설정 API로는 전용 키를 여전히 바꿀 수 있다. 일반 설정 표의 "이 값으로 복원"도 전용 키에 남아 있다.

## 영향 범위 (Scope)
- 서버 관리자 `/admin/app-operation`, `/admin/settings`, `BillingOperationServiceTest`, 감사 로그(`AdminAuditLogService`).

## 출처 (References)
- GitHub #961 이슈 본문과 구현 보고(PR #969): https://github.com/Twin-Fang/passQL/issues/961
