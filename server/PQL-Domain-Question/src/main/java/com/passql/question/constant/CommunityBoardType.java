package com.passql.question.constant;

/** 커뮤니티 게시판 종류 (1차는 QUESTION_OPINION 만 사용, 나머지는 값만 예약) */
public enum CommunityBoardType {
    QUESTION_OPINION,  // 문제별 의견
    EXAM_REVIEW,       // 시험 후기 (예약)
    FREE,              // 자유 게시판 (예약)
    QNA                // 질문 (예약)
}
