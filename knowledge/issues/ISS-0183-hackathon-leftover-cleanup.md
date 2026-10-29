---
type: issue
id: ISS-0183
created: 2026-10-02
topics: [dev-workflow]
symptoms: ["해커톤 잔재", "목업 HTML", DevPage, ".bak 파일", "docs/suh-template", "정식 서비스 전환", "문서 현행화"]
root_cause: "해커톤/공모전 때 만든 문서·목업·샘플 데이터·개발용 화면이 레포에 남아 있음"
status: resolved
resolution: "[[ISS-0183-hackathon-leftover-cleanup-report]]"
related: ["[[DEC-0093-untrack-ai-artifacts-and-hackathon-docs]]"]
source: "https://github.com/Twin-Fang/passQL/issues/338"
---

# ISS-0183: 해커톤 잔재 정리 및 정식 서비스 기준 재정비

GitHub #338 (원본: 이슈 본문과 댓글 4개).

## 증상
(현재 문제점) 해커톤/공모전 목적의 문서, 목업, 샘플 데이터, 개발용 화면이 남아 있다. 이슈 본문 조건: 삭제는 대상 확정 후 사용자 승인, 이미 적용된 DB 마이그레이션은 절대 수정·삭제하지 않는다.

## 재현 조건
해당 없음.

## 조사 기록
- 2026-10-02 후보: `docs/suh-template/`, `docs/product/` 해커톤 일정, README 공모전 어필 포인트, `client/public/ai-card-mockup.html`·`ai-result-mockup.html`, 샘플 데이터 마이그레이션(`V0_0_44`, 삭제 금지·내용 확인만), 웹 `DevPage`(라우트 미등록), 미사용 워크플로우·`.bak`, `github-issues/`, `SUH-DEVOPS-TEMPLATE-SETUP-GUIDE.md`.
- 2026-10-02 1차(커밋 `e8e973d`) → 2026-10-07 진행 현황 → 커밋 `2acdd33`, `5f7bbe0` → 커밋 `802dee2`로 마무리.

## 근본 원인
해당 없음 (정리 작업).
