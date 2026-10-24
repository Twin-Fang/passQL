package com.passql.application.service;

import com.passql.application.community.CommunityAdminService;
import com.passql.meta.service.FeedbackService;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.cache.annotation.Cacheable;
import org.springframework.stereotype.Service;

import java.util.Map;

/**
 * 사이드바 미처리 건수 뱃지: 문제 신고, 건의, 토론 신고 (대시보드와 같은 count 쿼리)
 * 기본 캐시(5초)로 화면 이동마다 쿼리가 나가지 않게 함, 조회 실패는 뱃지만 생략
 */
@Slf4j
@Service
@RequiredArgsConstructor
public class AdminSidebarBadgeService {

    // 사이드바 메뉴 코드 (AdminSidebar 항목의 menuCode 와 같은 값)
    public static final String REPORTS_MENU_CODE = "reports";
    public static final String FEEDBACKS_MENU_CODE = "feedbacks";
    public static final String COMMUNITY_REPORTS_MENU_CODE = "community-reports";

    private static final String BADGE_CACHE_NAME = "adminSidebarBadges";

    private final QuestionReportService questionReportService;
    private final FeedbackService feedbackService;
    private final CommunityAdminService communityAdminService;

    /** 메뉴 코드 > 미처리 건수 (0건인 메뉴도 포함, 실패하면 빈 맵) */
    @Cacheable(BADGE_CACHE_NAME)
    public Map<String, Long> countPendingByMenuCode() {
        try {
            return Map.of(
                    REPORTS_MENU_CODE, questionReportService.countPendingReports(),
                    FEEDBACKS_MENU_CODE, feedbackService.countPending(),
                    COMMUNITY_REPORTS_MENU_CODE, communityAdminService.countPendingPosts());
        } catch (Exception e) {
            log.warn("[admin sidebar badge] count failed : {}", e.getClass().getSimpleName());
            return Map.of();
        }
    }
}
