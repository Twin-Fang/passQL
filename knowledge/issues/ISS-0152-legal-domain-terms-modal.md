---
type: issue
id: ISS-0152
created: 2026-04-24
topics: [store-release, auth-member, admin]
symptoms: ["약관 내용 확인 불가", "정적 약관 문구", AppSetting, "약관 key-value 혼재", Login.tsx, legal]
root_cause: "로그인 화면 약관 문구가 정적 텍스트뿐이고, 약관 콘텐츠가 `AppSetting` key-value에 섞여 있음"
status: resolved
resolution: "[[ISS-0152-legal-domain-terms-modal-report]]"
related: ["[[DEC-0082-legal-table-separate-from-app-setting]]"]
source: "https://github.com/Twin-Fang/passQL/issues/283"
---

# ISS-0152: 로그인 화면에서 약관 내용을 볼 수 없고 약관이 시스템 설정에 섞여 있음

GitHub #283 (원본: 이슈 본문과 댓글 2개).

## 증상
로그인 하단 "로그인하면 이용약관 및 개인정보처리방침에 동의하게 됩니다"가 정적 문구뿐이라 약관 내용을 확인할 방법이 없다. 약관 콘텐츠는 `AppSetting` 테이블 key-value에 저장돼 시스템 설정과 도메인이 혼재한다.

## 재현 조건
로그인 화면에서 약관 문구 확인.

## 조사 기록
- 2026-04-24: 제안 — 약관 링크 + daisyUI `modal-bottom sm:modal-middle` 모달, `legal` 테이블 분리와 관리자 편집.

## 근본 원인
약관 전용 도메인이 없었다.
