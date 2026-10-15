package com.passql.web.controller.admin;

import com.passql.meta.constant.LegalStatus;
import com.passql.meta.constant.LegalType;
import com.passql.meta.dto.LegalUpdateRequest;
import com.passql.meta.service.LegalService;
import com.passql.web.support.AdminMenu;
import com.passql.web.support.AdminPage;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.*;

@Controller
@RequestMapping("/admin/legal")
@RequiredArgsConstructor
public class AdminLegalController implements AdminLegalControllerDocs {

    private final LegalService legalService;

    @GetMapping
    @AdminPage(menu = AdminMenu.LEGAL)
    public String list(Model model) {
        model.addAttribute("legals", legalService.findAll());
        model.addAttribute("legalTypes", LegalType.values());
        // 약관 종류별 이전 본문 (수정 시 보관, #469)
        model.addAttribute("historiesByType", legalService.findRecentHistoriesByType());
        return "admin/legal";
    }

    @PutMapping("/{type}")
    @ResponseBody
    public ResponseEntity<Void> update(@PathVariable LegalType type,
                                       @Valid @RequestBody LegalUpdateRequest request) {
        legalService.update(type, request);
        return ResponseEntity.ok().build();
    }

    @PutMapping("/{type}/status")
    @ResponseBody
    public ResponseEntity<Void> updateStatus(@PathVariable LegalType type,
                                             @RequestParam LegalStatus status) {
        legalService.updateStatus(type, status);
        return ResponseEntity.ok().build();
    }
}
