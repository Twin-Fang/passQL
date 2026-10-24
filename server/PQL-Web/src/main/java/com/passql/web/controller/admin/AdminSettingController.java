package com.passql.web.controller.admin;

import com.passql.common.exception.CustomException;
import com.passql.common.exception.constant.ErrorCode;
import com.passql.meta.dto.AppSettingChangeHistory;
import com.passql.meta.dto.AppSettingRollbackRequest;
import com.passql.meta.service.AppSettingHistoryService;
import com.passql.meta.service.AppSettingService;
import com.passql.web.support.AdminMenu;
import com.passql.web.support.AdminPage;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.Map;

@Controller
@RequestMapping("/admin/settings")
@RequiredArgsConstructor
public class AdminSettingController {

    private final AppSettingService appSettingService;
    private final AppSettingHistoryService appSettingHistoryService;

    @GetMapping
    @AdminPage(menu = AdminMenu.SETTINGS)
    public String list(Model model) {
        model.addAttribute("settings", appSettingService.findAllAsView());
        return "admin/settings";
    }

    /** 비밀 설정(예: Gemini 키) 변경: 암호화 저장, 빈 값은 400 */
    @PutMapping("/{key}/secret")
    @ResponseBody
    public ResponseEntity<Void> updateSecretSetting(@PathVariable String key,
                                                    @RequestBody Map<String, String> body) {
        appSettingService.saveSecret(key, body.get("value"));
        return ResponseEntity.ok().build();
    }

    @PutMapping("/{key}")
    @ResponseBody
    public ResponseEntity<Void> updateSetting(@PathVariable String key,
                                              @RequestBody Map<String, String> body) {
        if (AppSettingService.isSensitiveKey(key)) {
            throw new CustomException(ErrorCode.SETTING_SENSITIVE_UPDATE_FORBIDDEN);
        }
        appSettingService.save(key, body.get("value"));
        return ResponseEntity.ok().build();
    }

    /** 설정 변경 이력 (최근 20건, 민감 키는 마스킹 값) */
    @GetMapping("/{key}/history")
    @ResponseBody
    public List<AppSettingChangeHistory> history(@PathVariable String key) {
        return appSettingHistoryService.findHistory(key);
    }

    /** 이력 1건의 이전 값으로 복원 (형식 검사·감사 기록은 일반 저장과 같음) */
    @PostMapping("/{key}/rollback")
    @ResponseBody
    public ResponseEntity<Void> rollback(@PathVariable String key,
                                         @Valid @RequestBody AppSettingRollbackRequest request) {
        appSettingHistoryService.rollback(key, request.auditLogUuid());
        return ResponseEntity.ok().build();
    }
}
