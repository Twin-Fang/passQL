package com.passql.web.controller.admin;

import com.passql.application.questionformat.QuestionFormatAutoFixService;
import com.passql.application.questionformat.dto.QuestionFormatFixApplyRequest;
import com.passql.application.questionformat.dto.QuestionFormatFixApplyResult;
import com.passql.application.questionformat.dto.QuestionFormatFixPreview;
import com.passql.question.dto.AdminQuestionFormatCheckRequest;
import com.passql.question.dto.AdminQuestionFormatCheckResponse;
import com.passql.question.service.QuestionFormatCheckService;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import java.util.List;

/**
 * 관리자 문항 형식 API (#905): 저장 전 검사, 자동 정리 미리보기·적용
 */
@RestController
@RequestMapping("/admin/api/question-format")
@RequiredArgsConstructor
public class AdminQuestionFormatApiController implements AdminQuestionFormatApiControllerDocs {

    private final QuestionFormatCheckService questionFormatCheckService;
    private final QuestionFormatAutoFixService questionFormatAutoFixService;

    @PostMapping("/check")
    public ResponseEntity<AdminQuestionFormatCheckResponse> checkBeforeSave(@RequestBody AdminQuestionFormatCheckRequest request) {
        return ResponseEntity.ok(questionFormatCheckService.checkBeforeAdminSave(request));
    }

    @GetMapping("/auto-fix/preview")
    public ResponseEntity<List<QuestionFormatFixPreview>> previewAutoFix() {
        return ResponseEntity.ok(questionFormatAutoFixService.preview());
    }

    @PostMapping("/auto-fix/apply")
    public ResponseEntity<QuestionFormatFixApplyResult> applyAutoFix(@Valid @RequestBody QuestionFormatFixApplyRequest request) {
        return ResponseEntity.ok(questionFormatAutoFixService.apply(request));
    }
}
