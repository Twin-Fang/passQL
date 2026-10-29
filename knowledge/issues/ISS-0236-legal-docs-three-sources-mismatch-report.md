---
type: completion-report
id: ISS-0236
created: 2026-10-08
topics: [store-release]
status: resolved
resolves: "[[ISS-0236-legal-docs-three-sources-mismatch]]"
related: ["[[DEC-0105-legal-docs-single-source-server-db]]"]
source: "https://github.com/Twin-Fang/passQL/issues/403"
---

# ISS-0236 완료 리포트: 약관 원본을 서버 DB 하나로, 정적 페이지는 API 본문으로 렌더

GitHub #403 완료 댓글 기준 (PR #426, gh-pages #427). `## 개요` 형식 리포트는 없음.

## 해결 방법
| 위치 | 전 | 후 |
|---|---|---|
| Vercel `/legal/*.html` | 별도 사본 | 열릴 때 API 본문으로 렌더(HTML 이스케이프), 실패 시 사본 + 다시 시도 |
| 웹 로그인 모달 | 실패 시 제목 "약관", 재시도 없음 | 문서별 제목, 다시 시도 버튼 |
| `delete-account.html` | "하단 설정 탭 → 회원 탈퇴" | 앱 실제 경로(설정 탭 → 계정 → 회원 탈퇴). 웹은 탈퇴 메뉴가 없어 앱·이메일 안내 |
| gh-pages | `delete-account.html` 404 | 같은 안내로 추가 (GitHub #404) |

운영 DB 문구 수정(관리자 화면, 변경 전 원문 백업 보관): 개인정보처리방침 5항의 탈퇴 경로를 "앱의 설정 탭 > 계정 > 회원 탈퇴에서 직접 처리하거나 (문의 이메일)으로"로 변경, 두 문서 끝에 `## 부칙` 시행일 2026-10-07 추가.

## 근본 원인 (확정)
원본이 세 곳에 복제돼 있었다.

## 재발 방지
운영 확인: `/legal/privacy.html`·`terms.html`이 부칙 포함 DB 본문으로 표시, 모달 제목 "개인정보처리방침", 콘솔 오류 0. 남은 것: 웹에 회원 탈퇴 기능 없음(필요 시 별도 기능), 스토어 콘솔에 등록된 약관 URL은 직접 확인 필요.

## 교훈
(원본에 없음, 볼트 정리) 약관 문구를 바꿀 때는 관리자 `/admin/legal`(서버 DB)만 고친다. 정적 사본은 API 실패 시 대체용이다.
