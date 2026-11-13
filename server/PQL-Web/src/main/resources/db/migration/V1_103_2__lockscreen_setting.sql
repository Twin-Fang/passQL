-- 잠금화면 문제 풀기 설정 (#990, Android 앱 잠금화면 위 문제 1개)
--    lockscreen.enabled: BOOLEAN, 기본 꺼짐 (꺼지면 앱 메뉴 숨김, GET /api/questions/lockscreen 204)
--    lockscreen.default_interval_minutes: INT, 기본 30 (앱 기본 표시 간격, 사용자가 바꾸기 전 값)
--    lockscreen.include_executable: BOOLEAN, 기본 켜짐 (false 면 실행형 SQL 문제 출제 안 함)
INSERT INTO app_setting (app_setting_uuid, setting_key, value_type, value_text, category, description)
VALUES
    (gen_random_uuid(), 'lockscreen.enabled', 'BOOLEAN', 'false',
     'LOCKSCREEN', '잠금화면 문제 풀기 전체 사용 여부 (true 앱 메뉴 노출·출제, false 메뉴 숨김·출제 안 함)'),
    (gen_random_uuid(), 'lockscreen.default_interval_minutes', 'INT', '30',
     'LOCKSCREEN', '잠금화면 문제 기본 표시 간격 (분, 마지막 표시 후 최소 간격, 사용자가 앱에서 바꾸기 전 값)'),
    (gen_random_uuid(), 'lockscreen.include_executable', 'BOOLEAN', 'true',
     'LOCKSCREEN', '잠금화면 문제에 실행형 SQL 문제 포함 여부 (true 객관식·실행형 모두, false 객관식만)')
ON CONFLICT (setting_key) DO NOTHING;
