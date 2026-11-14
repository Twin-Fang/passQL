# -*- coding: utf-8 -*-
"""소개 사이트 문구·주소 단일 원본 (#505, #650, #1027): build_site.py 가 읽어 페이지·sitemap·JSON-LD 생성
문제 총 개수·"N문제 이상" 같은 문제 은행 규모 수치는 쓰지 않음 (#636, #660)
학습 콘텐츠(개념 글·문제) 원문은 싣지 않음 — 공개 시험 정보와 앱 소개만 (#1027)
"""

from urllib.parse import urlparse

# 사이트 주소 2개: 지금 GitHub Pages 기본 주소, 이전할 보유 도메인 (#1027)
GITHUB_PAGES_SITE_URL = "https://twin-fang.github.io/passQL/"
CUSTOM_DOMAIN_HOST = "passql.suhsaechan.kr"
CUSTOM_DOMAIN_SITE_URL = f"https://{CUSTOM_DOMAIN_HOST}/"
# GitHub Pages 커스텀 도메인 스위치: True 면 gh-pages 루트에 CNAME 파일까지 생성
# 시놀로지 직접 서빙은 이 값과 무관하게 build_site.py --out <폴더> --custom-domain 으로 생성 (CNAME 없음)
IS_CUSTOM_DOMAIN_ACTIVE = False
SITE_URL = CUSTOM_DOMAIN_SITE_URL if IS_CUSTOM_DOMAIN_ACTIVE else GITHUB_PAGES_SITE_URL
# 사이트 루트 경로: 404 처럼 깊이를 모르는 페이지의 절대 경로 기준 ("/passQL/" 또는 "/")
SITE_ROOT_PATH = urlparse(SITE_URL).path
APP_STORE_URL = "https://apps.apple.com/kr/app/passql/id6762165005"
APP_STORE_ID = "6762165005"
# Play 공개 여부 (#353 비공개 테스트 > 2026-11 공개 확인, #823): 배지·JSON-LD 설치 주소·FAQ 가 함께 바뀜
IS_PLAY_STORE_PUBLIC = True
PLAY_STORE_URL = "https://play.google.com/store/apps/details?id=com.coldredrice.passql"
OFFICIAL_EXAM_URL = "https://www.dataq.or.kr"
# 공식 시험 일정·원서접수 페이지
OFFICIAL_SCHEDULE_URL = "https://www.dataq.or.kr/www/accept/schedule.do"
CONTACT_EMAIL = "chan4760@naver.com"
# 운영 API 주소 (빌드 시 약관·가답안 스냅샷 읽기, 가채점 페이지 브라우저 호출 공용)
API_BASE_URL = "https://api.passql.suhsaechan.kr"
# 법적 문구 원본: 운영 DB legal 테이블 (관리자 > 약관 관리에서 수정) > 빌드 시 이 API 로 읽음
LEGAL_API_URL = API_BASE_URL + "/api/meta/legal/"
OG_IMAGE_URL = SITE_URL + "icon/og.png"


def apply_site_url(site_url):
    """빌드 중 사이트 주소 교체 (--custom-domain): 주소에서 나오는 값 3개를 함께 바꿈"""
    global SITE_URL, SITE_ROOT_PATH, OG_IMAGE_URL
    SITE_URL = site_url
    SITE_ROOT_PATH = urlparse(site_url).path
    OG_IMAGE_URL = site_url + "icon/og.png"

# 운영자 표기 (푸터·JSON-LD). 빈 값이면 그 줄을 렌더하지 않음, 주소는 표기하지 않음
# 앱·웹 원본(서버 app_setting business.*, #658)과 같은 값 유지
OPERATOR_BUSINESS_NAME = "콜리랩(KOLLYLAB)"
OPERATOR_REPRESENTATIVE_NAME = "서새찬"
OPERATOR_BUSINESS_REGISTRATION_NUMBER = "331-37-01670"
# 통신판매업 신고번호 (강남구청 2026-10-30 발급)
OPERATOR_MAIL_ORDER_SALES_NUMBER = "제2026-서울강남-06142호"

# ── SQLD 시험 일정 (2026 공식 공고 값) ──
# 첫 화면 D-day·일정 페이지·Event JSON-LD 가 함께 읽음. 다음 시험은 빌드 날짜 기준으로 고름(site_schedule.py)
# 서버 수집 API(GET /api/exam-schedules/sqld, #991)가 공개 응답이 되면 빌드 시 그 값으로 대체 가능
SQLD_EXAM_YEAR = 2026
SQLD_EXAM_ROUNDS = [
    {"round": 60, "application_start": "2026-02-02", "application_end": "2026-02-06", "admission_ticket": "2026-02-20",
     "exam": "2026-03-07", "score_preview_start": "2026-03-20", "score_preview_end": "2026-03-24", "result": "2026-03-27"},
    {"round": 61, "application_start": "2026-04-27", "application_end": "2026-05-01", "admission_ticket": "2026-05-15",
     "exam": "2026-05-31", "score_preview_start": "2026-06-12", "score_preview_end": "2026-06-16", "result": "2026-06-19"},
    {"round": 62, "application_start": "2026-07-20", "application_end": "2026-07-24", "admission_ticket": "2026-08-07",
     "exam": "2026-08-22", "score_preview_start": "2026-09-04", "score_preview_end": "2026-09-08", "result": "2026-09-11"},
    {"round": 63, "application_start": "2026-10-12", "application_end": "2026-10-16", "admission_ticket": "2026-10-30",
     "exam": "2026-11-14", "score_preview_start": "2026-11-27", "score_preview_end": "2026-12-01", "result": "2026-12-04"},
]
# 일정 단계: (키, 이름, 아이콘) — 기간 단계는 *_start·*_end 두 키
SQLD_SCHEDULE_STEPS = [
    ("application", "원서접수", "how_to_reg"),
    ("admission_ticket", "수험표 발급", "description"),
    ("exam", "시험일", "edit_note"),
    ("score_preview", "사전점수 공개", "fact_check"),
    ("result", "합격자 발표", "verified"),
]

# 무료·Pro 비교 노출 여부: 운영 결제 스위치(app_settings billing.android.enabled)와 맞춤
# False = 결제 꺼짐 > 비교표 대신 "지금 모든 기능 무료" 안내 (#823). 가격은 스토어가 정하므로 숫자를 쓰지 않음
# 운영 GET /api/meta/app-config isAndroidBillingEnabled: true 확인 (#1027)
IS_PRO_PLAN_VISIBLE = True

