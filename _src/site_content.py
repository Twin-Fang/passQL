# -*- coding: utf-8 -*-
"""소개 사이트 문구·주소 단일 원본 (#505, #650): build_site.py 가 읽어 페이지·sitemap·JSON-LD 생성
문제 총 개수·"N문제 이상" 같은 문제 은행 규모 수치는 쓰지 않음 (#636, #660)
"""

SITE_URL = "https://twin-fang.github.io/passQL/"
WEB_APP_URL = "https://passql.vercel.app"
APP_STORE_URL = "https://apps.apple.com/kr/app/passql/id6762165005"
APP_STORE_ID = "6762165005"
# Play 공개 페이지는 비공개 테스트 중이라 404 (#353) > 배지 대신 "출시 준비 중" 표기
IS_PLAY_STORE_PUBLIC = False
PLAY_STORE_URL = "https://play.google.com/store/apps/details?id=com.coldredrice.passql"
OFFICIAL_EXAM_URL = "https://www.dataq.or.kr"
CONTACT_EMAIL = "chan4760@naver.com"
# 법적 문구 원본: 운영 DB legal 테이블 (관리자 > 약관 관리에서 수정) > 빌드 시 이 API 로 읽음
LEGAL_API_URL = "https://api.passql.suhsaechan.kr/api/meta/legal/"
OG_IMAGE_URL = SITE_URL + "icon/og.png"

# 운영자 표기 (푸터·JSON-LD). 빈 값이면 그 줄을 렌더하지 않음, 주소는 표기하지 않음
OPERATOR_BUSINESS_NAME = "KOLLYLAB (콜리랩)"
OPERATOR_REPRESENTATIVE_NAME = ""
OPERATOR_BUSINESS_REGISTRATION_NUMBER = ""

# 첫 화면 D-day 기준 시험 (JS 가 방문 날짜 기준으로 남은 날 계산, 회차가 바뀌면 여기만 수정)
NEXT_EXAM_NAME = "SQLD 제63회"
NEXT_EXAM_DATE = "2026-11-14"
NEXT_EXAM_DATE_LABEL = "2026년 11월 14일 (토)"

# 무료·Pro 비교 노출 여부 (결제 끄면 False). 가격은 스토어가 정하므로 숫자를 쓰지 않음
IS_PRO_PLAN_VISIBLE = True

# 시험 범위: 운영 API /api/meta/topics 의 주제 9개 (sortOrder 순)
SQLD_SUBJECTS = [
    {
        "name": "1과목 · 데이터 모델링의 이해",
        "topics": ["데이터 모델링"],
    },
    {
        "name": "2과목 · SQL 기본 및 활용",
        "topics": [
            "SELECT 기본", "DDL / DML / TCL", "SQL 함수", "JOIN",
            "서브쿼리", "그룹함수 / 집계", "윈도우 함수", "계층 / PIVOT",
        ],
    },
]

# ── 첫 화면 ──
HOME_TITLE = "passQL — SQLD 문제 풀이 앱 | 최신 기출 경향, AI 해설, 매일 5문제"
HOME_DESCRIPTION = ("책 없이 앱 하나로 SQLD 준비. 제58~62회 복원 기출 경향을 반영한 문제를 풀고, "
                    "틀린 이유는 AI 해설로 바로 확인하세요. 매일 5문제 오늘의 세트, 오답 노트, 합격 준비도까지.")

HERO_EYEBROW = "SQLD 자격증 문제 풀이 앱"
HERO_TITLE_LEAD = "SQLD,"
HERO_TITLE_HIGHLIGHT = "앱 하나로"
HERO_TITLE_TAIL = "끝내세요"
HERO_LEAD = ("두꺼운 수험서 대신 최신 출제 경향을 반영한 문제를 풀고, 틀린 이유는 AI 해설로 바로 확인하세요. "
             "매일 5문제부터 합격 준비도까지 passQL 하나면 충분해요.")
