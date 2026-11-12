# -*- coding: utf-8 -*-
"""구조화 데이터(JSON-LD) 원본 (#505, #1027): MobileApplication·WebSite·Organization·BreadcrumbList·FAQPage·Event
화면 문구와 같은 site_content 원본에서 만듦 (화면 <-> JSON-LD 어긋남 방지)
"""

import site_content as content

SCHEMA_CONTEXT = "https://schema.org"
EXAM_ORGANIZER_NAME = "한국데이터산업진흥원"


def build_organization_json_ld():
    """운영자 Organization (사이트 발행 주체)"""
    return {
        "@context": SCHEMA_CONTEXT,
        "@type": "Organization",
        "name": content.OPERATOR_BUSINESS_NAME,
        "url": content.SITE_URL,
        "logo": content.SITE_URL + "icon/mark.png",
        "email": content.CONTACT_EMAIL,
    }


def build_website_json_ld():
    return {
        "@context": SCHEMA_CONTEXT,
        "@type": "WebSite",
        "name": "passQL",
        "alternateName": "패스큐엘",
        "url": content.SITE_URL,
        "inLanguage": "ko",
        "publisher": {"@type": "Organization", "name": content.OPERATOR_BUSINESS_NAME, "url": content.SITE_URL},
    }


def build_app_json_ld():
    """MobileApplication: 앱 정보 + 설치 주소 + 무료"""
    install_urls = [content.APP_STORE_URL] + ([content.PLAY_STORE_URL] if content.IS_PLAY_STORE_PUBLIC else [])
    return {
        "@context": SCHEMA_CONTEXT,
        "@type": "MobileApplication",
        "name": "passQL",
        "alternateName": ["패스큐엘", "passQL SQLD"],
        "description": "교재 없이 앱 하나로 SQLD 준비. 최신 출제 경향 문제, 보기 SQL 직접 실행, AI 해설, 단원별 개념 학습, 실전 모의고사, 시험 일정 알림, 매일 5문제 오늘의 세트, 오답 노트, 합격 준비도.",
        "applicationCategory": "EducationalApplication",
        "operatingSystem": "iOS, Android, Web",
        "inLanguage": "ko",
        "url": content.SITE_URL,
        "downloadUrl": install_urls,
        "installUrl": install_urls,
        "image": content.OG_IMAGE_URL,
        "offers": {"@type": "Offer", "price": "0", "priceCurrency": "KRW"},
        "publisher": {"@type": "Organization", "name": content.OPERATOR_BUSINESS_NAME},
    }


def build_breadcrumb_json_ld(crumbs):
    """빵부스러기 [(이름, 경로)] > BreadcrumbList (첫 항목은 항상 첫 화면)"""
    return {
        "@context": SCHEMA_CONTEXT,
        "@type": "BreadcrumbList",
        "itemListElement": [
            {"@type": "ListItem", "position": position, "name": name, "item": content.SITE_URL + path}
            for position, (name, path) in enumerate(crumbs, start=1)
        ],
    }


def build_faq_json_ld(faqs):
    """화면 FAQ <-> FAQPage JSON-LD (같은 원본)"""
    return {
        "@context": SCHEMA_CONTEXT,
        "@type": "FAQPage",
        "mainEntity": [
            {"@type": "Question", "name": question,
             "acceptedAnswer": {"@type": "Answer", "text": answer}}
            for question, answer in faqs
        ],
    }


def build_exam_event_json_ld(exam_round):
    """SQLD 회차 1개 > Event (시험일 하루, 접수 기간은 offers 판매 기간으로)"""
    round_number = exam_round["round"]
    return {
        "@context": SCHEMA_CONTEXT,
        "@type": "Event",
        "name": f"제{round_number}회 SQLD(SQL 개발자) 자격검정 시험",
        "description": (f"제{round_number}회 SQLD 시험. 원서접수 {exam_round['application_start']}~{exam_round['application_end']}, "
                        f"합격자 발표 {exam_round['result']}. 접수와 세부 공지는 데이터자격검정 공식 사이트에서 확인."),
        "startDate": exam_round["exam"],
        "endDate": exam_round["exam"],
        "eventStatus": "https://schema.org/EventScheduled",
        "eventAttendanceMode": "https://schema.org/OfflineEventAttendanceMode",
        "location": {
            "@type": "Place",
            "name": "전국 지정 시험장 (원서접수 시 선택)",
            "address": {"@type": "PostalAddress", "addressCountry": "KR"},
        },
        "organizer": {"@type": "Organization", "name": EXAM_ORGANIZER_NAME, "url": content.OFFICIAL_EXAM_URL},
        "offers": {
            "@type": "Offer",
            "url": content.OFFICIAL_SCHEDULE_URL,
            "price": str(content.SQLD_EXAM_FEE_WON),
            "priceCurrency": "KRW",
            "validFrom": exam_round["application_start"],
        },
        "image": content.OG_IMAGE_URL,
        "inLanguage": "ko",
    }
