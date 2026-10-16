package com.passql.web.controller.admin;

import com.passql.common.exception.CustomException;
import com.passql.common.exception.constant.ErrorCode;
import com.passql.meta.service.AppSettingService;
import com.passql.web.support.AdminMenu;
import com.passql.web.support.AdminPage;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.*;

import java.util.Map;

@Controller
@RequestMapping("/admin/settings")
@RequiredArgsConstructor
public class AdminSettingController {

    private final AppSettingService appSettingService;

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
}
