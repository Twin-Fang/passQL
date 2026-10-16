package com.passql.web.controller.admin;

import com.passql.question.dto.ExportRequest;
import com.passql.question.dto.ImportRequest;
import com.passql.question.dto.ImportResult;
import com.passql.question.dto.ImportValidationResult;
import com.passql.question.dto.QuestionExportDto;
import com.passql.question.service.QuestionImportExportService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpHeaders;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.*;

import java.time.LocalDate;
import java.time.format.DateTimeFormatter;
import java.util.List;

/**
 * 관리자 문제 JSON 가져오기·내보내기: 필터·선택 내보내기(파일 다운로드), 가져오기 전 검증, 등록/업데이트
 */
@Controller
@RequestMapping("/admin/questions")
@RequiredArgsConstructor
public class AdminQuestionImportExportController {

    // 내보내기 파일명: passql-questions-{yyyy-MM-dd}.json
    private static final String EXPORT_FILE_NAME_PREFIX = "passql-questions-";
    private static final String EXPORT_FILE_EXTENSION = ".json";

    private final QuestionImportExportService importExportService;

    /**
     * 필터 조건 기반 전체 내보내기 (JSON 파일 다운로드).
     */
    @GetMapping("/export")
    @ResponseBody
    public ResponseEntity<List<QuestionExportDto>> exportByFilter(
            @RequestParam(required = false) String topic,
            @RequestParam(required = false) Integer difficulty,
            @RequestParam(required = false) String executionMode) {
        List<QuestionExportDto> data = importExportService.exportByFilter(topic, difficulty, executionMode);
        return toJsonFileDownload(data);
    }

    /**
     * 선택 UUID 기반 내보내기 (JSON 파일 다운로드).
     */
    @PostMapping("/export")
    @ResponseBody
    public ResponseEntity<List<QuestionExportDto>> exportByUuids(@RequestBody ExportRequest request) {
        List<QuestionExportDto> data = importExportService.exportByUuids(request.questionUuids());
        return toJsonFileDownload(data);
    }

    /**
     * 배치 Sandbox 검증 (가져오기 전 미리보기).
     */
    @PostMapping("/import/validate")
    @ResponseBody
    public ResponseEntity<ImportValidationResult> validateImport(@RequestBody List<QuestionExportDto> items) {
        ImportValidationResult result = importExportService.validateBatch(items);
        return ResponseEntity.ok(result);
    }

    /**
     * 검증 후 실제 등록/업데이트.
     */
    @PostMapping("/import")
    @ResponseBody
    public ResponseEntity<ImportResult> importBatch(@RequestBody ImportRequest request) {
        ImportResult result = importExportService.importBatch(request);
        return ResponseEntity.ok(result);
    }

    /** 내보내기 목록 > 오늘 날짜 파일명의 JSON 첨부 응답 */
    private ResponseEntity<List<QuestionExportDto>> toJsonFileDownload(List<QuestionExportDto> data) {
        String filename = EXPORT_FILE_NAME_PREFIX
                + LocalDate.now().format(DateTimeFormatter.ISO_LOCAL_DATE) + EXPORT_FILE_EXTENSION;
        return ResponseEntity.ok()
                .header(HttpHeaders.CONTENT_DISPOSITION, "attachment; filename=\"" + filename + "\"")
                .contentType(MediaType.APPLICATION_JSON)
                .body(data);
    }
}
