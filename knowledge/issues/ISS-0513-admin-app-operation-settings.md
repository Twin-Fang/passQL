---
type: issue
id: ISS-0513
created: 2026-11-11
topics: [admin, billing, ads]
symptoms: ["최소 버전을 두 화면에서 편집", "일반 설정 표에 최소 버전 키", "결제 켜기 전 점검표 없음", "비밀 설정 미설정 문구가 값처럼 보임", "스토어에 없는 버전으로 최소 버전", /admin/app-operation, /admin/settings, app.minimum_version, app.recommended_version, billing.play_service_account_json]
root_cause: "앱 운영 설정(최소·권장 버전, 결제 켜기 준비)이 앱 운영 화면과 일반 설정 표에 나뉘어 있고, 결제 준비 상태를 한눈에 보는 곳과 최소 버전 변경의 영향 안내가 없었다"
status: resolved
resolution: "[[ISS-0513-admin-app-operation-settings-report]]"
related: ["[[DEC-0308-admin-app-operation-single-entry]]", "[[ISS-0512-test-build-minimum-version-block]]", "[[ISS-0361-billing-switch-final-checks]]", "[[DEC-0026-sensitive-settings-masked-readonly]]"]
source: "https://github.com/Twin-Fang/passQL/issues/961"
---

# ISS-0513: 관리자 앱 운영 설정 화면 정리 (최소 버전, 결제 켜기 점검을 한 곳에서)

GitHub #961. 관련 #596([[ISS-0361-billing-switch-final-checks]]), #941, #624.

## 증상
2026-11-11 결제 켜기 전 점검 중 최소 지원 버전을 올리다가 겪은 불편.
- 최소·권장 버전 키가 `/admin/app-operation` 전용 화면과 일반 설정 표(`/admin/settings`)에 함께 보여 어느 쪽이 정식 입구인지 알 수 없다. 이번에도 일반 설정 표에서 바꿨다.
- 일반 설정 표는 카테고리 9개에 키가 길고, 값 하나 바꾸는 데 찾기·연필·입력·저장을 매번 거친다.
- 결제 켜기 전 볼 설정(결제 스위치, 미리보기 회원, Play 서비스 계정 키, 광고 서버 검증 필수·단위 ID)이 흩어져 있어, 서비스 계정 키와 광고 단위 ID가 비어 있다는 것을 점검 중에야 알았다.
- 비밀 설정(`billing.play_service_account_json`) 값 칸에 "미설정" 문구가 값처럼 들어 있어 설정된 것으로 한 번 잘못 읽었다.
- 최소 버전을 올릴 때 영향(그 버전 미만 사용 불가)과 스토어 공개 최신 버전을 보여 주는 곳이 없다. 스토어에 없는 버전으로 올리면 전원이 차단된다.

## 재현 조건
운영 관리자에서 최소 버전 변경, 결제 켜기 전 점검.

## 조사 기록
- 하지 않는 것(이슈 본문): 설정 키 이름 변경(#596에서 따로), 설정 변경 이력·롤백 신규 구현(#624 범위).

## 근본 원인
앱 운영 설정의 입구가 둘이고, 결제 준비 상태와 최소 버전 변경 영향을 보여 주는 곳이 없었다.
