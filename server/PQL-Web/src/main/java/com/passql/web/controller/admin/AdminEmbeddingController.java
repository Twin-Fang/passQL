package com.passql.web.controller.admin;

import com.passql.ai.dto.IndexQuestionsBulkResult;
import com.passql.ai.dto.IndexStatusResult;
import com.passql.common.exception.CustomException;
import com.passql.common.exception.constant.ErrorCode;
import com.passql.question.dto.EmbeddingIndexProgress;
import com.passql.question.dto.IndexQuestionPreview;
import com.passql.question.service.EmbeddingIndexRunService;
import com.passql.question.service.QuestionVectorIndexService;
import com.passql.web.support.AdminMenu;
import com.passql.web.support.AdminPage;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.http.ResponseEntity;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.*;

import java.security.Principal;
import java.util.List;
import java.util.Map;

/**
 * 관리자 Qdrant 임베딩 인덱스 관리 화면 컨트롤러.
 * - GET  /admin/embeddings                : 색인 상태·실행 이력 대시보드
 * - POST /admin/embeddings/index-all      : 전체 재색인 비동기 시작 (JSON)
 * - GET  /admin/embeddings/progress       : 진행률 조회 (JSON, 화면이 주기적으로 호출)
 * - POST /admin/embeddings/retry-failed   : 직전 실행 실패 문제 재시도 (JSON)
 * - POST /admin/embeddings/index-selected : 선택 문제 재색인 (JSON)
 */
@Slf4j
@Controller
@RequestMapping("/admin/embeddings")
@RequiredArgsConstructor
public class AdminEmbeddingController {

    // 미색인 목록에 지문·토픽을 붙여 보여 줄 최대 건수 (나머지는 전체 색인으로 처리)
    private static final int MAX_UNINDEXED_PREVIEW_COUNT = 500;

    private final QuestionVectorIndexService questionVectorIndexService;
    private final EmbeddingIndexRunService embeddingIndexRunService;

    @GetMapping
    @AdminPage(menu = AdminMenu.EMBEDDINGS)
    public String index(Model model) {
        log.info("[admin-embeddings] 색인 상태 페이지 요청");

        // AI 서버 장애면 null — 화면에 에러 배너 표시, 페이지는 정상 렌더링
        IndexStatusResult status = questionVectorIndexService.findIndexStatusOfActiveQuestions();
        model.addAttribute("status", status);
        List<IndexQuestionPreview> unindexedPreviews = status == null ? List.of()
                : questionVectorIndexService.describeQuestions(
                        status.unindexedUuids().stream().limit(MAX_UNINDEXED_PREVIEW_COUNT).toList());
        model.addAttribute("unindexedPreviews", unindexedPreviews);
        model.addAttribute("failedQuestions", embeddingIndexRunService.listLatestFailedQuestions());
        model.addAttribute("recentRuns", embeddingIndexRunService.listRecentRuns());
        model.addAttribute("lastRun", embeddingIndexRunService.findLastFinishedRun().orElse(null));
        return "admin/embeddings";
    }

    /**
     * 전체 활성 문제 재색인을 백그라운드로 시작한다 (이미 진행 중이면 409).
     * 진행률은 GET /progress, 결과는 실행 이력에서 확인한다.
     */
    @PostMapping("/index-all")
    @ResponseBody
    public ResponseEntity<Void> indexAll(Principal adminPrincipal) {
        log.info("[admin-embeddings] 전체 재색인 시작 요청");
        embeddingIndexRunService.startReindexAll(adminPrincipal.getName());
        return ResponseEntity.accepted().build();
    }

    /** 진행률 (진행 중이 아니면 isRunning=false). */
    @GetMapping("/progress")
    @ResponseBody
    public ResponseEntity<EmbeddingIndexProgress> progress() {
        return ResponseEntity.ok(embeddingIndexRunService.getCurrentProgress());
    }

    /** 직전 실행에서 실패한 문제만 백그라운드로 재시도한다 (실패 목록 없으면 400, 진행 중이면 409). */
    @PostMapping("/retry-failed")
    @ResponseBody
    public ResponseEntity<Void> retryFailed(Principal adminPrincipal) {
        log.info("[admin-embeddings] 실패 문제 재시도 요청");
        embeddingIndexRunService.startRetryFailed(adminPrincipal.getName());
        return ResponseEntity.accepted().build();
    }

    /**
     * 선택한 문제 UUID 목록을 Qdrant에 재색인한다.
     * questions.html의 체크박스 선택 후 "선택 색인" 버튼과 임베딩 관리 화면의 미색인 선택 색인에서 호출된다.
     * JSON API — 응답은 { succeeded, failed } 형태로 반환한다.
     * 실패 응답: 표준 {errorCode, message} (GlobalExceptionHandler)
     */
    @PostMapping("/index-selected")
    @ResponseBody
    public ResponseEntity<Map<String, Object>> indexSelected(
            @RequestBody Map<String, List<String>> body, Principal adminPrincipal) {
        List<String> uuids = body.get("uuids");
        if (uuids == null || uuids.isEmpty()) {
            throw new CustomException(ErrorCode.EMBEDDING_INDEX_TARGET_EMPTY);
        }

        log.info("[admin-embeddings] 선택 재색인 시작: count={}", uuids.size());
        IndexQuestionsBulkResult result = embeddingIndexRunService.runSelectedSynchronously(uuids, adminPrincipal.getName());
        log.info("[admin-embeddings] 선택 재색인 완료: succeeded={}, failed={}",
                result.succeeded(), result.failed());
        return ResponseEntity.ok(Map.of(
                "succeeded", result.succeeded(),
                "failed", result.failed(),
                "failedUuids", result.failedUuids()
        ));
    }
}