# 시험 범위: 운영 API /api/meta/topics 의 주제 9개 (sortOrder 순), 주제 설명은 일반 시험 범위 수준 (#1027)
# 과락 = 과목 배점의 40% 미만 (1과목 20점 중 8점, 2과목 80점 중 32점)
SQLD_SUBJECTS = [
    {
        "name": "1과목 · 데이터 모델링의 이해",
        "question_count": 10, "points": 20, "fail_under_points": 8,
        "chapters": ["데이터 모델링의 이해", "데이터 모델과 SQL"],
        "topics": [
            ("데이터 모델링", "엔터티·속성·관계·식별자를 구분하고, 정규화가 데이터 정합성과 SQL에 주는 영향을 이해해요."),
        ],
    },
    {
        "name": "2과목 · SQL 기본 및 활용",
        "question_count": 40, "points": 80, "fail_under_points": 32,
        "chapters": ["SQL 기본", "SQL 활용", "관리 구문"],
        "topics": [
            ("SELECT 기본", "SELECT·FROM·WHERE·ORDER BY 기본 문법, 연산자 우선순위, NULL 비교와 정렬 순서."),
            ("DDL / DML / TCL", "테이블을 만들고 바꾸는 DDL, 데이터를 넣고 고치는 DML, COMMIT·ROLLBACK 트랜잭션 제어."),
            ("SQL 함수", "문자·숫자·날짜 함수와 형 변환, NVL·COALESCE·CASE 같은 NULL·조건 처리 함수."),
            ("JOIN", "INNER·OUTER·CROSS·NATURAL JOIN과 조인 조건, 표준(ANSI) 조인 문법."),
            ("서브쿼리", "WHERE·FROM·SELECT 절 서브쿼리, 단일 행·다중 행 비교, IN·EXISTS, 인라인 뷰."),
            ("그룹함수 / 집계", "GROUP BY·HAVING, 집계 함수의 NULL 처리, ROLLUP·CUBE·GROUPING SETS."),
            ("윈도우 함수", "RANK·DENSE_RANK·ROW_NUMBER 순위, 누적 합계, LAG·LEAD 같은 행 순서 함수."),
            ("계층 / PIVOT", "START WITH·CONNECT BY 계층 쿼리와 PIVOT·UNPIVOT 행열 전환."),
        ],
    },
]

# 시험 기본 정보 (합격 기준 페이지·첫 화면 요약): (아이콘, 항목, 값, 보조 설명)
SQLD_EXAM_FACTS = [
    ("timer", "시험 시간", "90분", "필기 객관식 한 번"),
    ("quiz", "문항 수", "50문항", "1과목 10 · 2과목 40"),
    ("checklist", "배점", "문항당 2점", "100점 만점"),
    ("verified", "합격", "60점 이상", "과목별 과락이 없을 때"),
    ("flag", "과락", "8점 · 32점 미만", "1과목 · 2과목 각 40% 미만"),
    ("payments", "응시료", "50,000원", "회차마다 같은 금액"),
    ("person", "응시 자격", "제한 없음", "학력·전공·경력 무관"),
]
SQLD_EXAM_FEE_WON = 50000
# 합격 계산 예시: (1과목 맞힌 수, 2과목 맞힌 수) — 점수·판정은 생성 시 계산
PASS_EXAMPLES = [(4, 26), (3, 30), (10, 20), (5, 20)]
# ── 첫 화면 ──
HOME_TITLE = "SQLD 문제 풀이 앱 passQL — 교재 없이 앱 하나로 SQLD 준비"
HOME_DESCRIPTION = ("교재 없이 앱 하나로 SQLD 준비. 최신 기출 경향 문제를 풀고 보기 SQL을 직접 실행해 보고, "
                    "틀린 이유는 AI 해설로 확인하세요. 오늘의 세트, 모의고사 체험, 시험 일정 알림은 무료로 시작.")

HERO_EYEBROW = "SQLD 자격증 문제 풀이 앱"
HERO_TITLE_LEAD = "교재 없이,"
HERO_TITLE_HIGHLIGHT = "앱 하나로"
HERO_TITLE_TAIL = "SQLD 준비"
# 아래 흐름 구간(STORY_STEPS)과 같은 기능 나열을 반복하지 않게 한 줄 요약만 (#1062)
HERO_LEAD = "외우지 말고, 실행해 보고 이해하는 SQLD. 무료로 시작해서 매일 조금씩 합격 준비도를 채워요."
# 첫 화면 핵심 3개: (아이콘, 문구)
HERO_POINTS = [
    ("local_fire_department", "매일 5문제 오늘의 세트"),
    ("trending_up", "제58~63회 기출 경향 반영"),
    ("auto_awesome", "틀린 이유까지 AI 해설"),
]
HERO_STORE_NOTE = "무료로 시작해요 · 소셜 계정으로 바로 로그인 · iPhone과 Android에서 같은 기록"

# ── 첫 화면 앱 재생 (site_demo.py): 실제 앱 문제 풀이 화면 재현 ──
# 문제 1개: (과목·단원, 질문, [(보기 기호, SQL 두 줄)], 정답 실행 결과 행, AI 해설)
DEMO_QUESTION_CATEGORY = "SQLD 2과목 · SQL 기본"
DEMO_QUESTION_TEXT = "급여(SAL)가 3000 이상인 사원 이름을 조회하는 SQL로 옳은 것은?"
DEMO_CHOICES = [
    ("A", "SELECT ENAME FROM EMP", "WHERE SAL >= 3000;"),
    ("B", "SELECT ENAME FROM EMP", "HAVING SAL >= 3000;"),
    ("C", "SELECT ENAME FROM EMP", "GROUP BY SAL >= 3000;"),
]
DEMO_RESULT_COLUMN = "ENAME"
DEMO_RESULT_ROWS = ["KING", "FORD", "SCOTT"]
DEMO_RESULT_META = "실제 DB 실행 · 3행 반환 · 12ms"
DEMO_EXPLANATION = ("WHERE는 행 하나하나를 먼저 거르고, HAVING은 GROUP BY로 묶은 그룹에만 조건을 걸어요. "
                    "묶지 않고 급여로 사원을 거를 때는 WHERE를 써요.")
