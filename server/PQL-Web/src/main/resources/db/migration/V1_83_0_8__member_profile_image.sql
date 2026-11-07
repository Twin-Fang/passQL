-- 회원 소셜 프로필 이미지 (#908): 로그인 때 제공자 응답의 https 주소, 없거나 기본 이미지면 NULL
ALTER TABLE member ADD COLUMN IF NOT EXISTS profile_image_url VARCHAR(1000);
