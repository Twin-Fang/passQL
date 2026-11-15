---
type: completion-report
id: ISS-0526
created: 2026-11-16
topics: [question-bank, admin]
status: resolved
resolves: "[[ISS-0526-question-internal-tags]]"
related: ["[[DEC-0324-question-internal-tag-namespace-format]]", "[[DEC-0325-import-without-internal-tags-keeps-existing]]", "[[ISS-0527-sqld-round63-batch07-internal-tags]]"]
source: "https://github.com/Twin-Fang/passQL/issues/1117#issuecomment-6903013598"
---

# ISS-0526 완료 리포트: 문제 내부 관리 태그 추가, 서버 배포, 운영 213건 백필

PR #1120 머지 · 릴리스 #1121 (서버만, 앱 심사 없음)

## 해결 방법
- `question_internal_tag` 테이블(문제·태그 쌍 1행, `UNIQUE(question_uuid, tag)`, 앞부분 일치용 `varchar_pattern_ops` 인덱스), 엔티티·저장소.
- `QuestionInternalTagRule`: 정규화(앞뒤 공백 제거, 영문만 소문자), 검증(64자, 공백·`*`·쉼표 금지, 네임스페이스·값 빈칸 금지, 문제당 20개), 필터 해석(끝 `*` = 앞부분 일치). 가져오기·1건 교체·일괄·필터가 모두 거친다. 하네스 `internal_tags.py`가 같은 규칙.
- API: `PUT /admin/questions/{uuid}/internal-tags`, `PUT /admin/questions/internal-tags`(`addTags`/`removeTags`), `GET /admin/questions/internal-tags/summary`. 사용자 API(`/api/**`) 미노출.
- 운영: 요약 API 200, 기존 213건 백필 changed 213 실패 0.

## 근본 원인 (확정)
가져오기 형식(`QuestionExportDto`)과 운영 스키마에 출처·유형 메타데이터 자리가 없었다.

## 재발 방지
- 서버 규칙과 하네스 규칙은 사본 관계: 길이·금지 문자·개수를 바꾸면 두 곳을 함께 고친다.
- 칸 없는 옛 파일로 갱신하면 태그 유지, 지우려면 `internalTags: []` 명시([[DEC-0325-import-without-internal-tags-keeps-existing]]). 이 분기(`replaceInternalTagsIfPresent`)를 바꾸면 옛 내보내기 파일 재가져오기로 운영 태그가 전부 지워질 수 있다.

## 교훈
문제 출처·유형을 찾을 때는 관리자 목록 태그 필터(`source:63-*`, `trend:t41`)를 먼저 쓴다. 태그 되돌리기는 일괄 API `removeTags`.