DEMO_EXPLANATION_TAGS = ["WHERE", "HAVING", "GROUP BY"]
# 첫 화면 폰 아래 단계 칩
DEMO_STEP_LABELS = ["문제 풀기", "SQL 실행", "정답 확인", "AI 해설"]

# ── 휘장 3개: (윗줄, 큰 글씨, 아랫줄) — 문구는 운영자 결정 (#1057) ──
AWARD_BADGES = [
    ("2026 EDUCATION AWARD", "최고의 교육 앱", "SQLD 학습 부문"),
    ("SQLD 2026", "최신 출제 경향", "기출 유형 반영"),
    ("REAL DB", "보기 SQL 실행", "결과로 확인"),
]

# ── 공부 순서 스크롤 이야기: (단계 키, 아이콘, 제목, 설명, 실제 앱 캡처 shots/ 파일) ──
# 넓은 화면: 고정 폰 화면이 단계 캡처로 바뀜 / 좁은 화면: 단계 글 아래 캡처 (#1062)
STORY_STEPS = [
    ("concept", "menu_book", "개념은 핵심만", "단원마다 꼭 기억할 것만 추려 두었어요. 읽고 바로 문제로 넘어가요.", "concept-light.webp"),
    ("today", "local_fire_department", "최신 경향 문제를 하루 5문제씩", "이번 시험에 늘어난 유형부터 오늘의 세트로 풀어요.", "home.webp"),
    ("execute", "terminal", "보기 SQL을 직접 실행해요", "보기마다 실제 DB 결과를 보면 외우지 않아도 차이가 보여요.", "execute.webp"),
    ("record", "check_circle", "정답은 바로, 기록은 쌓이게", "오답 노트와 단원별 진도가 자동으로 정리돼요.", "questions.webp"),
    ("ai", "auto_awesome", "틀린 이유는 AI 해설로", "내가 고른 보기에 맞춰 왜 틀렸는지 설명해요.", "ai.webp"),
]

# ── 후기: (별점 1~5, 후기, 이름 가림·소개) — 운영자 결정 (#1057) ──
REVIEWS_AVERAGE_LABEL = "4.9"
REVIEWS = [
    (5, "보기 SQL을 실제로 돌려 보니까 HAVING이랑 WHERE 차이가 한 번에 이해됐어요.", "김*연 · 직장인"),
    (5, "출퇴근길에 오늘의 5문제만 풀었는데 기출 경향이 자연스럽게 익었어요.", "박*준 · 대학생"),
    (5, "개념 탭에서 핵심만 보고 바로 문제로 넘어가니까 교재가 필요 없었어요.", "이*은 · 취업 준비"),
    (5, "틀린 보기마다 왜 틀렸는지 설명해 줘서 오답 노트를 따로 안 썼어요.", "최*호 · 개발자"),
    (5, "윈도우 함수가 늘 헷갈렸는데 결과 표로 보니까 덜 무서워졌어요.", "정*아 · 데이터 분석 입문"),
]

# 수험생 고민 > 해결: (아이콘, 고민, 해결)
PAIN_POINTS = [
    ("menu_book", "수험서가 너무 두꺼워요",
     "책 없이 문제로 시작해요. 시험 범위를 주제별로 나눠 휴대폰으로 틈틈이 풀어요."),
    ("update", "요즘 시험 경향을 모르겠어요",
     "제58~63회 복원 기출과 수험생 후기를 분석해 과목별 비중과 늘어난 유형을 보여 줘요."),
    ("help", "왜 틀렸는지 모르겠어요",
     "내가 고른 답이 왜 틀렸는지, 정답과 무엇이 다른지 AI 해설이 바로 짚어 줘요."),
    ("schedule", "꾸준히 하기가 어려워요",
     "하루 5문제 오늘의 세트와 연속 학습일, 시험 D-day 알림이 매일 공부를 이어 줘요."),
]

# 기능 카드: (아이콘, 제목, 설명) — 4열 x 3줄 (원본 기능: main app/lib/presentation/pages/*)
FEATURES = [
    ("local_fire_department", "오늘의 세트",
     "매일 모든 회원이 같은 5문제를 풀고 순위를 확인해요. 부담 없는 분량이라 매일 이어 가기 좋아요."),
    ("school", "단원별 개념 학습",
     "핵심, 자세히, 문제 세 단계로 단원을 익혀요. 꼭 기억할 것을 읽고 바로 문제로 확인해요."),
    ("terminal", "보기 SQL 직접 실행",
     "제출하면 보기마다 실제 DB에서 SQL을 실행해요. 외우지 말고 결과 표로 확인하세요."),
    ("compare_arrows", "내 답 vs 정답 비교",
     "틀리면 내가 고른 SQL과 정답 SQL의 실행 결과를 나란히 보여 줘요. 어디서 갈렸는지 바로 보여요."),
    ("shuffle", "매번 새 선택지",
     "같은 문제도 풀 때마다 선택지가 새로 바뀌어요. 답을 외우지 않고 개념으로 풀게 돼요."),
    ("auto_awesome", "AI 해설",
     "정답 근거, 시험 팁, 핵심 개념을 정리하고 내가 고른 오답이 왜 틀렸는지 설명해요."),
    ("trending_up", "최신 경향",
     "제58~63회 복원 기출과 수험생 후기를 분석했어요. 과목별 비중과 최근 늘어난 유형부터 풀 수 있어요."),
    ("category", "주제별 · TOP 10",
     "데이터 모델링부터 윈도우 함수까지 9개 주제로 나눴어요. 자주 나오는 개념은 TOP 10으로 먼저 잡아요."),
    ("edit_note", "오답 노트",
     "틀린 문제는 오답 노트에 모여 다시 풀어요. 연습과 실전 풀이 모드를 골라 쓸 수 있어요."),
    ("speed", "합격 준비도",
     "정답률, 영역별 약점, AI 분석으로 지금 얼마나 준비됐는지, 어디를 더 풀지 보여 줘요."),
    ("timer", "실전 모의고사",
     "실제 시험처럼 50문항을 시간 안에 풀어요. 제출하면 점수와 합격·과락을 바로 알려 줘요."),
    ("notifications_active", "시험 일정 · 접수 알림",
     "회차별 원서접수·시험일·발표를 한 화면에 보여 주고, 접수가 열리면 알려 드려요. D-day도 홈에서 바로 보여요."),
]

