package com.passql.web.controller.admin;

import com.passql.ai.dto.TestPromptResult;
import com.passql.application.service.AdminPromptTestService;
import com.passql.meta.dto.PromptHistoryItem;
import com.passql.meta.dto.PromptTemplateSaveRequest;
import com.passql.meta.dto.PromptTestHistoryItem;
import com.passql.meta.dto.PromptVersionItem;
import com.passql.meta.entity.PromptTemplate;
import com.passql.meta.service.PromptService;
import com.passql.web.support.AdminFlash;
import com.passql.web.support.AdminMenu;
import com.passql.web.support.AdminPage;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.http.ResponseEntity;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.servlet.mvc.support.RedirectAttributes;

import java.security.Principal;
import java.util.List;
import java.util.Map;
import java.util.UUID;

@Slf4j
@Controller
@RequestMapping("/admin/prompts")
@RequiredArgsConstructor
public class AdminPromptController {

    private final PromptService promptService;
    private final AdminPromptTestService adminPromptTestService;

    @GetMapping
    @AdminPage(menu = AdminMenu.PROMPTS)
    public String list(Model model) {
        model.addAttribute("promptTemplates", promptService.findAll());
        return "admin/prompts";
    }

    @GetMapping("/{uuid}")
    @AdminPage(menu = AdminMenu.PROMPTS)
    public String detail(@PathVariable UUID uuid, Model model) {
        model.addAttribute("promptTemplates", promptService.findAll());
        promptService.findById(uuid)
                .ifPresent(pt -> model.addAttribute("selectedPrompt", pt));
        return "admin/prompts";
    }

    @PostMapping
    public String create(@Valid @ModelAttribute PromptTemplateSaveRequest request, Principal adminPrincipal,
                         RedirectAttributes redirectAttributes) {
        PromptTemplate created = promptService.create(request, adminPrincipal.getName());
        redirectAttributes.addFlashAttribute(AdminFlash.TOAST_MESSAGE, "프롬프트를 등록했습니다.");
        return "redirect:/admin/prompts/" + created.getPromptTemplateUuid();
    }

    @PutMapping("/{uuid}")
    public String update(@PathVariable UUID uuid, @Valid @ModelAttribute PromptTemplateSaveRequest request,
                         Principal adminPrincipal, RedirectAttributes redirectAttributes) {
        promptService.update(uuid, request, adminPrincipal.getName());
        redirectAttributes.addFlashAttribute(AdminFlash.TOAST_MESSAGE, "프롬프트를 저장했습니다.");
        return "redirect:/admin/prompts/" + uuid;
    }

    /**
     * 프롬프트 삭제 (JSON, 활성 버전은 409).
     */
    @DeleteMapping("/{uuid}")
    @ResponseBody
    public ResponseEntity<Void> delete(@PathVariable UUID uuid, Principal adminPrincipal) {
        promptService.delete(uuid, adminPrincipal.getName());
        return ResponseEntity.ok().build();
    }

    /**
     * 프롬프트 테스트 페이지.
     */
    @GetMapping("/{uuid}/test")
    @AdminPage(menu = AdminMenu.PROMPTS, title = "프롬프트 테스트")
    public String testPage(@PathVariable UUID uuid, Model model) {
        promptService.findById(uuid)
                .ifPresent(pt -> model.addAttribute("prompt", pt));
        model.addAttribute("promptTemplates", promptService.findAll());
        return "admin/prompt-test";
    }

    /**
     * 프롬프트 테스트 실행 (JSON, 결과는 테스트 이력에 저장).
     */
    @PostMapping("/{uuid}/test")
    @ResponseBody
    public ResponseEntity<TestPromptResult> testExecute(
            @PathVariable UUID uuid,
            @RequestBody Map<String, String> variables,
            Principal adminPrincipal) {
        return ResponseEntity.ok(adminPromptTestService.testPrompt(uuid, variables, adminPrincipal.getName()));
    }

    /**
     * 프롬프트 테스트 결과 이력 (JSON, 최신순).
     */
    @GetMapping("/{uuid}/test-history")
    @ResponseBody
    public ResponseEntity<List<PromptTestHistoryItem>> testHistory(@PathVariable UUID uuid) {
        return ResponseEntity.ok(promptService.listTestHistory(uuid));
    }

    /**
     * 버전 활성화.
     */
    @PutMapping("/{uuid}/activate")
    @ResponseBody
    public ResponseEntity<Void> activate(@PathVariable UUID uuid, Principal adminPrincipal) {
        promptService.activateVersion(uuid, adminPrincipal.getName());
        return ResponseEntity.ok().build();
    }

    /**
     * 같은 키의 전체 버전 (JSON, 버전 간 diff·롤백용).
     */
    @GetMapping("/{uuid}/versions")
    @ResponseBody
    public ResponseEntity<List<PromptVersionItem>> versions(@PathVariable UUID uuid) {
        return ResponseEntity.ok(promptService.listVersionItems(uuid));
    }

    /**
     * 변경 이력 (JSON, 최신순).
     */
    @GetMapping("/{uuid}/history")
    @ResponseBody
    public ResponseEntity<List<PromptHistoryItem>> history(@PathVariable UUID uuid) {
        return ResponseEntity.ok(promptService.listHistory(uuid));
    }

    /**
     * 변경 이력 시점으로 본문 되돌리기 (JSON).
     */
    @PostMapping("/history/{historyUuid}/restore")
    @ResponseBody
    public ResponseEntity<Void> restoreFromHistory(@PathVariable UUID historyUuid, Principal adminPrincipal) {
        promptService.restoreFromHistory(historyUuid, adminPrincipal.getName());
        return ResponseEntity.ok().build();
    }
}
