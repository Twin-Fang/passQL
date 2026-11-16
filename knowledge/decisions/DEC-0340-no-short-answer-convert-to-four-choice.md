---
type: decision
id: DEC-0340
created: 2026-11-16
reviewed: null
topics: [question-bank, practice]
status: active
supersedes: null
superseded_by: null
related: ["[[ISS-0535-past-exam-restored-rounds]]", "[[ISS-0540-past-exam-figure-erd-generator]]", "[[DEC-0328-past-exam-rewrite-operation-rules]]"]
---

# DEC-0340: 단답형 문항 유형은 만들지 않고, 기출 복원 단답형 문항은 같은 개념의 4지선다로 바꿔 넣는다

GitHub #1085 (취소, 닫기 댓글), #1079.

## 문제 정의 (Context)
passQL 은 객관식만 지원한다. 기출 복원 900문항 중 60문항(45~49회)이 단답형(함수 결과 값 쓰기, 용어 쓰기)이라 그대로는 담을 수 없었다([[ISS-0535-past-exam-restored-rounds]]). #1085 는 단답형 유형 추가(정답 후보 여러 개 허용 채점, SQL 결과 값은 샌드박스 검증)를 제안했다.

## 결정 (Decision)
- 단답형 유형을 지원하지 않는다. 기출 복원 45~49회의 단답형 60문항은 같은 개념의 4지선다로 바꿔 등록했다(#1079).
- #1085 는 `취소` 라벨로 닫았다.

## 검토한 대안 (Alternatives)
- **단답형 유형 추가(#1085 제안):** 2024 개정 이후 SQLD 에는 단답형이 없어 4지선다가 실제 시험 형식과 같고, 단답형이 필요한 콘텐츠가 남지 않아 취소(닫기 댓글).

## 결과 (Consequences)
**긍정**
- 문항 유형·채점·입력 UI 를 새로 만들지 않고 실제 시험 형식(4지선다)과 맞춘다.

**부정**
- 2024 개정 전 회차(45~49회)의 단답형은 원래 형식과 다르게 풀게 된다. 영향은 논의 기록 없음.

## 영향 범위 (Scope)
기출 복원 45~49회 문항 데이터(연구 폴더 YAML·운영 등록). 서버·앱 문항 유형은 바꾸지 않음.

## 출처 (References)
- 닫기 댓글 https://github.com/Twin-Fang/passQL/issues/1085#issuecomment-6907794672
- 이슈 https://github.com/Twin-Fang/passQL/issues/1085

## W4 검사
- [[DEC-0328-past-exam-rewrite-operation-rules]](기출 복원 다시 쓰기 규칙): 다시 쓰기 범위 안의 형식 변환이라 충돌 없음.
- 문항 유형에 관한 다른 활성 결정(검색 "단답", "4지선다", "문항 유형")에서 단답형을 정한 결정 없음 — 충돌 없음.