# 첫 화면 핵심 3개: (아이콘, 문구)
HERO_POINTS = [
    ("local_fire_department", "매일 5문제 오늘의 세트"),
    ("trending_up", "제58~62회 기출 경향 반영"),
    ("auto_awesome", "틀린 이유까지 AI 해설"),
]
HERO_STORE_NOTE = "무료로 시작 · 소셜 계정으로 바로 로그인 · Android 앱은 출시 준비 중이라 웹으로 이용할 수 있어요"

# 수험생 고민 > 해결: (아이콘, 고민, 해결)
PAIN_POINTS = [
    ("menu_book", "수험서가 너무 두꺼워요",
     "책 없이 문제로 시작해요. 시험 범위를 주제별로 나눠 휴대폰으로 틈틈이 풀어요."),
    ("update", "요즘 시험 경향을 모르겠어요",
     "제58~62회 복원 기출과 수험생 후기를 분석해 과목별 비중과 늘어난 유형을 보여 줘요."),
    ("help", "왜 틀렸는지 모르겠어요",
     "내가 고른 답이 왜 틀렸는지, 정답과 무엇이 다른지 AI 해설이 바로 짚어 줘요."),
    ("schedule", "꾸준히 하기가 어려워요",
     "하루 5문제 오늘의 세트와 연속 학습일, 시험 D-day 알림이 매일 공부를 이어 줘요."),
]

# 기능 카드: (아이콘, 제목, 설명)
FEATURES = [
    ("local_fire_department", "오늘의 세트",
     "매일 모든 회원이 같은 5문제를 풀고 순위를 확인해요. 부담 없는 분량이라 매일 이어 가기 좋아요."),
    ("trending_up", "최신 경향",
     "제58~62회 복원 기출과 수험생 후기를 분석했어요. 과목별 비중과 최근 늘어난 유형부터 풀 수 있어요."),
    ("category", "주제별 · TOP 10",
     "데이터 모델링부터 윈도우 함수까지 9개 주제로 나눴어요. 자주 나오는 개념은 TOP 10으로 먼저 잡아요."),
    ("terminal", "보기 SQL 직접 실행",
     "보기의 SQL을 실제로 실행해 결과 표를 보여 줘요. 외우지 말고 왜 정답인지 눈으로 확인하세요."),
    ("auto_awesome", "AI 해설",
     "정답 근거, 시험 팁, 핵심 개념을 정리하고 내가 고른 오답이 왜 틀렸는지 설명해요."),
    ("edit_note", "오답 노트",
     "틀린 문제는 오답 노트에 모여 다시 풀어요. 연습과 실전 풀이 모드를 골라 쓸 수 있어요."),
    ("speed", "합격 준비도",
     "정확도, 학습 범위, 최신 경향 대비를 합쳐 지금 얼마나 준비됐는지 숫자로 보여 줘요."),
    ("calendar_month", "시험 D-day · 달력",
     "푼 날이 달력에 쌓이고 연속 학습일이 이어져요. 시험까지 남은 날도 홈에서 바로 보여요."),
    ("forum", "토론",
     "헷갈리는 문제는 다른 수험생과 이야기 나눠요. 같은 시험을 준비하는 사람들이 모여 있어요."),
    ("notifications_active", "알림",
     "오늘의 세트가 열리면, 시험이 다가오면 알려 드려요. 잊지 않고 매일 풀 수 있어요."),
]

# 학습 흐름 4단계: (아이콘, 제목, 설명)
STUDY_STEPS = [
    ("local_fire_department", "매일 5문제", "오늘의 세트로 모두가 같은 5문제를 풀고 순위를 확인해요."),
    ("auto_awesome", "AI 해설로 이해", "정답 근거와 오답 이유, 시험 팁을 바로 읽어요."),
    ("edit_note", "오답 노트로 다시", "틀린 문제만 모아 다시 풀며 약한 곳을 메워요."),
    ("speed", "합격 준비도 확인", "정확도·범위·최신성으로 지금 준비 상태를 숫자로 봐요."),
]

