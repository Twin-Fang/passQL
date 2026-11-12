# 최소 보안 헤더 (location 마다 add_header 를 쓰면 상위 헤더가 상속되지 않아 include 로 공통화)
add_header X-Content-Type-Options "nosniff" always;
add_header X-Frame-Options "SAMEORIGIN" always;
add_header Referrer-Policy "strict-origin-when-cross-origin" always;
