package com.passql.web.controller.admin;

import com.passql.meta.constant.ConceptDocSortType;
import com.passql.meta.dto.OrderedCodesRequest;
import com.passql.meta.service.MetaService;
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

@Controller
@RequestMapping("/admin/concepts")
@RequiredArgsConstructor
public class AdminConceptController {

    private final MetaService metaService;

    /** 개념 문서 목록: 태그 선택 또는 검색어(제목·본문)로 문서 조회 + 정렬 */
    @GetMapping
    @AdminPage(menu = AdminMenu.CONCEPTS)
    public String list(Model model,
                       @RequestParam(required = false) String tagKey,
                       @RequestParam(required = false) String keyword,
                       @RequestParam(required = false) String sort) {
        ConceptDocSortType sortType = ConceptDocSortType.fromRequestValueOrRecentlyUpdated(sort);
        model.addAttribute("conceptTags", metaService.getActiveTags());
        model.addAttribute("conceptDocs", metaService.searchDocs(tagKey, keyword, sortType));
        model.addAttribute("tagKeyByUuid", metaService.getTagKeyByUuid());
        model.addAttribute("selectedTagKey", tagKey);
        model.addAttribute("keyword", keyword);
        model.addAttribute("selectedSort", sortType.name());
        model.addAttribute("sortTypes", ConceptDocSortType.values());
        return "admin/concepts";
    }

    @PostMapping
    public String createDoc(@RequestParam String tagKey,
                            @RequestParam String title,
                            @RequestParam(required = false) String bodyMd) {
        metaService.createDoc(tagKey, title, bodyMd);
        return "redirect:/admin/concepts?tagKey=" + tagKey;
    }

    @PutMapping("/{uuid}")
    @ResponseBody
    public ResponseEntity<Void> updateDoc(@PathVariable UUID uuid,
                                          @RequestBody Map<String, String> body) {
        metaService.updateDocBody(uuid, body.get("bodyMd"));
        return ResponseEntity.ok().build();
    }

    /** 개념 문서 삭제 (#479) */
    @DeleteMapping("/{uuid}")
    @ResponseBody
    public ResponseEntity<Void> deleteDoc(@PathVariable UUID uuid) {
        metaService.deleteDoc(uuid);
        return ResponseEntity.ok().build();
    }

    /** 개념 태그 순서 변경 (JSON body: { "orderedCodes": [활성 태그 전체 tagKey 를 새 순서로] }) */
    @PostMapping("/tags/order")
    @ResponseBody
    public ResponseEntity<Void> reorderTags(@Valid @RequestBody OrderedCodesRequest request) {
        metaService.reorderConceptTags(request.orderedCodes());
        return ResponseEntity.ok().build();
    }
}
