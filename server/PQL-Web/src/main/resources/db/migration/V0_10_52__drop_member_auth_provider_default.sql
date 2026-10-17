-- member.auth_provider 기본값 'ANONYMOUS' 제거 (#511)
-- ANONYMOUS 는 V0_0_155 에서 회원 정리 후 AuthProvider enum 에서도 빠짐 > 공급자 없이 들어온 행은 조회 시 enum 변환 오류(500)
-- 기본값 대신 NOT NULL 위반으로 저장 시점에 바로 실패하게 함 (앱은 가입 시 항상 공급자 지정, 데이터 변경 없음)
ALTER TABLE member ALTER COLUMN auth_provider DROP DEFAULT;
