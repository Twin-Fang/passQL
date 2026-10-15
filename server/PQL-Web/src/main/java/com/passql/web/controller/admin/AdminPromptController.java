package com.passql.web.controller.admin;

import com.passql.ai.client.AiGatewayClient;
import com.passql.ai.dto.LlmConfigDto;
import com.passql.ai.dto.TestPromptRequest;
import com.passql.ai.dto.TestPromptResult;
import com.passql.meta.dto.PromptTemplateSaveRequest;
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

import java.util.Map;
import java.util.UUID;

@Slf4j
@Controller
@RequestMapping("/admin/prompts")
@RequiredArgsConstructor
public class AdminPromptController {

    private final PromptService promptService;
    private final AiGatewayClient aiGatewayClient;

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
    public String create(@Valid @ModelAttribute PromptTemplateSaveRequest request, RedirectAttributes redirectAttributes) {
        PromptTemplate created = promptService.create(request);
        redirectAttributes.addFlashAttribute(AdminFlash.TOAST_MESSAGE, "프롬프트를 등록했습니다.");
        return "redirect:/admin/prompts/" + created.getPromptTemplateUuid();
    }

    @PutMapping("/{uuid}")
    public String update(@PathVariable UUID uuid, @Valid @ModelAttribute PromptTemplateSaveRequest request,
                         RedirectAttributes redirectAttributes) {
        promptService.update(uuid, request);
        redirectAttributes.addFlashAttribute(AdminFlash.TOAST_MESSAGE, "프롬프트를 저장했습니다.");
        return "redirect:/admin/prompts/" + uuid;
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
     * 프롬프트 테스트 실행 (JSON).
     */
    @PostMapping("/{uuid}/test")
    @ResponseBody
    public ResponseEntity<TestPromptResult> testExecute(
            @PathVariable UUID uuid,
            @RequestBody Map<String, String> variables) {
        PromptTemplate prompt = promptService.findById(uuid)
                .orElseThrow(() -> new com.passql.common.exception.CustomException(
                        com.passql.common.exception.constant.ErrorCode.PROMPT_NOT_FOUND));

        LlmConfigDto llmConfig = new LlmConfigDto(
                prompt.getModel(),
                prompt.getSystemPrompt(),
                prompt.getUserTemplate(),
                prompt.getTemperature(),
                prompt.getMaxTokens(),
                null
        );

        TestPromptRequest req = new TestPromptRequest(llmConfig, variables);
        TestPromptResult result = aiGatewayClient.testPrompt(req);
        return ResponseEntity.ok(result);
    }

    /**
     * 버전 활성화.
     */
    @PutMapping("/{uuid}/activate")
    @ResponseBody
    public ResponseEntity<Void> activate(@PathVariable UUID uuid) {
        promptService.activateVersion(uuid);
        return ResponseEntity.ok().build();
    }
}
