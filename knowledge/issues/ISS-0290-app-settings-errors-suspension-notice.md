---
type: issue
id: ISS-0290
created: 2026-10-15
topics: [auth-member]
symptoms: [닉네임 재생성 실패 안내 없음, 앱 버전 행 사라짐, "/members/me 실패", MEMBER_SUSPENDED 처리 흐름 없음, 제재 회원 안내]
root_cause: "닉네임 재생성 실패를 알리지 않았고, 앱 버전 행이 `/members/me` 데이터 안에 있었으며, 403 `MEMBER_SUSPENDED`는 매핑만 있고 처리 흐름이 없었다"
status: resolved
resolution: "[[ISS-0290-app-settings-errors-suspension-notice-report]]"
related: ["[[ISS-0276-suspended-member-blocked-only-in-getme]]", "[[DEC-0126-suspended-member-common-filter]]"]
source: "https://github.com/Twin-Fang/passQL/issues/484"
---

# ISS-0290: 앱 설정 화면 오류 처리 누락과 제재 회원 안내 부재

GitHub #484 (원본: 이슈 본문, 구현 보고서 댓글).

## 증상
- 닉네임 재생성 실패 시 안내가 없음.
- `/members/me` 실패 시 앱 버전 행이 사라짐.
- 403 `MEMBER_SUSPENDED`는 매핑만 있고 처리 흐름이 없음.
- 위치: `app/lib/presentation/pages/settings/settings_page.dart:109,162`, `providers/settings_providers.dart:34-35`, `core/error/error_code.dart:16,57`.

## 재현 조건
설정 화면에서 닉네임 재생성 실패, 네트워크 실패로 `/members/me` 조회 실패, 제재 회원이 API 호출.

## 조사 기록
- 2026-10-15: 예상 동작 — 재생성 실패 토스트, 버전은 PackageInfo 전용 provider로 분리, 제재 코드 수신 시 공통 지점에서 안내 화면 후 로그아웃. 서버 쪽은 GitHub #470.

## 근본 원인
frontmatter `root_cause`와 같음.
