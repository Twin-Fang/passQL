package com.passql.application.community;

/**
 * 뜨는 토론 점수: (의견 수 x 2 + 좋아요 수) / (마지막 활동 후 경과 시간 + 2)^1.5
 * 최근 72시간 안에 활동이 있는 문제만 피드 후보
 */
public final class CommunityHotScore {

    // 뜨는 토론 후보 기준: 마지막 활동 후 경과 시간 (시간)
    public static final int ACTIVE_WINDOW_HOURS = 72;
    private static final double POST_WEIGHT = 2.0;
    private static final double DECAY_BASE_HOURS = 2.0;
    private static final double DECAY_EXPONENT = 1.5;

    private CommunityHotScore() {
    }

    public static double calculate(long postCount, long likeCount, double hoursSinceLastActivity) {
        double engagement = postCount * POST_WEIGHT + likeCount;
        return engagement / Math.pow(Math.max(hoursSinceLastActivity, 0.0) + DECAY_BASE_HOURS, DECAY_EXPONENT);
    }
}
