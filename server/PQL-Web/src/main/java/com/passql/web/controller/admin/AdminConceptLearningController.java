package com.passql.web.controller.admin;

import com.passql.application.concept.admin.ConceptAdminService;
import com.passql.application.concept.admin.ConceptBundleImportService;
import com.passql.application.concept.admin.dto.ConceptBundle;
import com.passql.application.concept.admin.dto.ConceptBundleImportResult;
import com.passql.application.concept.admin.dto.ConceptBundleValidationResult;
import com.passql.meta.constant.ConceptPublishStatus;
import com.passql.web.support.AdminMenu;
import com.passql.web.support.AdminPage;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.PutMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.ResponseBody;

import java.util.Map;
import java.util.UUID;

/**
 * 개념 학습 관리 (#577): 단원별 개념 목록, 묶음 검증·가져오기, 공개 상태 변경·일괄 공개, 본문 수정, 미리보기
 * 기존 개념 문서 화면(/admin/concepts)은 그대로 두고 같은 메뉴 아래 별도 화면
 */
@Controller
@RequestMapping("/admin/concepts/learning")
@RequiredArgsConstructor
public class AdminConceptLearningController {

    private final ConceptAdminService conceptAdminService;
    private final ConceptBundleImportService conceptBundleImportService;

    /** 단원별 개념 목록 화면 */
    @GetMapping
    @AdminPage(menu = AdminMenu.CONCEPTS)
    public String list(Model model) {
        model.addAttribute("topicGroups", conceptAdminService.listByTopic());
        return "admin/concept-learning";
    }

    /** 개념 미리보기 화면 (앱과 같은 순서, 정답 포함) */
    @GetMapping("/{conceptUuid}/preview")
    @AdminPage(menu = AdminMenu.CONCEPTS)
    public String preview(@PathVariable UUID conceptUuid, Model model) {
        model.addAttribute("preview", conceptAdminService.getPreview(conceptUuid));
        return "admin/concept-preview";
    }

    /** 묶음 검증만 (저장 없음) */
    @PostMapping("/import/validate")
    @ResponseBody
    public ResponseEntity<ConceptBundleValidationResult> validateBundle(@RequestBody ConceptBundle bundle) {
        return ResponseEntity.ok(conceptBundleImportService.validate(bundle));
    }

    /** 묶음 가져오기 (검증 실패면 400, 아무것도 저장 안 함) */
    @PostMapping("/import")
    @ResponseBody
    public ResponseEntity<ConceptBundleImportResult> importBundle(@RequestBody ConceptBundle bundle) {
        return ResponseEntity.ok(conceptAdminService.importBundle(bundle));
    }

    /** 공개 상태 변경 (JSON body: { "status": "PUBLISHED" | "DRAFT" }) */
    @PutMapping("/{conceptUuid}/status")
    @ResponseBody
    public ResponseEntity<Void> changeStatus(@PathVariable UUID conceptUuid, @RequestBody Map<String, String> body) {
        conceptAdminService.changePublishStatus(conceptUuid, ConceptPublishStatus.valueOf(body.get("status")));
        return ResponseEntity.ok().build();
    }

    /** 일괄 공개 (확인 문제 5개를 갖춘 초안만) */
    @PostMapping("/publish-all")
    @ResponseBody
    public ResponseEntity<Map<String, Integer>> publishAll() {
        return ResponseEntity.ok(Map.of("publishedCount", conceptAdminService.publishAll()));
    }

    /** 본문 수정 (JSON body: title, summary, coreMd, detailMd) */
    @PutMapping("/{conceptUuid}/content")
    @ResponseBody
    public ResponseEntity<Void> updateContent(@PathVariable UUID conceptUuid, @RequestBody Map<String, String> body) {
        conceptAdminService.updateContent(conceptUuid, body.get("title"), body.get("summary"),
            body.get("coreMd"), body.get("detailMd"));
        return ResponseEntity.ok().build();
    }
}
