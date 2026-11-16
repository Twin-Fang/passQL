package com.passql.question.service;

import com.passql.common.exception.CustomException;
import com.passql.common.exception.constant.ErrorCode;
import com.passql.question.entity.Question;
import com.passql.question.repository.QuestionRepository;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.UUID;

/**
 * 문제 그림 저장 (#1132): 검사(QuestionFigureSvgRule) > 저장, 빈 값이면 그림 지움
 */
@Slf4j
@Service
@RequiredArgsConstructor
public class QuestionFigureService {

    private final QuestionRepository questionRepository;

    @Transactional
    public void updateFigure(UUID questionUuid, String figureSvgOrNull) {
        String rejectReason = QuestionFigureSvgRule.findRejectReason(figureSvgOrNull);
        if (rejectReason != null) {
            log.info("[question figure] rejected 400 : question={}, reason={}", questionUuid, rejectReason);
            throw new CustomException(ErrorCode.INVALID_INPUT_VALUE, rejectReason);
        }
        Question question = questionRepository.findById(questionUuid)
            .orElseThrow(() -> new CustomException(ErrorCode.QUESTION_NOT_FOUND));
        boolean hasFigure = figureSvgOrNull != null && !figureSvgOrNull.isBlank();
        question.setFigureSvg(hasFigure ? figureSvgOrNull.trim() : null);
        log.info("[question figure] updated : question={}, hasFigure={}", questionUuid, hasFigure);
    }
}
