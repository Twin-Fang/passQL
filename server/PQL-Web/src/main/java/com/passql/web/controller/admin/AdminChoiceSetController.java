package com.passql.web.controller.admin;

import com.passql.web.support.AdminPageRequest;
import com.passql.question.entity.QuestionChoiceSet;
import com.passql.question.entity.QuestionChoiceSetItem;
import com.passql.question.service.AdminChoiceSetService;
import com.passql.web.support.AdminMenu;
import com.passql.web.support.AdminPage;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.data.domain.PageRequest;
import org.springframework.http.ResponseEntity;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.UUID;

/**
 * 관리자 선택지 세트 이력 조회 / 관리.
 */
@Slf4j
@Controller
@RequestMapping("/admin/choice-sets")
@RequiredArgsConstructor
public class AdminChoiceSetController {

    private final AdminChoiceSetService adminChoiceSetService;

    @GetMapping
    @AdminPage(menu = AdminMenu.CHOICE_SETS)
    public String list(Model model,
                       @RequestParam(defaultValue = "0") int page,
                       @RequestParam(defaultValue = AdminPageRequest.DEFAULT_PAGE_SIZE) int size) {
        model.addAttribute("choiceSets", adminChoiceSetService.getChoiceSets(AdminPageRequest.newestFirst(page, size)));
        return "admin/choice-sets";
    }

    @GetMapping("/{uuid}")
    @AdminPage(menu = AdminMenu.CHOICE_SETS, title = "선택지 세트 상세")
    public String detail(@PathVariable UUID uuid, Model model) {
        QuestionChoiceSet set = adminChoiceSetService.getChoiceSet(uuid);
        List<QuestionChoiceSetItem> items = adminChoiceSetService.getChoiceSetItems(uuid);
        model.addAttribute("choiceSet", set);
        model.addAttribute("items", items);
        return "admin/choice-set-detail";
    }

    /**
     * 선택지 세트 아이템 JSON 조회 — 신고 상세 화면에서 인라인 렌더에 사용.
     */
    @GetMapping("/{uuid}/items")
    @ResponseBody
    public ResponseEntity<List<QuestionChoiceSetItem>> getItems(@PathVariable UUID uuid) {
        return ResponseEntity.ok(adminChoiceSetService.getChoiceSetItems(uuid));
    }

    /**
     * 비활성화.
     */
    @PutMapping("/{uuid}/disable")
    @ResponseBody
    public ResponseEntity<Void> disable(@PathVariable UUID uuid) {
        adminChoiceSetService.disableChoiceSet(uuid);
        return ResponseEntity.ok().build();
    }

    /**
     * 재사용 풀 승격.
     */
    @PutMapping("/{uuid}/promote")
    @ResponseBody
    public ResponseEntity<Void> promote(@PathVariable UUID uuid) {
        adminChoiceSetService.promoteChoiceSetToReusable(uuid);
        return ResponseEntity.ok().build();
    }
}
