package com.passql.web.controller.admin;

import com.passql.ai.dto.IndexQuestionsBulkResult;
import com.passql.ai.dto.PruneIndexResult;
import com.passql.common.exception.CustomException;
import com.passql.common.exception.constant.ErrorCode;
import com.passql.question.service.QuestionVectorIndexService;
import com.passql.web.support.AdminMenu;
import com.passql.web.support.AdminPage;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.http.ResponseEntity;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.servlet.mvc.support.RedirectAttributes;

import java.util.List;
import java.util.Map;

/**
 * 관리자 Qdrant 임베딩 인덱스 관리 화면 컨트롤러.
 * - GET  /admin/embeddings         : 색인 상태 대시보드
 * - POST /admin/embeddings/index-all      : 전체 재색인
 * - POST /admin/embeddings/index-selected : 선택 문제 재색인 (JSON API)
 */
@Slf4j
@Controller
@RequestMapping("/admin/embeddings")
@RequiredArgsConstructor
public class AdminEmbeddingController {

    // 전체 재색인 실패 시 화면 문구 (원인은 서버 로그)
    private static final String INDEX_ALL_FAILED_MESSAGE = "전체 색인 중 오류가 발생했습니다. 서버 로그를 확인하세요.";

    private final QuestionVectorIndexService questionVectorIndexService;

    @GetMapping
    @AdminPage(menu = AdminMenu.EMBEDDINGS)
    public String index(Model model) {
        log.info("[admin-embeddings] 색인 상태 페이지 요청");

        // AI 서버 장애면 null — 화면에 에러 배너 표시, 페이지는 정상 렌더링
        model.addAttribute("status", questionVectorIndexService.findIndexStatusOfActiveQuestions());
        return "admin/embeddings";
    }

    /**
     * 전체 활성 문제를 Qdrant에 재색인한다.
     * 완료 후 임베딩 관리 페이지로 리다이렉트한다.
     */
    @PostMapping("/index-all")
    public String indexAll(RedirectAttributes redirectAttrs) {
        log.info("[admin-embeddings] 전체 재색인 시작");
        try {
            IndexQuestionsBulkResult result = questionVectorIndexService.reindexAll();
            // 재색인은 추가만 하므로 삭제·비활성 문제의 벡터는 따로 정리한다 (#412)
            PruneIndexResult pruned = questionVectorIndexService.pruneIndex();
            redirectAttrs.addFlashAttribute("successMessage",
                    String.format("전체 색인 완료: %d개 성공, %d개 실패, 남은 벡터 %s",
                            result.succeeded(), result.failed(),
                            pruned != null ? pruned.deletedCount() + "개 정리" : "정리 실패"));
            log.info("[admin-embeddings] 전체 재색인 완료: succeeded={}, failed={}",
                    result.succeeded(), result.failed());
        } catch (Exception e) {
            log.error("[admin-embeddings] 전체 재색인 오류: {}", e.getMessage(), e);
            redirectAttrs.addFlashAttribute("errorMessage", INDEX_ALL_FAILED_MESSAGE);
        }
        return "redirect:/admin/embeddings";
    }

    /**
     * 선택한 문제 UUID 목록을 Qdrant에 재색인한다.
     * questions.html의 체크박스 선택 후 "선택 색인" 버튼에서 호출된다.
     * JSON API — 응답은 { succeeded, failed } 형태로 반환한다.
     * 실패 응답: 표준 {errorCode, message} (GlobalExceptionHandler)
     */
    @PostMapping("/index-selected")
    @ResponseBody
    public ResponseEntity<Map<String, Object>> indexSelected(
            @RequestBody Map<String, List<String>> body) {
        List<String> uuids = body.get("uuids");
        if (uuids == null || uuids.isEmpty()) {
            throw new CustomException(ErrorCode.EMBEDDING_INDEX_TARGET_EMPTY);
        }

        log.info("[admin-embeddings] 선택 재색인 시작: count={}", uuids.size());
        IndexQuestionsBulkResult result = questionVectorIndexService.reindexSelected(uuids);
        log.info("[admin-embeddings] 선택 재색인 완료: succeeded={}, failed={}",
                result.succeeded(), result.failed());
        return ResponseEntity.ok(Map.of(
                "succeeded", result.succeeded(),
                "failed", result.failed(),
                "failedUuids", result.failedUuids()
        ));
    }
}
