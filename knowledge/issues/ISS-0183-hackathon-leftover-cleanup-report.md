---
type: completion-report
id: ISS-0183
created: 2026-10-07
topics: [dev-workflow]
status: resolved
resolves: "[[ISS-0183-hackathon-leftover-cleanup]]"
related: ["[[DEC-0093-untrack-ai-artifacts-and-hackathon-docs]]"]
source: "https://github.com/Twin-Fang/passQL/issues/338"
---

# ISS-0183 완료 리포트: 해커톤 문서·목업 삭제, AI 산출물·기획 문서 추적 해제, 문서 현행화, `DevPage` 삭제

GitHub #338 댓글(2026-10-02 1차, 2026-10-07 세 건) 기준.

## 해결 방법
- 1차(커밋 `e8e973d`, 사용자 승인 후 삭제): `docs/product/PASSQL-ROADMAP.md`, `client/public/ai-card-mockup.html`·`ai-result-mockup.html`, `docs/suh-template/` 하위 이슈/보고서 266개(git 히스토리·GitHub 이슈/PR에 남음). 루트 `CLAUDE.md` 산출물 경로 표를 `docs/projectops/`로 갱신.
- 의도적 유지: 이미 적용된 마이그레이션(`V0_0_44__add_schema_sample_data.sql` 등) — "수정/삭제하면 Flyway가 깨짐".
- 2026-10-07: 미사용 CI 워크플로우 수동 실행 전환(GitHub #336), 레포 조직 이전(GitHub #351), 구 앱 레포 폐기.
- 커밋 `2acdd33`, `5f7bbe0`: `.bak` 10개, AI 작업 산출물(`docs/superpowers`, `docs/projectops`, `client/docs/superpowers`, `app/docs/superpowers`), 해커톤 기획·분석 문서(`docs/product`, `docs/reports`, `client/docs`, `server/docs/apilog`)를 `.gitignore`로 추적 해제(로컬 파일 유지, git 기록에는 남음). README(샌드박스 Oracle→PostgreSQL, "계정 없이 UUID"→Google/Apple 로그인, 앱 추가, 해커톤 사업성 섹션 제거), `app/CLAUDE.md`, `app/docs/PRD.md`(디바이스 UUID → JWT 로그인 기준), 루트·client CLAUDE.md 문서 위치 표 현행화.
- 커밋 `802dee2`: 웹 `DevPage.tsx` 삭제(참조 주석 정리), `npm run build` 성공.

## 근본 원인 (확정)
해당 없음 (정리 작업).

## 재발 방지
삭제는 승인 후, 적용된 마이그레이션은 유지(원본 원칙).

## 교훈
원본에 적혀 있지 않다.
