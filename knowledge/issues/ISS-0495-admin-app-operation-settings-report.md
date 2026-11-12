---
type: completion-report
id: ISS-0495
created: 2026-11-12
topics: [admin, billing, ads]
status: resolved
resolves: "[[ISS-0495-admin-app-operation-settings]]"
related: ["[[DEC-0292-admin-app-operation-single-entry]]"]
source: "https://github.com/Twin-Fang/passQL/issues/961"
---

# ISS-0495 완료 리포트: 앱 운영 화면에 결제 영역과 최소 버전 확인 창

GitHub #961 구현 보고 (2026-11-12). PR #969 머지(2026-11-12).

## 해결 방법
- 앱 운영 화면(`/admin/app-operation`)에 결제 영역: 결제 스위치, 미리보기 회원 추가·삭제, 켜기 전 점검표(Play 서비스 계정 키, 광고 서버 검증 단위 ID·필수 여부, 최소 버전, 미리보기 회원 수).
- 최소 버전 저장 전 확인 창: 변경 전후 값, 영향 안내, 서버 빌드 버전보다 높으면 미배포 버전 경고.
- 결제 스위치를 켤 때 점검표에서 빠진 항목을 확인 창에 함께 보인다(막지 않음).
- 일반 설정 표: 앱 운영 전용 키 10개는 읽기 전용 + 이동 링크, 비밀 설정은 값 대신 상태 배지.
- 저장은 감사 로그·변경 이력에 남는다.

## 근본 원인 (확정)
앱 운영 설정의 입구가 둘이었고 결제 준비 상태를 모아 보는 곳이 없었다.

## 재발 방지
- 앱 운영 전용 키는 일반 설정 표에서 읽기 전용이다.

## 교훈
- 검증: `./gradlew build` 통과(ArchitectureRuleTest 포함), `BillingOperationServiceTest` 5건. 화면을 실제로 띄워 확인하지 못했다(배포 후 운영 관리자에서 확인 필요).
- 남은 것: 앱 운영 화면의 공지 함수는 옛 `fetch`·`confirm` 그대로, 일반 설정 표의 "이 값으로 복원"은 전용 키에도 남아 있다.
