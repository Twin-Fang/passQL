package com.passql.question.dto;

import com.passql.question.constant.ExecutionMode;
import com.passql.question.entity.Question;
import com.passql.question.entity.QuestionChoiceSetItem;

import java.util.List;

/**
 * 형식 검사 입력 문항 1개 (#905): 지문·힌트·스키마(DDL·샘플)·실행형 여부·보기
 * 실행형 여부: 지문 표를 스키마로 옮기는 자동 정리 판단용 (실행형은 샘플이 채점에 쓰여 자동 변환 안 함)
 */
public record QuestionFormatInput(
        String stem,
        String hint,
        String schemaDdl,
        String schemaSampleData,
        Boolean isExecutable,
        List<QuestionFormatChoice> choices
) {

    /** 가져오기 JSON 항목 (실행 모드 문자열이 EXECUTABLE 일 때만 실행형) */
    public static QuestionFormatInput from(QuestionExportDto item) {
        List<QuestionFormatChoice> choices = item.choices() == null ? List.of()
                : item.choices().stream().map(QuestionFormatChoice::from).toList();
        return new QuestionFormatInput(item.stem(), item.hint(), item.schemaDdl(), item.schemaSampleData(),
                ExecutionMode.EXECUTABLE.name().equalsIgnoreCase(item.executionMode()), choices);
    }

    /** 저장된 문제 + 세트 보기 (보기 없으면 빈 목록) */
    public static QuestionFormatInput from(Question question, List<QuestionChoiceSetItem> choiceItems) {
        List<QuestionFormatChoice> choices = choiceItems.stream().map(QuestionFormatChoice::from).toList();
        return new QuestionFormatInput(question.getStem(), question.getHint(), question.getSchemaDdl(),
                question.getSchemaSampleData(), question.getExecutionMode() == ExecutionMode.EXECUTABLE, choices);
    }

    /** 보기 없는 문제 필드만 (관리자 직접 등록·편집) */
    public static QuestionFormatInput withoutChoices(String stem, String hint, String schemaDdl,
                                                     String schemaSampleData, ExecutionMode executionMode) {
        return new QuestionFormatInput(stem, hint, schemaDdl, schemaSampleData,
                executionMode == ExecutionMode.EXECUTABLE, List.of());
    }
}
