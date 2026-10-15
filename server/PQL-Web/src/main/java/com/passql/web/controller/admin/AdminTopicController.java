package com.passql.web.controller.admin;

import com.passql.meta.dto.TopicCreateRequest;
import com.passql.meta.dto.TopicUpdateRequest;
import com.passql.meta.service.MetaService;
import com.passql.web.support.AdminMenu;
import com.passql.web.support.AdminPage;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.*;

@Controller
@RequestMapping("/admin/topics")
@RequiredArgsConstructor
public class AdminTopicController {

    private final MetaService metaService;

    @GetMapping
    @AdminPage(menu = AdminMenu.TOPICS)
    public String list(Model model, @RequestParam(required = false) String topicCode) {
        model.addAttribute("topics", metaService.getTopicTree());
        model.addAttribute("selectedTopicCode", topicCode);
        if (topicCode != null) {
            model.addAttribute("subtopics", metaService.getSubtopics(topicCode));
        }
        return "admin/topics";
    }

    /** 토픽 추가 (#479) */
    @PostMapping
    @ResponseBody
    public ResponseEntity<Void> createTopic(@Valid @RequestBody TopicCreateRequest request) {
        metaService.createTopic(request);
        return ResponseEntity.ok().build();
    }

    /** 서브토픽 추가 (#479) */
    @PostMapping("/{topicCode}/subtopics")
    @ResponseBody
    public ResponseEntity<Void> createSubtopic(@PathVariable String topicCode,
                                               @Valid @RequestBody TopicCreateRequest request) {
        metaService.createSubtopic(topicCode, request);
        return ResponseEntity.ok().build();
    }

    /** 토픽 편집 — displayName, sortOrder, isActive 수정 */
    @PutMapping("/{code}")
    @ResponseBody
    public ResponseEntity<Void> updateTopic(
            @PathVariable String code,
            @Valid @RequestBody TopicUpdateRequest request) {
        metaService.updateTopic(code, request);
        return ResponseEntity.ok().build();
    }
}
