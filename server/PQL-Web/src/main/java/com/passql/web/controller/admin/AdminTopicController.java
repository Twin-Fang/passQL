package com.passql.web.controller.admin;

import com.passql.meta.dto.TopicCreateRequest;
import com.passql.meta.dto.TopicOrderRequest;
import com.passql.meta.dto.TopicUpdateRequest;
import com.passql.meta.service.MetaService;
import com.passql.web.service.AdminTopicManagementService;
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
    private final AdminTopicManagementService adminTopicManagementService;

    @GetMapping
    @AdminPage(menu = AdminMenu.TOPICS)
    public String list(Model model, @RequestParam(required = false) String topicCode) {
        model.addAttribute("topics", metaService.getTopicTree());
        model.addAttribute("selectedTopicCode", topicCode);
        model.addAttribute("topicQuestionCountByUuid", adminTopicManagementService.countQuestionsByTopicUuid());
        model.addAttribute("subtopicQuestionCountByUuid", adminTopicManagementService.countQuestionsBySubtopicUuid());
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

    /** 서브토픽 편집 — displayName, sortOrder, isActive 수정 */
    @PutMapping("/{topicCode}/subtopics/{subtopicCode}")
    @ResponseBody
    public ResponseEntity<Void> updateSubtopic(
            @PathVariable String topicCode,
            @PathVariable String subtopicCode,
            @Valid @RequestBody TopicUpdateRequest request) {
        metaService.updateSubtopic(topicCode, subtopicCode, request);
        return ResponseEntity.ok().build();
    }

    /** 토픽 삭제 — 소속 문제가 있으면 409 와 안내 문구 */
    @DeleteMapping("/{code}")
    @ResponseBody
    public ResponseEntity<Void> deleteTopic(@PathVariable String code) {
        adminTopicManagementService.deleteTopic(code);
        return ResponseEntity.ok().build();
    }

    /** 서브토픽 삭제 — 소속 문제가 있으면 409 와 안내 문구 */
    @DeleteMapping("/{topicCode}/subtopics/{subtopicCode}")
    @ResponseBody
    public ResponseEntity<Void> deleteSubtopic(@PathVariable String topicCode, @PathVariable String subtopicCode) {
        adminTopicManagementService.deleteSubtopic(topicCode, subtopicCode);
        return ResponseEntity.ok().build();
    }

    /** 토픽 순서 변경 (JSON body: { "orderedCodes": [전체 토픽 코드를 새 순서로] }) */
    @PostMapping("/order")
    @ResponseBody
    public ResponseEntity<Void> reorderTopics(@Valid @RequestBody TopicOrderRequest request) {
        metaService.reorderTopics(request.orderedCodes());
        return ResponseEntity.ok().build();
    }

    /** 서브토픽 순서 변경 (JSON body: { "orderedCodes": [해당 토픽의 전체 서브토픽 코드를 새 순서로] }) */
    @PostMapping("/{topicCode}/subtopics/order")
    @ResponseBody
    public ResponseEntity<Void> reorderSubtopics(@PathVariable String topicCode,
                                                 @Valid @RequestBody TopicOrderRequest request) {
        metaService.reorderSubtopics(topicCode, request.orderedCodes());
        return ResponseEntity.ok().build();
    }
}
