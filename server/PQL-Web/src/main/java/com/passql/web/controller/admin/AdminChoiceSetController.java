package com.passql.web.controller.admin;

import com.passql.question.constant.ChoiceSetSource;
import com.passql.question.constant.ChoiceSetStatus;
import com.passql.question.dto.AdminChoiceSetBulkRequest;
import com.passql.question.dto.AdminChoiceSetBulkResult;
import com.passql.question.dto.AdminChoiceSetSearchCondition;
import com.passql.question.dto.ChoiceSetIntegrityAuditPage;
import com.passql.web.support.AdminPageRequest;
import com.passql.question.entity.QuestionChoiceSet;
import com.passql.question.entity.QuestionChoiceSetItem;
import com.passql.question.service.AdminChoiceSetService;
import com.passql.question.service.ChoiceSetGenerationService;
import com.passql.question.service.ChoiceSetIntegrityAuditService;
import com.passql.web.support.AdminMenu;
import com.passql.web.support.AdminPage;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
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
    private final ChoiceSetIntegrityAuditService choiceSetIntegrityAuditService;
    private final ChoiceSetGenerationService choiceSetGenerationService;

    @GetMapping
    @AdminPage(menu = AdminMenu.CHOICE_SETS)
    public String list(Model model,
                       AdminChoiceSetSearchCondition condition,
                       @RequestParam(defaultValue = "0") int page,
                       @RequestParam(defaultValue = AdminPageRequest.DEFAULT_PAGE_SIZE) int size) {
        model.addAttribute("choiceSets", adminChoiceSetService.getChoiceSets(condition, AdminPageRequest.newestFirst(page, size)));
        model.addAttribute("condition", condition);
        model.addAttribute("sources", ChoiceSetSource.values());
        model.addAttribute("statuses", ChoiceSetStatus.values());
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

    /** 선택 세트 일괄 비활성화 (JSON body: { "choiceSetUuids": [...] }) */
    @PutMapping("/bulk-disable")
    @ResponseBody
    public ResponseEntity<AdminChoiceSetBulkResult> bulkDisable(@RequestBody AdminChoiceSetBulkRequest request) {
        return ResponseEntity.ok(adminChoiceSetService.disableChoiceSets(request.choiceSetUuids()));
    }

    /** 선택 세트 일괄 재사용 풀 승격 (JSON body: { "choiceSetUuids": [...] }), 상태 OK 세트만 */
    @PutMapping("/bulk-promote")
    @ResponseBody
    public ResponseEntity<AdminChoiceSetBulkResult> bulkPromote(@RequestBody AdminChoiceSetBulkRequest request) {
        return ResponseEntity.ok(adminChoiceSetService.promoteChoiceSets(request.choiceSetUuids()));
    }

    /** 노출 중 세트 전수 검증 1페이지 (#828, 읽기 전용: 내리기는 bulk-disable) */
    @GetMapping("/integrity-audit")
    @ResponseBody
    public ResponseEntity<ChoiceSetIntegrityAuditPage> integrityAudit(
            @RequestParam(defaultValue = "0") int page,
            @RequestParam(defaultValue = "20") int size) {
        return ResponseEntity.ok(choiceSetIntegrityAuditService.auditPage(page, size));
    }

    /** 문제 1개 새 세트 생성 (#828): 정책별 경로, 검증 통과 세트만 저장 > 새 세트 UUID */
    @PostMapping("/regenerate/{questionUuid}")
    @ResponseBody
    public ResponseEntity<UUID> regenerate(@PathVariable UUID questionUuid) {
        QuestionChoiceSet choiceSet = choiceSetGenerationService.generateForQuestion(
                questionUuid, null, ChoiceSetSource.AI_RUNTIME);
        return ResponseEntity.ok(choiceSet.getChoiceSetUuid());
    }
}
