-- 선택지 세트 단위 구조화 AI 해설 (#521)
-- 보기마다 4번 부르던 해설을 세트당 1번(구조화 JSON)으로 묶고, 생성 상태를 저장해 조회는 기다리지 않고 바로 응답
-- explanation_status: GENERATING 생성 중, READY 저장본 있음, FAILED 생성 실패 (NULL: 아직 요청 없음)
ALTER TABLE question_choice_set ADD COLUMN IF NOT EXISTS explanation_json TEXT;
ALTER TABLE question_choice_set ADD COLUMN IF NOT EXISTS explanation_prompt_version INT;
ALTER TABLE question_choice_set ADD COLUMN IF NOT EXISTS explanation_status VARCHAR(20);
ALTER TABLE question_choice_set ADD COLUMN IF NOT EXISTS explanation_status_changed_at TIMESTAMP(6);
ALTER TABLE question_choice_set ADD COLUMN IF NOT EXISTS explanation_attempt_count INT;
