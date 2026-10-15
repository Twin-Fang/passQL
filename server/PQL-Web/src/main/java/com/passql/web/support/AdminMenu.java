package com.passql.web.support;

import lombok.Getter;
import lombok.RequiredArgsConstructor;

/**
 * 관리자 메뉴 단일 원본: 사이드바 활성 코드(currentMenu) + 기본 화면 제목(pageTitle)
 * layout.html 의 currentMenu 비교 문자열과 code 를 같게 유지
 */
@Getter
@RequiredArgsConstructor
public enum AdminMenu {

    DASHBOARD("dashboard", "대시보드"),
    MEMBERS("members", "회원 관리"),
    QUESTIONS("questions", "문제 관리"),
    CHOICE_SETS("choice-sets", "선택지 세트 이력"),
    PROMPTS("prompts", "프롬프트 관리"),
    TOPICS("topics", "토픽/태그 관리"),
    CONCEPTS("concepts", "개념 문서 관리"),
    DAILY_CHALLENGES("daily-challenges", "일일 챌린지 관리"),
    EXAM_SCHEDULES("exam-schedules", "시험 일정 관리"),
    FEEDBACKS("feedbacks", "건의사항 관리"),
    REPORTS("reports", "신고 관리"),
    LEGAL("legal", "약관 관리"),
    SETTINGS("settings", "앱 설정"),
    EMBEDDINGS("embeddings", "임베딩 인덱스 관리"),
    MONITOR("monitor", "모니터링");

    // layout.html 사이드바 활성 표시용 코드
    private final String code;
    // @AdminPage title 미지정 시 화면 제목
    private final String defaultTitle;
}
