package com.passql.question.dto;

import com.passql.question.constant.ChoiceKind;
import com.passql.question.entity.QuestionChoiceSetItem;

/**
 * 형식 검사용 보기 1개 (#905): 키, SQL 보기 여부, 본문, 근거
 */
public record QuestionFormatChoice(String choiceKey, Boolean isSqlBody, String body, String rationale) {

    /** 가져오기·관리자 고정 보기 (kind 문자열 "SQL" 만 SQL 보기) */
    public static QuestionFormatChoice from(CuratedChoiceDto choice) {
        return new QuestionFormatChoice(choice.choiceKey(), "SQL".equalsIgnoreCase(choice.kind()),
                choice.body(), choice.rationale());
    }

    /** 저장된 세트 보기 */
    public static QuestionFormatChoice from(QuestionChoiceSetItem item) {
        return new QuestionFormatChoice(item.getChoiceKey(), item.getKind() == ChoiceKind.SQL,
                item.getBody(), item.getRationale());
    }
}
