---
type: issue
id: ISS-0017
created: 2026-04-08
topics: [design-system]
symptoms: ["Design.md 불일치", "Linear 다크 모드", "라이트 모드", "잘못된 색상 폰트", "토큰 동기화"]
root_cause: "`.claude/rules/Design.md`에 Linear 다크 모드 디자인 시스템이 그대로 들어 있어 라이트 모드 실제 구현과 불일치했다"
status: resolved
resolution: "[[ISS-0017-design-md-light-design-system-report]]"
related: ["[[DEC-0022-design-md-single-source-of-truth]]"]
source: "https://github.com/Twin-Fang/passQL/issues/20"
---

# ISS-0017: Design.md 기반 디자인 시스템 정비 및 적용

GitHub #20 (원본: 이슈 본문과 댓글).

## 증상
`.claude/rules/Design.md`에 Linear 다크 모드 디자인 시스템이 그대로 있어 passQL 실제 구현(라이트 모드)과 맞지 않았다. 디자인 룰 문서가 실제 토큰/컴포넌트와 동기화되지 않아 코드 생성 시 잘못된 색상/폰트가 적용될 수 있었다.

## 재현 조건
Design.md를 참조해 코드를 생성하면 다크 모드 색상/폰트가 적용될 수 있음 (이슈 본문).

## 조사 기록
- 2026-04-08: 백엔드 담당이 Design.md 참고 자료(VoltAgent awesome-design-md 컬렉션) 링크 공유.
- 2026-04-08: 프론트 담당 작업 보고 (아래 리포트).
- 2026-04-22: 백엔드 담당 작업 완료 보고 — daisyUI 컴포넌트 클래스 전면 적용(GitHub #167, #175, #179, #183), card-base 커스텀 CSS → Tailwind 유틸리티(GitHub #187), 에러 상태 UI 개선(GitHub #190).

## 근본 원인
디자인 룰 문서를 외부 다크 모드 시스템에서 가져온 채 프로젝트 실제 값으로 바꾸지 않았다 (이슈 본문).