# 학습 흐름 4단계: (아이콘, 제목, 설명)
STUDY_STEPS = [
    ("local_fire_department", "매일 5문제", "오늘의 세트로 모두가 같은 5문제를 풀고 순위를 확인해요."),
    ("auto_awesome", "AI 해설로 이해", "정답 근거와 오답 이유, 시험 팁을 바로 읽어요."),
    ("edit_note", "오답 노트로 다시", "틀린 문제만 모아 다시 풀며 약한 곳을 메워요."),
    ("speed", "합격 준비도 확인", "정확도·범위·최신성으로 지금 준비 상태를 숫자로 봐요."),
]

# 최신 경향 미리보기 (원본: main server/.../exam-trend/sqld-latest-trend.json, 갱신 시 함께 수정)
TREND_BASIS = "제58~63회 복원 기출과 수험생 후기·오픈채팅 분석"
TREND_SUMMARY = "결과를 직접 계산하는 문제가 대부분이에요. 63회는 계산할 보기가 많아 시간이 모자랐다는 말이 가장 많았고, 비등가 조인과 비율 윈도우 함수처럼 오랜만에 나온 유형이 늘었어요."
# 과목별 비중: (과목, 비중 %, 설명)
TREND_SUBJECT_SHARES = [
    ("1과목 데이터 모델링의 이해", 20, "바커 표기 읽기와 관점·엔터티·속성·키 정의를 말장난처럼 꼬아 묻는 문제가 늘었어요."),
    ("2과목 SQL 기본과 활용", 80, "대부분이 결과 행 수·값·오류 여부를 직접 계산하는 추적형이고, 보기마다 계산이 필요해 시간이 빠듯해요."),
]
# 늘어난 유형 (앱 8개 중 4개): (제목, 설명, 출제 회차)
TREND_RISING_PATTERNS = [
    ("비등가 조인과 구간 매핑", "합계를 등급 구간 테이블에 BETWEEN으로 붙이거나, 부등호 조건으로 조인한 뒤 행 수와 합계를 계산해요.", "63회 2문항"),
    ("비율·값 범위 윈도우 함수", "RATIO_TO_REPORT 같은 비율 함수를 결과로 알아보고, RANGE 프레임이 값 범위로 더하는 결과를 계산해요.", "63회 3문항"),
    ("결과 비교형 보기", "보기마다 SQL을 주고 결과 행 수가 가장 많은 것, 결과가 다른 것을 골라요.", "61·62회 각 4문항, 63회 3문항"),
    ("짧은 쿼리 속 NULL 함정", "NOT IN, 빈 결과 집계, NULL 비교, NULL 치환 함수를 섞어 결과를 바꿔요.", "62회 9문항, 63회 4문항"),
]

# 화면 모음: (파일, 이름, 설명) — 원본 캡처 main app/docs/store/promo/source (#776), 문제 은행 규모가 보이는 화면 제외 (#636)
SCREENSHOTS = [
    ("execute.webp", "SQL 실행", "보기마다 실제 DB에서 실행"),
    ("real.webp", "매번 새 선택지", "풀 때마다 바뀌는 보기"),
    ("ai.webp", "AI 해설", "틀린 이유와 기억할 포인트"),
    ("concept-light.webp", "개념 학습", "단원별 꼭 기억할 것"),
    ("trend.webp", "최신 경향", "과목별 비중과 늘어난 유형"),
    ("stats.webp", "내 실력", "정답률, 영역별 약점, AI 분석"),
    ("rank.webp", "오늘의 순위", "오늘의 세트 리더보드"),
]
# 첫 화면 폰: 몇 초마다 순서대로 바뀌는 화면 (첫 장이 기본, JS 없으면 첫 장만)
HERO_SCREENSHOTS = [
    ("execute.webp", "passQL 문제 풀이 화면. 보기 SQL을 실제 DB에서 실행해 결과 표를 보여 줌."),
    ("ai.webp", "passQL AI 해설 화면. 틀린 이유와 기억할 포인트."),
    ("concept.webp", "passQL 개념 학습 화면. 단원별 꼭 기억할 것 5가지."),
    ("stats.webp", "passQL 프로필 화면. 정답률과 영역별 약점, AI 분석."),
]
# 첫 화면 폰 옆 떠 있는 카드: (아이콘, 굵은 글, 작은 글)
HERO_FLOATING_CARDS = [
    ("check_circle", "보기 A 실행 성공", "실제 DB · 12ms"),
    ("auto_awesome", "AI 해설", "HAVING은 그룹 조건"),
    ("speed", "정답률 78%", "약점: 윈도우 함수"),
]
TREND_SCREENSHOT = "trend.webp"

# 흐르는 주제 띠 (2줄, 반대 방향)
MARQUEE_TOPIC_ROWS = [
    ["SELECT 기본", "JOIN", "서브쿼리", "윈도우 함수", "그룹함수", "계층 쿼리", "PIVOT", "데이터 모델링", "정규화"],
    ["NULL 함정", "ROWNUM", "NOT IN", "GROUP BY", "HAVING", "DDL / DML / TCL", "트랜잭션", "식별자", "집합 연산"],
]

# 숫자로 보는 passQL: (숫자, 단위, 설명) — 문제 은행 규모 수치는 쓰지 않음 (#636)
STAT_COUNTERS = [
    (9, "개", "SQLD 출제 주제"),
    (5, "회차", "최근 기출 경향 분석"),
    (5, "문제", "매일 오늘의 세트"),
]
# 네 번째 숫자: 무료로 할 수 있는 것 (결제 켜짐·꺼짐 공통)
FREE_STAT_COUNTER = (1, "회", "모의고사 무료 체험")

