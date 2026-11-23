---
type: issue
id: ISS-0547
created: 2026-11-23
topics: [question-bank, practice]
symptoms: ["기출 복원 너무 쉬움", "복원본보다 실제 시험이 어려움", "63회 기출 복원 없음", "63회 가채점 마감", "모두 고르기 부족", "하나만 다른 SQL", "보기 세트가 출제 기준 미달", "가져오기 갱신 후 공개 검사 실패", "그림 보기 번호 순서 섞임", "choiceFigures", "choiceTables"]
root_cause: "기출 복원 900문항이 공개 복원(문어CBT) 수준으로만 다시 쓰여 실제 시험보다 쉽고 단순했고, 63회 회차가 없었으며, 기존 문항 갱신 시 회차 문항이 옛 보기 세트를 계속 가리키는 구조였다"
status: resolved
resolution: "[[ISS-0547-past-exam-real-exam-level-rewrite-report]]"
related: ["[[ISS-0535-past-exam-restored-rounds]]", "[[ISS-0540-past-exam-figure-erd-generator]]", "[[ISS-0542-past-exam-grading-omr-link]]", "[[DEC-0328-past-exam-rewrite-operation-rules]]", "[[DEC-0350-past-exam-real-exam-level-standard]]", "[[DEC-0351-choice-order-fixed-and-round-choice-set-repoint]]", "[[LSN-0008-import-update-breaks-round-choice-set]]"]
source: "https://github.com/Twin-Fang/passQL/issues/1155"
capture_mode: "issue-end"
captured_at: "2026-11-23T21:49:53+09:00"
captured_by: "pro-brain"
project: "passql"
stacks: ["spring"]
app_version: "1.143.5"
build_number: 613
issue: 1155
issue_url: "https://github.com/Twin-Fang/passQL/issues/1155"
pr: 1173
pr_url: "https://github.com/Twin-Fang/passQL/pull/1173"
commit_base: "da0e47c33fa883eccb816a00fec19f891d7c4ee3"
commit_head: "f42961da69c37a049bafa27a4e5a1a4d1db27837"
commit_count: 4
merge_commit: "f9b0a37b24318b4275049cc5488951ded7166046"
changed_modules: ["docs", "tools", "server/PQL-Domain-Question", "server/PQL-Domain-Submission"]
lines_added: 1340
lines_deleted: 144
deployed: true
deploy_targets: ["server", "ai", "web", "play", "testflight"]
deploy_version: "1.144.0"
---

# ISS-0547: 기출 복원이 실제 시험보다 쉽고, 63회가 없고, 문항 갱신이 회차 보기를 깨뜨림 (#1155)

## 증상
- 앱 기출 복원(45~62회 900문항)이 공개 복원 수준이라 실제 시험보다 쉽다. 60회 응시자(사용자) 증언: 실제 2과목은 SQL이 길고 하나만 다른 SQL, 여러 문장 차례 실행, NULL 함정이 많다.
- 63회(2026-11-14) 기출 회차가 없고, 63회 가답안은 가채점을 받는 중이었다.
- 기존 문항을 관리자 가져오기로 갱신하자 회차 공개 검사가 "보기 세트가 출제 기준 미달" 50건으로 실패했다.

## 재현 조건
- 관리자 `/admin/questions/import` 에 questionUuid 를 넣어 회차에 들어간 문항을 갱신.
- 학습 모드에서 보기 글이 "관계선 그림 ②"처럼 번호가 뒤에 붙은 그림·표 보기 문항을 연다.

## 조사 기록
- 2026-11-18: 자료 수집(ego-browser): 문어CBT 45~63회 950문항(63회는 11-15 "전문가 검수" 공개, 우리 가답안과 49/50 일치), 카톡·네이버 카페·구글. sqld.kr 은 번호·주제 어긋남과 옛 투표가 남아 근거로 쓰지 않음.
- 2026-11-18: 63회 가채점 마감(OFFICIAL, 29번=2). 63회 기출 회차 신규 등록·공개.
- 2026-11-18: 1차(실제 형식) > 2차(난이도 상향) 19회차 다시 쓰기. 60회 갱신 직후 공개 검사 실패 발견 > 운영 DB 재연결로 복구(백업 `backup_1155_round_item_20261118`, 응시 0건이라 사용자 영향 없음).
- 2026-11-18: 타 사이트 대조(SQLD양파, yunamom 블로그, 카페)로 문어CBT가 원형과 다른 문항 10건과 단순화 흔적 약 120건 확인.
- 2026-11-21: 유형 조사(후기 135편, 복원 300문항 집계)로 2차 기준이 실제보다 과함을 확인 > 보정 기준 [[DEC-0350-past-exam-real-exam-level-standard]] > 보정판(v4) 19회차 반영.
- 2026-11-23: v1.144.0 배포 후 앱 실측에서 그림·표 보기 10문항 순서 섞임과 "위 그림" 문구 2건 발견 > 데이터 수정.

## 근본 원인
기출 복원 원재료(공개 복원)가 실제 시험을 단순화한 판이고 우리 1차 다시 쓰기도 그 수준을 따랐다. 서버는 회차 문항이 보기 세트를 고정 참조해, 가져오기로 보기 세트가 교체돼도 회차가 옛 세트를 가리켰다.
