package com.passql.submission.dto.mockexam;

import com.passql.ai.dto.AiAnalysisAction;

import java.util.List;

/**
 * 결과 화면 "다음에 할 일" (서버 판정, #861 바로 풀기 버튼 재사용): 제목 한 줄, 이유 한 줄, 버튼 최대 2개
 */
public record MockExamNextStep(String headline, String message, List<AiAnalysisAction> actions) {
}