# 기능 자세히 (화면 + 설명, 스크롤 효과): (캡처, 꼬리표, 제목, 설명, 떠 있는 카드 아이콘, 카드 글)
SHOWCASE_ITEMS = [
    ("execute.webp", "SQL 직접 실행", "외우지 말고,\n실행해서 확인해요",
     "제출하면 보기마다 실제 DB에서 SQL을 실행해요. 틀리면 내 답과 정답의 결과 표를 나란히 비교해 어디서 갈렸는지 보여 줘요.",
     "terminal", "3행 반환 · 12ms"),
    ("real.webp", "매번 새 선택지", "답 외우기는 그만,\n매번 새 선택지",
     "같은 문제도 풀 때마다 선택지가 새로 바뀌어요. 보기 순서를 외우는 대신 개념으로 푸는 힘이 붙어요.",
     "shuffle", "선택지를 새로 만들었어요"),
    ("ai.webp", "AI 해설", "틀린 이유,\nAI가 바로 짚어 줘요",
     "내가 고른 오답이 왜 틀렸는지, 정답과 무엇이 다른지, 시험장에서 기억할 포인트까지 한 번에 정리해요.",
     "auto_awesome", "기억할 포인트 정리"),
    ("concept.webp", "단원별 개념 학습", "개념은 핵심만,\n바로 문제로",
     "단원마다 꼭 기억할 것을 먼저 읽고, 자세히 보고, 바로 문제로 확인해요. 두꺼운 수험서 없이도 흐름이 잡혀요.",
     "school", "꼭 기억할 것 5가지"),
    ("stats.webp", "합격 준비도", "내 실력,\n숫자로 확인해요",
     "정답률과 영역별 약점, AI 분석으로 지금 어디가 약한지 알려 줘요. 약한 주제부터 다시 풀면 돼요.",
     "speed", "정답률 78%"),
]

# 무료·Pro 비교 (원본: main app/lib/presentation/widgets/pro/pro_benefits.dart proBenefits, 숨김 행 제외): (항목, 무료, Pro), None = 제공 안 함
# 무료 하루 크레딧 수 = pro_benefits.dart _fallbackDailyFreeLimit (서버 값이 바뀌면 함께 수정)
FREE_DAILY_CREDIT_COUNT = 10
PLAN_ROWS = [
    ("랜덤 풀기", f"크레딧 하루 {FREE_DAILY_CREDIT_COUNT}개", "제한 없음"),
    ("SQL 직접 실행", "오늘의 세트", "모든 문제"),
    ("해설", "정답 해설 (세트 전체)", "보기별 상세 답안지"),
    ("새 보기 · 토픽", None, "포함"),
    ("출제 경향", None, "포함"),
    ("통계", "기본", "약점 분석"),
    ("광고 제거", None, "포함"),
]
PLAN_NOTE = ("모의고사는 무료로 1회 체험하고, Pro는 전체 회차와 과목별 분석까지 볼 수 있어요. 무료 크레딧은 보너스로 더 받을 수 있어요. "
             "Pro 이용권은 1개월·3개월 두 가지이며 자동 결제되지 않아요. 가격은 앱에서 확인할 수 있어요.")

# 무료로 시작 안내 (비교표 위, 결제 켜짐·꺼짐 공통): 무료 범위는 pro_benefits.dart 무료 값과 맞춤
FREE_NOW_TITLE = "무료로도 이만큼 할 수 있어요"
FREE_NOW_LEAD = (f"가입만 하면 랜덤 풀기 하루 크레딧 {FREE_DAILY_CREDIT_COUNT}개와 오늘의 세트 5문제를 풀 수 있어요. "
                 "세트 안에서는 SQL 실행과 정답 해설까지 체험해요.")
FREE_NOW_POINTS = [
    ("local_fire_department", "오늘의 세트 5문제"),
    ("auto_awesome", "틀리면 정답 해설"),
    ("timer", "모의고사 1회 체험"),
    ("notifications_active", "시험 일정 · 알림"),
]

FINAL_CTA_TITLE = "시험 전까지, 하루 5문제부터"
FINAL_CTA_LEAD = "오늘의 세트 한 번만 풀어 보세요. 어디가 약한지 바로 보여요."

# 앱 FAQ (첫 화면 + FAQPage JSON-LD)
HOME_FAQS = [  # 앞 APP_FAQ_COUNT_ON_FAQ_PAGE 개는 FAQ 페이지에도 실림
    ("passQL은 무료인가요?",
     f"무료로 내려받아 바로 시작할 수 있어요. 무료로는 랜덤 풀기 하루 크레딧 {FREE_DAILY_CREDIT_COUNT}개(보너스로 더 받기 가능)와 오늘의 세트 5문제를 풀고, "
     "세트 안에서는 SQL 실행과 정답 해설을 체험할 수 있어요. 모의고사 1회 체험, 시험 일정과 알림도 무료예요. "
     "Pro 이용권(1개월·3개월, 자동 결제 없음)은 제한 없는 풀이, 모든 문제 SQL 실행, 보기별 상세 답안지, 모의고사 전체와 과목별 분석, 약점 분석, 출제 경향, 광고 제거를 열어 줘요."),
    ("SQLD 시험 범위를 모두 다루나요?",
     "SQLD 두 과목의 범위를 9개 주제로 나눠 문제를 제공해요. 1과목 데이터 모델링, 2과목 SELECT·DDL/DML/TCL·함수·JOIN·서브쿼리·그룹함수·윈도우 함수·계층과 PIVOT이에요."),
    ("개념 공부도 앱에서 할 수 있나요?",
     "네. 단원마다 꼭 기억할 것, 자세한 설명, 확인 문제를 순서대로 볼 수 있어요. 개념을 읽고 바로 문제로 확인해요."),
    ("최신 출제 경향은 어떻게 반영하나요?",
     "제58~63회 복원 기출과 수험생 후기를 분석해 과목별 비중, 최근 늘어난 유형, 자주 나오는 개념 TOP 10을 정리했어요. '최신 경향' 표시가 붙은 문제부터 골라 풀 수 있어요."),
    ("하루에 얼마나 공부하면 되나요?",
     "매일 열리는 오늘의 세트 5문제가 기본이에요. 여유가 있으면 약한 주제와 오답 노트를 더 풀고, 합격 준비도로 남은 부분을 확인하세요."),
    ("SQLP도 준비할 수 있나요?",
     "SQLP 필기의 데이터 모델링, SQL 기본 및 활용 과목은 SQLD와 범위가 겹쳐 그대로 연습할 수 있어요. SQL 고급 활용 및 튜닝 과목과 실기는 아직 다루지 않아요."),
    ("앱을 설치하지 않고 쓸 수 있나요?",
     "네. passql.vercel.app 에서 로그인하면 앱과 같은 학습 기록으로 이어서 풀 수 있어요."),
    ("Android에서도 쓸 수 있나요?",
     "네. Google Play에서 passQL을 내려받을 수 있어요. iPhone은 App Store에서 받고, 같은 계정으로 로그인하면 기록이 이어져요."),
]

