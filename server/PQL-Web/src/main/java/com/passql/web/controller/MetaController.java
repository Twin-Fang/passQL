package com.passql.web.controller;

import com.passql.meta.constant.LegalType;
import com.passql.meta.dto.AppLinksResponse;
import com.passql.meta.dto.LegalResponse;
import com.passql.meta.dto.TopicTree;
import com.passql.meta.entity.ConceptTag;
import com.passql.meta.service.AppSettingService;
import com.passql.meta.service.LegalService;
import com.passql.meta.service.MetaService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api")
@RequiredArgsConstructor
public class MetaController implements MetaControllerDocs {

    private final MetaService metaService;
    private final LegalService legalService;
    private final AppSettingService appSettingService;

    @GetMapping("/meta/topics")
    public ResponseEntity<List<TopicTree>> getTopics() {
        return ResponseEntity.ok(metaService.getTopicTree());
    }

    @GetMapping("/meta/tags")
    public ResponseEntity<List<ConceptTag>> getTags() {
        return ResponseEntity.ok(metaService.getActiveTags());
    }

    /** 공개 약관 조회 — type: TERMS_OF_SERVICE | PRIVACY_POLICY, 인증 불필요 */
    @GetMapping("/meta/legal/{type}")
    public ResponseEntity<LegalResponse> getLegal(@PathVariable LegalType type) {
        return ResponseEntity.ok(legalService.getPublished(type));
    }

    /** 스토어 다운로드 링크 — 인증 불필요. 출시 전에는 두 필드 모두 null (#433) */
    @GetMapping("/meta/app-links")
    public ResponseEntity<AppLinksResponse> getAppLinks() {
        return ResponseEntity.ok(appSettingService.getAppLinks());
    }
}
