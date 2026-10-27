package com.passql.web.controller.admin;

import com.passql.ai.constant.AiProvider;
import com.passql.ai.dto.AiConnectionApiKeyRequest;
import com.passql.ai.dto.AiConnectionCreateRequest;
import com.passql.ai.dto.AiConnectionHealth;
import com.passql.ai.dto.AiConnectionUpdateRequest;
import com.passql.ai.service.AiConnectionAdminService;
import com.passql.web.support.AdminMenu;
import com.passql.web.support.AdminPage;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.*;

import java.util.Map;
import java.util.UUID;

/**
 * 관리자 AI 연결 관리 (#695): 목록 화면, 추가·수정·키 교체·사용 전환·순서 이동·삭제·연결 확인
 */
@Controller
@RequestMapping("/admin/ai-connections")
@RequiredArgsConstructor
public class AdminAiConnectionController {

    private final AiConnectionAdminService aiConnectionAdminService;

    @GetMapping
    @AdminPage(menu = AdminMenu.AI_CONNECTIONS)
    public String list(Model model) {
        model.addAttribute("connections", aiConnectionAdminService.findAllViews());
        model.addAttribute("providers", AiProvider.values());
        return "admin/ai-connections";
    }

    @PostMapping
    @ResponseBody
    public ResponseEntity<Void> create(@Valid @RequestBody AiConnectionCreateRequest request) {
        aiConnectionAdminService.create(request);
        return ResponseEntity.ok().build();
    }

    @PutMapping("/{uuid}")
    @ResponseBody
    public ResponseEntity<Void> update(@PathVariable UUID uuid, @Valid @RequestBody AiConnectionUpdateRequest request) {
        aiConnectionAdminService.update(uuid, request);
        return ResponseEntity.ok().build();
    }

    @PutMapping("/{uuid}/api-key")
    @ResponseBody
    public ResponseEntity<Void> replaceApiKey(@PathVariable UUID uuid, @Valid @RequestBody AiConnectionApiKeyRequest request) {
        aiConnectionAdminService.replaceApiKey(uuid, request.apiKey());
        return ResponseEntity.ok().build();
    }

    /** 사용 켜기·끄기 (body: {"isEnabled": true}) */
    @PutMapping("/{uuid}/enabled")
    @ResponseBody
    public ResponseEntity<Void> changeEnabled(@PathVariable UUID uuid, @RequestBody Map<String, Boolean> body) {
        aiConnectionAdminService.changeEnabled(uuid, Boolean.TRUE.equals(body.get("isEnabled")));
        return ResponseEntity.ok().build();
    }

    /** 순서 한 칸 이동 (direction: up 앞으로, down 뒤로) */
    @PutMapping("/{uuid}/move")
    @ResponseBody
    public ResponseEntity<Void> move(@PathVariable UUID uuid, @RequestParam String direction) {
        aiConnectionAdminService.move(uuid, direction);
        return ResponseEntity.ok().build();
    }

    @DeleteMapping("/{uuid}")
    @ResponseBody
    public ResponseEntity<Void> delete(@PathVariable UUID uuid) {
        aiConnectionAdminService.delete(uuid);
        return ResponseEntity.ok().build();
    }

    /** 연결 확인 (키·기본 모델 조회 1회, 과금 없음) */
    @PostMapping("/{uuid}/check")
    @ResponseBody
    public AiConnectionHealth check(@PathVariable UUID uuid) {
        return aiConnectionAdminService.check(uuid);
    }
}
