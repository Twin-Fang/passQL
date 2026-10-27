package com.passql.web.controller.admin;

import com.passql.application.concept.admin.ConceptAdminService;
import com.passql.application.concept.admin.ConceptBundleImportService;
import com.passql.application.concept.admin.dto.ConceptBundle;
import com.passql.application.concept.admin.dto.ConceptBundleItemIssue;
import com.passql.application.concept.admin.dto.ConceptBundleValidationResult;
import com.passql.meta.constant.ConceptPublishStatus;
import org.junit.jupiter.api.Test;

import java.util.List;
import java.util.Map;
import java.util.UUID;

import static org.assertj.core.api.Assertions.assertThat;
import static org.mockito.Mockito.mock;
import static org.mockito.Mockito.verify;
import static org.mockito.Mockito.when;

/** 개념 학습 관리 (#577): 검증 결과 그대로 반환, 상태 문자열 > enum, 본문 칸 전달 */
class AdminConceptLearningControllerTest {

    private final ConceptAdminService conceptAdminService = mock(ConceptAdminService.class);
    private final ConceptBundleImportService conceptBundleImportService = mock(ConceptBundleImportService.class);
    private final AdminConceptLearningController controller =
        new AdminConceptLearningController(conceptAdminService, conceptBundleImportService);

    @Test
    void import_validate_returnsIssues() {
        ConceptBundle bundle = new ConceptBundle(List.of());
        ConceptBundleValidationResult result = new ConceptBundleValidationResult(false,
            List.of(new ConceptBundleItemIssue("entity", "rereadAnchor", "anchor not in detailMd: x")));
        when(conceptBundleImportService.validate(bundle)).thenReturn(result);

        assertThat(controller.validateBundle(bundle).getBody()).isEqualTo(result);
    }

    @Test
    void status_put_changesStatus() {
        UUID conceptUuid = UUID.randomUUID();

        controller.changeStatus(conceptUuid, Map.of("status", "PUBLISHED"));

        verify(conceptAdminService).changePublishStatus(conceptUuid, ConceptPublishStatus.PUBLISHED);
    }

    @Test
    void content_put_passesAllFields() {
        UUID conceptUuid = UUID.randomUUID();

        controller.updateContent(conceptUuid, Map.of("title", "엔터티", "summary", "요약", "coreMd", "핵심", "detailMd", "## 왜 {#why}\n가"));

        verify(conceptAdminService).updateContent(conceptUuid, "엔터티", "요약", "핵심", "## 왜 {#why}\n가");
    }
}
