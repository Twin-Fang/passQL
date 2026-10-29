---
type: issue
id: ISS-0226
created: 2026-10-07
topics: [admin]
symptoms: ["/admin/tags", TemplateInputException, "500", AdminTagController, "tags.html 없음"]
root_cause: "`AdminTagController`가 `admin/tags` 뷰를 반환하지만 `templates/admin/tags.html`이 없었다"
status: resolved
resolution: "[[ISS-0226-admin-tags-template-missing-500-report]]"
related: []
source: "https://github.com/Twin-Fang/passQL/issues/392"
---

# ISS-0226: `/admin/tags` 접근 시 템플릿이 없어 500 오류

GitHub #392 (원본: 이슈 본문과 댓글 2개).

## 증상
메뉴에는 없지만 `/admin/tags`로 직접 들어가면 `TemplateInputException`으로 500.

## 재현 조건
관리자 로그인 후 `/admin/tags` 접속 (이슈 작성 시점은 코드 근거, 로그인 실측 보류).

## 조사 기록
- 2026-10-07: `AdminTagController.java:20` `return "admin/tags";`, `templates/admin/`에 `tags.html` 없음.

## 근본 원인
반환하는 뷰 이름에 해당하는 템플릿이 없었다.
