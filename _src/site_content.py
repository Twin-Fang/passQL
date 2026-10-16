# -*- coding: utf-8 -*-
"""소개 사이트 문구·주소 단일 원본 (#505): build_site.py 가 읽어 페이지·sitemap·JSON-LD 생성"""

SITE_URL = "https://twin-fang.github.io/passQL/"
WEB_APP_URL = "https://passql.vercel.app"
APP_STORE_URL = "https://apps.apple.com/kr/app/passql/id6762165005"
APP_STORE_ID = "6762165005"
# Play 공개 페이지는 비공개 테스트 중이라 404 (#353) > 배지 대신 "출시 준비 중" 표기
IS_PLAY_STORE_PUBLIC = False
PLAY_STORE_URL = "https://play.google.com/store/apps/details?id=com.coldredrice.passql"
OFFICIAL_EXAM_URL = "https://www.dataq.or.kr"
CONTACT_EMAIL = "chan4760@gmail.com"
OG_IMAGE_URL = SITE_URL + "icon/og.png"

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

# 페이지 공통 FAQ (index 화면 + FAQPage JSON-LD)
HOME_FAQS = [
    ("passQL은 무료인가요?",
     "네, 무료입니다. App Store에서 내려받거나 웹에서 바로 시작할 수 있습니다."),
    ("SQLD 시험 범위를 모두 다루나요?",
     "SQLD 두 과목의 범위를 9개 주제로 나눠 문제를 제공합니다. 1과목 데이터 모델링, 2과목 SELECT·DDL/DML/TCL·함수·JOIN·서브쿼리·그룹함수·윈도우 함수·계층과 PIVOT입니다."),
    ("SQLP도 준비할 수 있나요?",
     "SQLP 필기의 데이터 모델링, SQL 기본 및 활용 과목은 SQLD와 범위가 겹쳐 그대로 연습할 수 있습니다. SQL 고급 활용 및 튜닝 과목과 실기는 아직 다루지 않습니다."),
    ("SQL을 직접 실행해 볼 수 있나요?",
     "실행형 문제에서는 SQL을 직접 실행하고, 내 쿼리의 결과와 정답 결과를 표로 비교할 수 있습니다."),
    ("앱을 설치하지 않고 쓸 수 있나요?",
     "네. passql.vercel.app 에서 Google 또는 Apple 계정으로 로그인하면 앱과 같은 학습 기록으로 이어서 풀 수 있습니다."),
    ("Android 앱은 언제 나오나요?",
     "Google Play 출시를 준비하고 있습니다. 그전에는 Android 휴대폰의 브라우저에서 웹으로 이용할 수 있습니다."),
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
