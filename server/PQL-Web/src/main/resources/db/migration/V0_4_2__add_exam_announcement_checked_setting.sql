-- 시험 일정 공식 공고를 마지막으로 확인한 날짜 (#411). 빈 값이면 "확인 기록 없음"으로 표시한다.
INSERT INTO app_setting (app_setting_uuid, setting_key, value_type, value_text, category, description)
VALUES
    (gen_random_uuid(), 'exam.announcement_checked_at', 'STRING', '', 'EXAM', '시험 일정 공식 공고를 마지막으로 확인한 날짜 (관리자 > 시험 일정에서 기록)')
ON CONFLICT (setting_key) DO NOTHING;
