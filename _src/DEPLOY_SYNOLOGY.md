# passQL 소개 사이트 — 시놀로지 배포 (passql.suhsaechan.kr)

## 구조

```
브라우저 > Cloudflare DNS (CNAME, DNS 전용) > suh-project.synology.me
  > DSM 리버스 프록시 (80·443) > Traefik localhost:8079 > 컨테이너 passql-site (nginx:1.27-alpine :80)
```

api.passql.suhsaechan.kr 백엔드와 같은 경로다. 호스트 포트를 새로 열지 않았다.

| 구성 | 값 |
|---|---|
| DNS (Cloudflare suhsaechan.kr) | `passql`·`www.passql` CNAME > `suh-project.synology.me`, 프록시 꺼짐(DNS 전용), TTL 자동 |
| DSM 리버스 프록시 4개 | `passql`·`www.passql` 각각 443(HSTS, `X-Forwarded-Proto: https`) · 80(`X-Forwarded-Proto: http`) > `http://localhost:8079` (설명 `passQL-SITE ...`) |
| 인증서 (Let's Encrypt, DSM 자동 갱신) | `passql.suhsaechan.kr`(DSM id mYlOMK) · `www.passql.suhsaechan.kr`(OKUSU9), 443 규칙에 각각 연결 |
| Traefik 라우터 | `passql-site`: ``Host(`passql.suhsaechan.kr`) || Host(`www.passql.suhsaechan.kr`)`` (compose 라벨) |
| NAS 폴더 | `/volume1/projects/passql/site/` — `html/`(사이트), `nginx.conf`, `security-headers.inc`, `docker-compose.yml` |
| 원본 | 이 폴더의 `_src/synology/` (설정), `_src/site_verification/` (검색엔진 소유 확인 파일) |

nginx 가 처리하는 것: www > 루트 301, http > https 301, 404 > `/404.html`, gzip,
캐시(HTML 5분 · robots/sitemap 1시간 · css/js/이미지 7일), 보안 헤더(nosniff, SAMEORIGIN, Referrer-Policy).
HTTPS 종료와 HSTS 는 DSM 443 규칙이 맡는다.

## 재배포 (내용 바꿨을 때)

gh-pages 작업 트리 루트에서:

```bash
bash _src/synology/deploy_synology.sh
```

1. `python3 -I _src/build_site.py --out <임시폴더> --custom-domain` 로 새 주소 기준 사이트 생성
2. `_src/site_verification/*.html` 복사 (지우면 검색엔진 소유 확인이 풀림)
3. tar 묶음을 ssh(포트 2022, 계정 chan4760)로 보내 NAS 에서 풀고 `html/` 을 NAS 로컬 `rsync --delete` 로 맞춤
4. 공개 주소 4개 상태 코드 출력

- 비밀번호는 ssh 가 묻는다. 자동화할 때는 환경변수 `SSHPASS` 에 넣으면 `sshpass -e` 로 넘긴다(명령줄에 쓰지 않는다).
- html 은 읽기 전용 바인드 마운트라 컨테이너 재시작이 필요 없다.
- 맥에서 ssh 경유 `rsync` 를 직접 쓰지 않는 이유: 시놀로지가 rsync 앱 권한이 없는 계정의 rsync 접속을 인증 단계에서 거부한다(`Permission denied`).
- 이 NAS 는 맞는 비밀번호도 가끔 한 번씩 거부한다 > 스크립트가 최대 5회 재시도한다.

## 설정(nginx.conf · compose) 바꿨을 때

스크립트가 설정 파일도 올린다. 그다음 NAS 에서:

```bash
# nginx 설정만 바뀜
sudo /usr/local/bin/docker exec passql-site nginx -t && sudo /usr/local/bin/docker exec passql-site nginx -s reload
# compose(이미지·라벨·볼륨) 바뀜
cd /volume1/projects/passql/site && sudo /usr/local/bin/docker compose -p passql-site up -d
```

## 확인

```bash
curl -sI https://passql.suhsaechan.kr/                 # 200
curl -sI https://passql.suhsaechan.kr/sqld/schedule/   # 200
curl -sI https://passql.suhsaechan.kr/없는주소           # 404 (404.html 본문)
curl -sI https://www.passql.suhsaechan.kr/             # 301 > https://passql.suhsaechan.kr/
curl -sI http://passql.suhsaechan.kr/                  # 301 > https
```

## 검색엔진

- Google Search Console: URL 접두어 속성 `https://passql.suhsaechan.kr/` (chancamera123 계정). suhsaechan.kr 도메인 DNS 확인으로 자동 소유 확인됨. sitemap `https://passql.suhsaechan.kr/sitemap.xml` 제출.
- 네이버 서치어드바이저: 소유 확인 HTML 파일을 `_src/site_verification/` 에 넣고 재배포한 뒤 확인·사이트맵 제출.

## 되돌리기 (사이트 내리기)

```bash
cd /volume1/projects/passql/site && sudo /usr/local/bin/docker compose -p passql-site down
```

DSM 리버스 프록시 4개(설명 `passQL-SITE`)·인증서 2개·Cloudflare CNAME 2개는 각 관리 화면에서 지운다. 다른 서비스 규칙은 건드리지 않는다.
