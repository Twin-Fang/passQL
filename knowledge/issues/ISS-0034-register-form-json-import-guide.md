---
type: issue
id: ISS-0034
created: 2026-04-09
topics: [admin, question-bank]
symptoms: ["문제 직접 등록 반복 입력", "JSON 불러오기", "등록 가이드 없음", topicCode, "AI 변환 프롬프트"]
root_cause: "직접 등록 폼을 필드마다 수동 입력해야 했고 topicCode·difficulty·executionMode 입력 가이드가 없었다"
status: resolved
resolution: "[[ISS-0034-register-form-json-import-guide-report]]"
related: []
source: "https://github.com/Twin-Fang/passQL/issues/49"
---

# ISS-0034: 문제 직접 등록 폼 JSON 불러오기와 등록 가이드

GitHub #49 (원본: 이슈 본문과 댓글).

## 증상
직접 등록 폼(`/admin/questions/register`)은 데이터를 수동 입력해야 해 반복 작업이 많았다. SQLD 문제 MD 파일 보유자도 각 필드를 하나씩 채워야 했고, topicCode 목록·difficulty 기준·executionMode 판단 기준 가이드가 없어 다른 팀원이 등록하기 어려웠다.
제안: JSON 파일 불러오기, JSON 붙여넣기 모달, 등록 가이드 모달(topicCode 표는 Thymeleaf `${topics}` 동적), 가이드 MD 다운로드(`/docs/question-register-guide.md`), AI 변환 프롬프트 복사(Clipboard API + execCommand fallback). `applyJson()`(topicCode → UUID 매핑), `topicSelect` option `data-code`.

## 재현 조건
해당 없음 (기능 이슈).

## 조사 기록
- 2026-04-09: 화면 캡처 4장과 "문제를 빠르게 만들수있습니다" 댓글.

## 근본 원인
해당 없음 (기능 이슈).
