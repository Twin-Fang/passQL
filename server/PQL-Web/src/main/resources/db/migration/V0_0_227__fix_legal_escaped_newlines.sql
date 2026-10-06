-- 약관/개인정보처리방침 본문의 줄바꿈 보정.
-- V0_0_159 가 일반 문자열('...\n...')로 넣어 PostgreSQL 에 줄바꿈이 아니라 역슬래시+n 두 글자로 저장됐다.
-- 그 결과 앱·웹에서 "\n" 이 그대로 보이고 마크다운 제목(##)도 한 줄로 붙어 표시됐다.
-- 실제 줄바꿈으로 바꾼다. 이미 정상인 행은 바뀌지 않는다(멱등).
UPDATE legal
SET content    = replace(content, E'\\n', E'\n'),
    updated_at = now()
WHERE position(E'\\n' in content) > 0;
