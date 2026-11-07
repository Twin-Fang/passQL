package com.passql.question.service;

import com.passql.common.exception.CustomException;
import com.passql.common.exception.constant.ErrorCode;
import com.passql.question.constant.ExecutionMode;
import com.passql.question.dto.AdminQuestionFormatCheckRequest;
import com.passql.question.dto.AdminQuestionFormatCheckResponse;
import com.passql.question.dto.QuestionFormatCheckResult;
import com.passql.question.dto.QuestionFormatChoice;
import com.passql.question.dto.QuestionFormatInput;
import com.passql.question.dto.QuestionFormatViolation;
import com.passql.question.entity.Question;
import com.passql.question.repository.QuestionRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;

/**
 * 관리자 저장 전 형식 검사 (#905): 등록·편집·AI 생성 검수 화면이 저장 버튼 전에 부름 (저장 관문 QuestionFormatGate 와 같은 판정)
 */
@Service
@RequiredArgsConstructor
@Transactional(readOnly = true)
public class QuestionFormatCheckService {

    private final QuestionRepository questionRepository;

    /** 새 문항 > 위반 전부 막음, 편집 > 저장본에 없던 사유만 막고 나머지는 경고 */
    public AdminQuestionFormatCheckResponse checkBeforeAdminSave(AdminQuestionFormatCheckRequest request) {
        List<QuestionFormatChoice> choices = request.choices() == null ? List.of()
                : request.choices().stream().map(QuestionFormatChoice::from).toList();
        QuestionFormatInput editedInput = new QuestionFormatInput(request.stem(), request.hint(), request.schemaDdl(),
                request.schemaSampleData(), ExecutionMode.EXECUTABLE.name().equalsIgnoreCase(request.executionMode()), choices);
        QuestionFormatCheckResult editedResult = QuestionFormatRule.check(editedInput);
        if (request.questionUuid() == null) {
            return new AdminQuestionFormatCheckResponse(editedResult.isPassed(), editedResult.violations(), List.of());
        }

        Question savedQuestion = questionRepository.findById(request.questionUuid())
                .orElseThrow(() -> new CustomException(ErrorCode.QUESTION_NOT_FOUND));
        QuestionFormatInput savedInput = QuestionFormatInput.withoutChoices(savedQuestion.getStem(), savedQuestion.getHint(),
                savedQuestion.getSchemaDdl(), savedQuestion.getSchemaSampleData(), savedQuestion.getExecutionMode());
        List<QuestionFormatViolation> blockingViolations = QuestionFormatGate.findNewReasonViolations(savedInput, editedInput)
                .violations();
        List<QuestionFormatViolation> existingViolations = editedResult.violations().stream()
                .filter(violation -> !blockingViolations.contains(violation))
                .toList();
        return new AdminQuestionFormatCheckResponse(blockingViolations.isEmpty(), blockingViolations, existingViolations);
    }
}