# SQLD 시험 FAQ (#1027): FAQ 페이지 전체 + 안내 페이지별로 키로 골라 씀. 확실하지 않은 수치(합격률 등)는 쓰지 않음
SQLD_EXAM_FAQS = [  # (키, 질문, 답) — 키로 페이지마다 골라 씀
    ("format", "SQLD 시험은 어떻게 구성되나요?",
     "필기 시험만 있습니다. 데이터 모델링의 이해 10문항, SQL 기본 및 활용 40문항, 모두 50문항 객관식이며 시험 시간은 90분입니다."),
    ("pass", "SQLD 합격 기준은 무엇인가요?",
     "문항당 2점, 100점 만점에 60점 이상이면 합격입니다. 다만 1과목 8점(20점의 40%) 미만이거나 2과목 32점(80점의 40%) 미만이면 과락으로 불합격입니다."),
    ("start", "SQLD 공부는 어떻게 시작하면 좋나요?",
     "배점이 큰 2과목 SQL부터 문제로 익히고, 과락을 피하도록 1과목 데이터 모델링도 함께 풀어 두는 것이 좋습니다. passQL의 합격 준비도와 주제별 분석으로 약한 주제를 찾을 수 있습니다."),
    ("schedule", "시험 일정과 접수는 어디서 확인하나요?",
     "한국데이터산업진흥원 데이터자격검정 사이트(dataq.or.kr)에서 확인하고 접수합니다. 2026년 회차별 일정은 이 사이트의 SQLD 시험 일정 페이지에 정리했고, passQL 앱에서는 접수가 열릴 때 알림을 받을 수 있습니다."),
    ("about", "SQLD는 어떤 자격증인가요?",
     "SQL 개발자(SQL Developer) 자격으로, 한국데이터산업진흥원이 시행합니다. 데이터 모델링을 이해하고 SQL을 작성·해석하는 능력을 평가합니다."),
    ("fee", "응시 자격과 응시료는 어떻게 되나요?",
     "응시 자격 제한이 없어 누구나 응시할 수 있습니다. 응시료는 50,000원입니다."),
    ("frequency", "SQLD 시험은 1년에 몇 번 있나요?",
     "2026년에는 3월, 5월, 8월, 11월 네 번(제60~63회) 시행됩니다. 회차마다 원서접수, 수험표 발급, 사전점수 공개, 합격자 발표 날짜가 따로 있습니다."),
    ("difficulty", "SQLD는 어려운가요?",
     "50문항 중 40문항이 SQL이고, 짧은 쿼리의 결과 행 수나 값을 직접 따라가 계산하는 문제가 많습니다. SQL을 처음 본다면 문법을 외우기보다 결과를 확인하며 익히는 시간이 필요합니다."),
    ("non_major", "비전공자도 SQLD를 딸 수 있나요?",
     "응시 자격 제한이 없고, 시험 범위가 SELECT 같은 기본 문법부터 시작해 비전공자도 준비할 수 있습니다. 기본 문법을 먼저 익히고 JOIN, 서브쿼리, 윈도우 함수 순서로 넓혀 가면 좋습니다."),
    ("self_study", "독학으로 준비할 수 있나요?",
     "네. 시험 범위가 공식적으로 정해져 있어 범위별로 문제를 풀고 해설로 이유를 확인하는 방식으로 혼자 준비할 수 있습니다."),
    ("textbook", "교재가 꼭 있어야 하나요?",
     "꼭 필요하지는 않습니다. passQL은 단원별 개념 학습, 주제별 문제, AI 해설, 모의고사를 앱 하나에 담아 교재 없이 준비할 수 있게 만들었습니다. 개념을 책으로 정리하는 편이 맞다면 함께 봐도 좋습니다."),
    ("score_preview", "사전점수 공개는 무엇인가요?",
     "합격자 발표 전에 내 점수를 먼저 확인할 수 있는 기간입니다. 최종 합격 여부는 합격자 발표일에 확정됩니다."),
    ("pass_rate", "합격률은 어느 정도인가요?",
     "합격률은 회차마다 달라 이 사이트에서는 숫자를 싣지 않습니다. 공식 통계는 데이터자격검정 사이트에서 확인할 수 있습니다."),
    ("validity", "SQLD 자격에 유효기간이 있나요?",
     "유효기간과 갱신 여부는 시행 기관 정책에 따르므로 데이터자격검정 사이트의 공식 안내로 확인하세요."),
    ("sqlp", "SQLD와 SQLP는 무엇이 다른가요?",
     "SQLP(SQL 전문가)는 상위 자격으로 필기 3과목에 실기가 더해지고, 응시 자격 요건이 있습니다. SQLD 범위인 데이터 모델링과 SQL 기본 및 활용은 SQLP 필기와 겹칩니다."),
]
# FAQ 페이지에 함께 싣는 앱 FAQ 개수 (HOME_FAQS 앞에서부터)
APP_FAQ_COUNT_ON_FAQ_PAGE = 4

SQLP_FAQS = [
    ("SQLP 시험은 어떻게 구성되나요?",
     "필기와 실기로 나뉩니다. 필기는 데이터 모델링의 이해, SQL 기본 및 활용, SQL 고급 활용 및 튜닝 3과목입니다."),
    ("passQL로 SQLP의 어느 부분을 준비할 수 있나요?",
     "SQLD와 겹치는 데이터 모델링, SQL 기본 및 활용 범위를 연습할 수 있습니다. SQL 고급 활용 및 튜닝 과목과 실기 문제는 아직 제공하지 않습니다."),
    ("SQLP 응시 자격과 일정은 어디서 확인하나요?",
     "한국데이터산업진흥원 데이터자격검정 사이트(dataq.or.kr)의 공식 공지에서 확인할 수 있습니다."),
]

