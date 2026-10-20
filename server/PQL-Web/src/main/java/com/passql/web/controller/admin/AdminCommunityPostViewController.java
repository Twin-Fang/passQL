package com.passql.web.controller.admin;

import com.passql.web.support.AdminMenu;
import com.passql.web.support.AdminPage;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;

/** 토론 게시글 관리 화면 (#557): 목록은 화면 JS 가 /admin/api/community/posts 로 조회 */
@Controller
@RequestMapping("/admin/community/posts")
public class AdminCommunityPostViewController {

    @GetMapping
    @AdminPage(menu = AdminMenu.COMMUNITY_POSTS)
    public String communityPostsPage() {
        return "admin/community-posts";
    }
}