# 최신 경향 미리보기 (원본: main server/.../exam-trend/sqld-latest-trend.json, 갱신 시 함께 수정)
TREND_BASIS = "제58~62회 복원 기출과 수험생 후기·오픈채팅 분석"
TREND_SUMMARY = "짧은 쿼리에 NULL 함정을 숨기고 결과를 따라가게 하는 문제가 중심이에요. 62회는 쉬웠다는 말이 많았지만 합격률은 낮았어요."
# 과목별 비중: (과목, 비중 %, 설명)
TREND_SUBJECT_SHARES = [
    ("1과목 데이터 모델링의 이해", 20, "정의 암기보다 참여도·상호배타·다중값 속성을 지문 상황에 적용하는 문제가 늘었어요."),
    ("2과목 SQL 기본과 활용", 80, "대부분이 결과 행 수·값·오류 여부를 직접 계산하는 추적형이에요."),
]
# 늘어난 유형 (앱 8개 중 4개): (제목, 설명, 출제 회차)
TREND_RISING_PATTERNS = [
    ("짧은 쿼리 속 NULL 함정", "NOT IN, 빈 결과 집계, NULL 비교, NULL 치환 함수를 섞어 결과를 바꿔요.", "62회 집중 출제"),
    ("결과 비교형 보기", "보기마다 SQL을 주고 결과 행 수가 가장 많은 것, 결과가 다른 것을 골라요.", "61·62회"),
    ("오류 나는 SQL 고르기", "인라인 뷰 별칭을 바깥에서 쓰거나 스칼라 서브쿼리가 여러 행을 돌려주는 SQL을 찾아요.", "58·61·62회"),
    ("ROWNUM 실행 순서", "ROWNUM이 ORDER BY보다 먼저 붙는 점과 부등 조건에서 행이 탈락하는 점을 노려요.", "61·62회"),
]

# 화면 모음: (파일, 이름, 설명) — 원본 캡처 main app/docs/store/promo/source, 문제 은행 규모가 보이는 화면 제외 (#636)
SCREENSHOTS = [
    ("home.webp", "홈", "오늘의 세트, 시험 D-day, 이번 시험 출제 경향"),
    ("trend.webp", "최신 경향", "과목별 비중과 늘어난 유형"),
    ("questions.webp", "문제", "주제별로 골라 풀기, 오답 노트, 풀이 모드"),
    ("execute.webp", "SQL 실행", "보기 SQL을 실행해 결과 표 확인"),
    ("ai.webp", "AI 해설", "틀린 이유와 기억할 포인트"),
    ("stats.webp", "합격 준비도", "정확도·범위·최신성, 학습 달력"),
    ("rank.webp", "오늘의 순위", "오늘의 세트 리더보드"),
]
# 첫 화면 폰 목업 (앞, 뒤)
HERO_FRONT_SCREENSHOT = "home.webp"
HERO_BACK_SCREENSHOT = "questions.webp"
TREND_SCREENSHOT = "trend.webp"

# 무료·Pro 비교 (원본: main app/lib/presentation/widgets/pro/pro_plan_comparison_table.dart): (항목, 무료, Pro), None = 제공 안 함
PLAN_ROWS = [
    ("문제 풀이", "하루 일정량", "제한 없음"),
    ("AI 해설", "한 줄 요약", "보기별 전체"),
    ("보기 SQL 직접 실행", None, "포함"),
    ("실전 모드 · 토픽", None, "포함"),
    ("최신 출제 경향", None, "포함"),
    ("학습 통계", "기본", "약점 분석"),
]
PLAN_NOTE = "Pro 이용권은 1개월·3개월 두 가지이며 자동 결제되지 않아요. 가격은 앱에서 확인할 수 있어요."

FINAL_CTA_TITLE = "시험 전까지, 하루 5문제부터"
FINAL_CTA_LEAD = "오늘의 세트 한 번만 풀어 보세요. 어디가 약한지 바로 보여요."