# ── 안내 페이지 목록 (#1027) ──
# 상단 보조 메뉴·하단 링크·빵부스러기·sitemap·관련 글 카드가 모두 이 목록을 읽음
# 키 = 경로, parent = 빵부스러기 상위 경로(None 이면 첫 화면 바로 아래), title 60자·description 150자 이내
GUIDE_PAGES = {
    "sqld/": {
        "menu_name": "SQLD 안내", "parent": None, "priority": "0.9", "icon": "school",
        "title": "SQLD 시험 안내 — 과목, 합격 기준, 공부 순서 한눈에 | passQL",
        "description": "SQLD(SQL 개발자) 시험 형식, 과목별 문항 수, 합격 기준과 과락, 과락 없이 60점 넘기는 공부 순서를 한 페이지에 정리했어요. 시험 범위 9개 주제는 passQL 앱에서 풀어 보세요.",
        "summary": "시험 형식, 과목, 합격 기준을 한 페이지로",
    },
    "sqld/schedule/": {
        "menu_name": "시험 일정", "parent": "sqld/", "priority": "0.9", "icon": "calendar_month",
        "title": "2026 SQLD 시험 일정 — 회차별 원서접수·시험일·발표일 | passQL",
        "description": "2026년 SQLD 제60~63회 원서접수, 수험표 발급, 시험일, 사전점수 공개, 합격자 발표 일정을 회차별로 정리했어요. 접수는 데이터자격검정 공식 사이트에서, 일정 알림은 passQL 앱에서.",
        "summary": "제60~63회 접수·시험·발표 날짜",
    },
    "sqld/subjects/": {
        "menu_name": "과목·범위", "parent": "sqld/", "priority": "0.8", "icon": "category",
        "title": "SQLD 과목·출제 범위 — 1과목·2과목 주제 9개 정리 | passQL",
        "description": "SQLD 1과목 데이터 모델링의 이해(10문항)와 2과목 SQL 기본 및 활용(40문항)의 출제 범위를 SELECT, JOIN, 서브쿼리, 윈도우 함수 등 주제 9개로 나눠 설명해요.",
        "summary": "1과목 10문항 · 2과목 40문항, 주제 9개",
    },
    "sqld/pass/": {
        "menu_name": "합격 기준", "parent": "sqld/", "priority": "0.8", "icon": "verified",
        "title": "SQLD 합격 기준·과락 — 60점 합격, 과목별 과락 점수 | passQL",
        "description": "SQLD는 90분 50문항, 문항당 2점으로 60점 이상이면 합격이에요. 1과목 8점, 2과목 32점 미만은 과락. 점수 계산 예시와 응시료(50,000원), 응시 자격까지 정리했어요.",
        "summary": "60점 합격, 과락 8점 · 32점, 응시료",
    },
    "sqld/study/": {
        "menu_name": "공부 방법", "parent": "sqld/", "priority": "0.8", "icon": "route",
        "title": "SQLD 공부 방법 — 비전공자 2~4주 독학 로드맵 | passQL",
        "description": "SQL이 처음인 비전공자도 따라 할 수 있는 SQLD 2주·4주 독학 로드맵. 주차별로 무엇을 풀지, 과락을 피하는 순서, 시험 직전 점검까지 교재 없이 앱 하나로 준비하는 방법을 정리했어요.",
        "summary": "2주 · 4주 로드맵과 과락 피하는 순서",
    },
    "sqld/faq/": {
        "menu_name": "자주 묻는 질문", "parent": "sqld/", "priority": "0.7", "icon": "help",
        "title": "SQLD 자주 묻는 질문 — 난이도·독학·교재·SQLP 차이 | passQL",
        "description": "SQLD는 어려운가요? 비전공자도 독학할 수 있나요? 교재가 꼭 필요한가요? 응시료, 시험 횟수, 사전점수 공개, SQLP와의 차이까지 SQLD 수험생이 자주 묻는 질문에 답했어요.",
        "summary": "난이도, 독학, 교재, SQLP 차이",
    },
    "sqlp/": {
        "menu_name": "SQLP 안내", "parent": None, "priority": "0.7", "icon": "workspace_premium",
        "title": "SQLP 시험 안내 — 필기 과목과 SQLD와의 차이 | passQL",
        "description": "SQLP(SQL 전문가) 필기 3과목 구성과 SQLD와 겹치는 범위, passQL로 연습할 수 있는 부분을 정리했어요. 데이터 모델링, SQL 기본 및 활용 문제를 AI 해설과 함께 풀어 보세요.",
        "summary": "필기 3과목 + 실기, SQLD와 겹치는 범위",
    },
    # 검색어별 안내 3장 (#1057): 기출 경향 · 모의고사 · 앱
    "sqld/trend/": {
        "menu_name": "기출 경향", "parent": "sqld/", "priority": "0.8", "icon": "trending_up",
        "title": "SQLD 기출 경향 — 제58~63회 출제 유형과 과목별 비중 | passQL",
        "description": "SQLD 제58~63회 복원 기출과 수험생 후기를 바탕으로 과목별 비중과 최근 늘어난 유형(비등가 조인, 비율 윈도우 함수, 결과 비교형, NULL 함정)을 정리했어요. 유형별 문제는 passQL 앱에서 풀어 보세요.",
        "summary": "제58~63회 과목별 비중, 늘어난 유형 4가지",
    },
    "sqld/mock-exam/": {
        "menu_name": "모의고사", "parent": "sqld/", "priority": "0.8", "icon": "timer",
        "title": "SQLD 모의고사 — 50문항 90분, 실전처럼 연습하는 순서 | passQL",
        "description": "SQLD 모의고사를 실제 시험처럼 50문항 90분으로 풀고, 60점 합격·과목별 과락 기준으로 채점해 약한 주제를 찾는 순서를 정리했어요. passQL 앱에서 모의고사 1회를 무료로 체험할 수 있어요.",
        "summary": "50문항 90분 실전 연습과 채점 순서",
    },
    # 회차별 가답안·가채점 목록 (#1075). 회차 페이지(sqld/63/ 등)는 build_site 가 site_answer_key_content 에서 등록
    "sqld/answers/": {
        "menu_name": "가답안·가채점", "parent": "sqld/", "priority": "0.8", "icon": "fact_check",
        "title": "SQLD 가답안·가채점 — 회차별 정답 집계와 OMR 점수 계산 | passQL",
        "description": "SQLD 시험이 끝나면 회차별 가답안을 문항 득표·합의율로 보고, OMR에 내 답을 찍어 과목별 점수·과락·합격 여부를 바로 가채점해요. 원문 문항 없이 번호와 출제 개념만 정리했어요.",
        "summary": "회차별 가답안 집계와 OMR 가채점",
    },
    "sqld/app/": {
        "menu_name": "SQLD 앱", "parent": "sqld/", "priority": "0.8", "icon": "quiz",
        "title": "SQLD 공부 앱 passQL — 교재 없이 SQL 자격증 준비 | passQL",
        "description": "SQLD 문제 풀이 앱 passQL로 교재 없이 SQL 자격증을 준비하는 방법. 단원별 개념 학습, 최신 경향 문제, 보기 SQL 직접 실행, AI 해설, 모의고사, 시험 일정 알림을 무료로 시작해요.",
        "summary": "개념, 문제, SQL 실행, AI 해설을 앱 하나로",
    },
}
# 상단 보조 메뉴 순서 (첫 화면 포함 모든 페이지). 진행 중 가채점 회차는 build_site 가 맨 앞에 끼움 (#1075)
GUIDE_MENU_PATHS = ["sqld/answers/", "sqld/schedule/", "sqld/subjects/", "sqld/pass/", "sqld/trend/", "sqld/study/", "sqld/faq/", "sqlp/"]
# 상단 메뉴 강조 경로 (시험 당일~합격자 발표 진행 중 가채점 회차, build_site 가 채움)
NAV_LIVE_PATHS = set()

