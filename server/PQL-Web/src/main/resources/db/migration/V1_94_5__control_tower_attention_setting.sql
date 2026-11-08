-- 관제소 확인할 일 연동 켜기/끄기 (#959)
--    control_tower.attention.enabled: BOOLEAN, 기본 꺼짐 (꺼지면 GET /control/attention 404)
--    수집 토큰은 DB 가 아니라 설정 파일·환경변수(CONTROL_TOWER_ATTENTION_TOKEN)로만 관리
INSERT INTO app_setting (app_setting_uuid, setting_key, value_type, value_text, category, description)
VALUES
    (gen_random_uuid(), 'control_tower.attention.enabled', 'BOOLEAN', 'false',
     'CONTROL_TOWER', '관제소 확인할 일 연동 사용 여부 (true 수집 응답, false 연동 꺼짐 404, 건의사항 관리 화면에서 전환)')
ON CONFLICT (setting_key) DO NOTHING;
