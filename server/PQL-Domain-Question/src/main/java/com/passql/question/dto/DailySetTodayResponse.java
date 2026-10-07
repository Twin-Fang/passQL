package com.passql.question.dto;

import java.util.List;

public record DailySetTodayResponse(
    List<QuestionSummary> questions,
    Boolean alreadyCompleted,
    Integer correctCount,
    // 이미 완료한 세트를 다시 열 때 문제별 정답 여부(questions 순서와 같음). 미완료면 null (#372)
    List<Boolean> results
) {}