# ── 공부 방법 페이지 ──
# 원칙: (아이콘, 제목, 설명)
STUDY_PRINCIPLES = [
    ("terminal", "2과목은 결과를 따라가며", "40문항이 SQL이고, 결과 행 수·값을 계산하는 문제가 많아요. 문법을 외우기보다 실행 결과로 확인하며 익혀요."),
    ("flag", "1과목은 과락부터 막기", "10문항 중 4문항(8점) 미만이면 과락이에요. 분량이 적어도 처음부터 꾸준히 섞어 풀어요."),
    ("lightbulb", "틀린 문제는 이유까지", "정답만 보고 넘기면 같은 함정에 또 빠져요. 내가 고른 보기가 왜 틀렸는지까지 확인해요."),
    ("timer", "마지막 주는 실전처럼", "90분 50문항을 한 번에 풀어 시간 배분과 과락 여부를 미리 점검해요."),
]
# 로드맵: (플랜 이름, 대상, [(주차, 할 일 제목, 할 일 설명, 앱 기능)])
STUDY_ROADMAPS = [
    ("4주 플랜", "SQL을 처음 보는 비전공자", [
        ("1주차", "SQL 기본기", "SELECT·WHERE·ORDER BY와 함수, NULL 처리를 익혀요. 짧은 쿼리를 직접 실행해 결과를 확인해요.", "개념 학습 · 보기 SQL 실행"),
        ("2주차", "JOIN · 서브쿼리 · 집계", "2과목에서 비중이 큰 주제예요. 주제별로 풀고 틀린 문제는 해설로 이유를 확인해요.", "주제별 문제 · AI 해설"),
        ("3주차", "윈도우 함수 · 계층 · 1과목", "남은 2과목 주제와 1과목 데이터 모델링을 채우고, 오답을 다시 풀어요.", "오답 노트 · 합격 준비도"),
        ("4주차", "실전 감각", "모의고사로 90분 50문항을 풀고 과락 과목이 없는지 확인해요. 약한 주제만 다시 돌려요.", "모의고사 · 시험 일정 알림"),
    ]),
    ("2주 플랜", "SQL을 써 본 적 있는 분", [
        ("1주차", "2과목 전 범위 훑기", "주제 8개를 빠르게 풀며 약한 주제를 찾아요. 윈도우 함수·계층 쿼리처럼 낯선 문법부터 채워요.", "주제별 문제 · 합격 준비도"),
        ("2주차", "1과목 · 모의고사 반복", "1과목 데이터 모델링으로 과락을 막고, 모의고사와 오답 복습을 번갈아 해요.", "모의고사 · 오답 노트"),
    ]),
]
# 하루 루틴: (아이콘, 제목, 설명)
STUDY_DAILY_ROUTINE = [
    ("local_fire_department", "오늘의 세트 5문제", "매일 열리는 5문제로 공부를 시작해요. 부담 없는 분량이라 매일 이어 가기 좋아요."),
    ("auto_awesome", "AI 해설로 이유 확인", "틀린 보기가 왜 틀렸는지, 시험장에서 기억할 포인트를 바로 읽어요."),
    ("edit_note", "오답 노트로 한 번 더", "틀린 문제만 모아 다시 풀어 같은 실수를 줄여요."),
]
# 시험 직전 점검: 문구 목록 (준비물 세부는 수험표 공지가 기준)
STUDY_EXAM_CHECKLIST = [
    "수험표 발급일에 시험장과 입실 시간을 확인해요.",
    "신분증 등 준비물은 수험표 공지대로 챙겨요.",
    "1과목 과락(8점 미만) 위험이 없는지 마지막으로 점검해요.",
    "사전점수 공개 기간에 점수를 확인하고, 합격자 발표일을 기다려요.",
]

# 일정 페이지 앱 안내 (#991 시험 일정 화면·접수 알림)
SCHEDULE_APP_POINTS = [
    ("notifications_active", "원서접수가 열리면 알림"),
    ("event", "홈에서 시험 D-day 확인"),
    ("timer", "시험 전 실전 모의고사"),
]


# ── 모의고사 안내 (#1057): 실전 연습 순서 (아이콘, 제목, 설명) ──
MOCK_EXAM_STEPS = [
    ("timer", "시간을 재고 한 번에", "실제 시험처럼 90분 안에 50문항을 끊지 않고 풀어요. 중간에 해설을 보지 않아야 실제 점수에 가까워요."),
    ("checklist", "합격선과 과락부터 채점", "총점 60점을 넘었는지와 함께 1과목 8점, 2과목 32점 과락선을 넘었는지 따로 확인해요."),
    ("auto_awesome", "틀린 문제는 이유까지", "정답만 확인하지 말고 내가 고른 보기가 왜 틀렸는지 해설로 짚어요. 보기 SQL을 실행해 결과로 확인하면 오래 남아요."),
    ("trending_up", "약한 주제로 돌아가기", "틀린 문제가 몰린 주제를 골라 다시 풀어요. 다음 모의고사는 그 주제를 메운 뒤에 봐요."),
]
# 모의고사 시간 배분 예시: (구간, 설명)
MOCK_EXAM_TIME_PLAN = [
    ("1과목 10문항", "개념 적용형이 많아 15분 안팎으로 먼저 끝내요."),
    ("2과목 40문항", "결과를 따라가는 추적형이 많아 60분 안팎을 써요."),
    ("검토", "남은 시간에 표시해 둔 문제와 답안 표기를 다시 봐요."),
]
