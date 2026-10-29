---
type: issue
id: ISS-0236
created: 2026-10-07
topics: [store-release]
symptoms: ["약관 원본 3곳 불일치", "/api/meta/legal", "/legal/*.html", gh-pages, delete-account.html, "탈퇴 안내 경로 불일치", "모달 제목 약관", "재시도 없음"]
root_cause: "약관·개인정보처리방침 원본이 서버 API·Vercel 정적 페이지·gh-pages 세 곳에 따로 있었다"
status: resolved
resolution: "[[ISS-0236-legal-docs-three-sources-mismatch-report]]"
related: ["[[DEC-0105-legal-docs-single-source-server-db]]"]
source: "https://github.com/Twin-Fang/passQL/issues/403"
---

# ISS-0236: 약관·개인정보처리방침 원본 3곳 불일치와 탈퇴 안내 경로 불일치

GitHub #403 (원본: 이슈 본문과 완료 댓글).

## 증상
- 원본이 세 곳(서버 `/api/meta/legal`, Vercel `/legal/*.html`, gh-pages)에 있고 내용이 이미 다르다. gh-pages에는 시행일(2026-10-07)과 문의처가 있지만 Vercel 정적 페이지에는 없다.
- `delete-account.html`은 "하단 설정 탭 → 회원 탈퇴"로 안내하지만 웹은 마이페이지 톱니바퀴에서 진입. gh-pages에는 `delete-account.html`이 없다(404).
- 약관 API가 실패하면 개인정보처리방침을 눌러도 모달 제목이 "약관"이고 재시도 수단이 없다.

## 재현 조건
약관 API 500 상태에서 웹 로그인 모달의 개인정보처리방침 열기 (캡처 근거).

## 조사 기록
- 2026-10-07: 이슈 본문 — 원본을 하나로 정하고 나머지는 그곳을 가리키게 한다. 약관 문구는 법적 문서라 내용 결정은 담당자 확인 필요.

## 근본 원인
법적 문서 원본이 여러 곳에 복제돼 따로 관리됐다.
