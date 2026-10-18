package com.passql.web.controller;

import com.passql.question.dto.ExamTrendReportResponse;
import com.passql.question.dto.LatestTrendTopicCount;
import com.passql.question.service.ExamTrendService;
import com.passql.question.service.QuestionLatestTrendService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import java.util.List;

/**
 * 출제 경향: 경향 화면 내용, 토픽별 최신 경향 문제 수 (#523)
 */
@RestController
@RequestMapping("/api/exam-trends")
@RequiredArgsConstructor
public class ExamTrendController implements ExamTrendControllerDocs {

    private final ExamTrendService examTrendService;
    private final QuestionLatestTrendService questionLatestTrendService;

    @GetMapping("/latest")
    public ResponseEntity<ExamTrendReportResponse> getLatestReport() {
        return ResponseEntity.ok(examTrendService.getLatestReport());
    }

    @GetMapping("/latest/topics")
    public ResponseEntity<List<LatestTrendTopicCount>> getLatestTrendTopics() {
        return ResponseEntity.ok(questionLatestTrendService.getLatestTrendTopicCounts());
    }
}