# 페이지 공통 FAQ (index 화면 + FAQPage JSON-LD)
HOME_FAQS = [
    ("passQL은 무료인가요?",
     "무료로 내려받아 바로 시작할 수 있어요. 무료로는 하루 일정량의 문제를 풀 수 있고, "
     "Pro 이용권(1개월·3개월)을 쓰면 문제를 제한 없이 풀고 SQL 실행, 보기별 전체 해설, 최신 출제 경향까지 열려요. 자동 결제는 없어요."),
    ("SQLD 시험 범위를 모두 다루나요?",
     "SQLD 두 과목의 범위를 9개 주제로 나눠 문제를 제공해요. 1과목 데이터 모델링, 2과목 SELECT·DDL/DML/TCL·함수·JOIN·서브쿼리·그룹함수·윈도우 함수·계층과 PIVOT이에요."),
    ("최신 출제 경향은 어떻게 반영하나요?",
     "제58~62회 복원 기출과 수험생 후기를 분석해 과목별 비중, 최근 늘어난 유형, 자주 나오는 개념 TOP 10을 정리했어요. '최신 경향' 표시가 붙은 문제부터 골라 풀 수 있어요."),
    ("하루에 얼마나 공부하면 되나요?",
     "매일 열리는 오늘의 세트 5문제가 기본이에요. 여유가 있으면 약한 주제와 오답 노트를 더 풀고, 합격 준비도로 남은 부분을 확인하세요."),
    ("SQLP도 준비할 수 있나요?",
     "SQLP 필기의 데이터 모델링, SQL 기본 및 활용 과목은 SQLD와 범위가 겹쳐 그대로 연습할 수 있어요. SQL 고급 활용 및 튜닝 과목과 실기는 아직 다루지 않아요."),
    ("앱을 설치하지 않고 쓸 수 있나요?",
     "네. passql.vercel.app 에서 로그인하면 앱과 같은 학습 기록으로 이어서 풀 수 있어요."),
    ("Android 앱은 언제 나오나요?",
     "Google Play 출시를 준비하고 있어요. 그전에는 Android 휴대폰의 브라우저에서 웹으로 이용할 수 있어요."),
]

SQLD_FAQS = [
    ("SQLD 시험은 어떻게 구성되나요?",
     "필기 시험만 있습니다. 데이터 모델링의 이해 10문항, SQL 기본 및 활용 40문항, 모두 50문항 객관식이며 시험 시간은 90분입니다."),
    ("SQLD 합격 기준은 무엇인가요?",
     "100점 만점에 60점 이상이면 합격입니다. 다만 한 과목이라도 40% 미만이면 과락으로 불합격입니다."),
    ("SQLD 공부는 어떻게 시작하면 좋나요?",
     "배점이 큰 2과목 SQL부터 문제로 익히고, 과락을 피하도록 1과목 데이터 모델링도 함께 풀어 두는 것이 좋습니다. passQL의 합격 준비도와 주제별 분석으로 약한 주제를 찾을 수 있습니다."),
    ("시험 일정과 접수는 어디서 확인하나요?",
     "한국데이터산업진흥원 데이터자격검정 사이트(dataq.or.kr)에서 확인하고 접수합니다. passQL 앱에서도 응시할 회차를 고를 수 있습니다."),
]

SQLP_FAQS = [
    ("SQLP 시험은 어떻게 구성되나요?",
     "필기와 실기로 나뉩니다. 필기는 데이터 모델링의 이해, SQL 기본 및 활용, SQL 고급 활용 및 튜닝 3과목입니다."),
    ("passQL로 SQLP의 어느 부분을 준비할 수 있나요?",
     "SQLD와 겹치는 데이터 모델링, SQL 기본 및 활용 범위를 연습할 수 있습니다. SQL 고급 활용 및 튜닝 과목과 실기 문제는 아직 제공하지 않습니다."),
    ("SQLP 응시 자격과 일정은 어디서 확인하나요?",
     "한국데이터산업진흥원 데이터자격검정 사이트(dataq.or.kr)의 공식 공지에서 확인할 수 있습니다."),
]
