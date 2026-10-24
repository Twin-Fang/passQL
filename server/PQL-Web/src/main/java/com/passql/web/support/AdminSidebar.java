package com.passql.web.support;

import java.util.List;

/**
 * 관리자 사이드바 메뉴 단일 원본: 그룹 5개(개요, 회원·커뮤니티, 콘텐츠, AI, 운영) > 항목 (layout.html 이 순회해 그림)
 * 메뉴 추가 = 해당 그룹의 항목 목록에 item(...) 한 줄 추가 (menuCode 는 AdminMenu.code 와 같게)
 */
public final class AdminSidebar {

    /** 그룹 제목 + 항목 목록 */
    public record Group(String title, List<Item> items) {
    }

    /**
     * 메뉴 항목 1개
     * menuCode: currentMenu 와 같으면 활성 표시, iconName: lucide 아이콘, isWriteOnly: ADMIN 역할에만 노출
     */
    public record Item(String menuCode, String path, String iconName, String label, boolean isWriteOnly) {
    }

    // 사이드바 전체 (표시 순서 = 목록 순서)
    public static final List<Group> GROUPS = List.of(
            new Group("개요", List.of(
                    item("dashboard", "/admin", "layout-dashboard", "대시보드"),
                    item("statistics", "/admin/statistics", "chart-line", "AI 사용량·통계"),
                    item("subscriptions", "/admin/subscriptions", "credit-card", "구독·매출 현황"),
                    item("retention", "/admin/retention", "repeat", "리텐션·코호트"))),
            new Group("회원·커뮤니티", List.of(
                    item("members", "/admin/members", "users", "회원 관리"),
                    item("community-posts", "/admin/community/posts", "message-square-text", "토론 게시글"),
                    item("community-reports", "/admin/community/reports", "messages-square", "커뮤니티 신고"),
                    item("feedbacks", "/admin/feedbacks", "message-circle", "건의사항"),
                    item("push", "/admin/push", "bell", "알림 발송"))),
            new Group("콘텐츠", List.of(
                    item("questions", "/admin/questions", "book-open", "문제 관리"),
                    item("reports", "/admin/reports", "flag", "신고 관리"),
                    item("daily-challenges", "/admin/daily-challenges", "calendar-check", "일일 챌린지"),
                    item("topics", "/admin/topics", "tags", "토픽/태그 관리"),
                    item("concepts", "/admin/concepts", "book", "개념 문서 관리"),
                    item("exam-schedules", "/admin/exam-schedules", "calendar-days", "시험 일정"))),
            new Group("AI", List.of(
                    item("prompts", "/admin/prompts", "message-square-code", "프롬프트 관리"),
                    item("embeddings", "/admin/embeddings", "layers", "임베딩 관리"))),
            new Group("운영", List.of(
                    item("monitor", "/admin/monitor", "activity", "모니터링"),
                    item("app-operation", "/admin/app-operation", "megaphone", "앱 운영"),
                    item("settings", "/admin/settings", "settings", "앱 설정"),
                    item("legal", "/admin/legal", "file-text", "약관 관리"),
                    item("audit-logs", "/admin/audit-logs", "scroll-text", "감사 로그"),
                    writeOnlyItem("admin-accounts", "/admin/accounts", "user-cog", "관리자 계정"))));

    private AdminSidebar() {
    }

    private static Item item(String menuCode, String path, String iconName, String label) {
        return new Item(menuCode, path, iconName, label, false);
    }

    private static Item writeOnlyItem(String menuCode, String path, String iconName, String label) {
        return new Item(menuCode, path, iconName, label, true);
    }
}
