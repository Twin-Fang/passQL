package com.passql.question.constant;

import com.passql.common.util.RequestEnumParser;

/** 신고 사유: 욕설·비방, 광고·스팸, 정답 노출, 기타 */
public enum CommunityReportCategory {
    ABUSE("욕설·비방"),
    SPAM("광고·스팸"),
    ANSWER_SPOILER("정답 노출"),
    ETC("기타");

    // 관리자 화면 표시 이름
    private final String label;

    CommunityReportCategory(String label) {
        this.label = label;
    }

    public String getLabel() {
        return label;
    }

    /** 요청값 > CommunityReportCategory (null·공백·없는 값 > INVALID_INPUT_VALUE) */
    public static CommunityReportCategory fromRequestValue(String requestValue) {
        return RequestEnumParser.parse(CommunityReportCategory.class, requestValue);
    }
}
