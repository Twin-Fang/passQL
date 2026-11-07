package com.passql.web.controller;

import com.passql.application.entitlement.ProFeature;
import com.passql.web.support.RequiresProFeature;
import com.passql.ai.dto.AiCommentResponse;
import com.passql.application.service.AiCommentService;
import com.passql.member.auth.presentation.annotation.AuthMember;
import com.passql.member.auth.presentation.security.LoginMember;
import com.passql.submission.dto.AccuracyDetailResponse;
import com.passql.submission.dto.HeatmapResponse;
import com.passql.submission.dto.ProgressResponse;
import com.passql.submission.dto.StudyPatternResponse;
import com.passql.submission.dto.TopicAnalysisResponse;
import com.passql.submission.dto.WrongQuestionsResponse;
import com.passql.submission.service.ProgressService;
import com.passql.submission.service.StudyStatsService;
import com.passql.submission.service.TopicAnalysisService;
import lombok.RequiredArgsConstructor;
import org.springframework.format.annotation.DateTimeFormat;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.time.LocalDate;
import java.util.UUID;

@RestController
@RequestMapping("/api/progress")
@RequiredArgsConstructor
public class ProgressController implements ProgressControllerDocs {

    private final ProgressService progressService;
    private final TopicAnalysisService topicAnalysisService;
    private final AiCommentService aiCommentService;
    private final StudyStatsService studyStatsService;

    @GetMapping
    public ResponseEntity<ProgressResponse> getProgress(
        @AuthMember LoginMember loginMember
    ) {
        return ResponseEntity.ok(progressService.getProgress(loginMember.memberUuid()));
    }

    @RequiresProFeature(ProFeature.TOPIC_ANALYSIS)
    @GetMapping("/topic-analysis")
    public ResponseEntity<TopicAnalysisResponse> getTopicAnalysis(
        @AuthMember LoginMember loginMember
    ) {
        return ResponseEntity.ok(topicAnalysisService.getTopicAnalysis(loginMember.memberUuid()));
    }

    @GetMapping("/heatmap")
    public ResponseEntity<HeatmapResponse> getHeatmap(
        @AuthMember LoginMember loginMember,
        @RequestParam(required = false) @DateTimeFormat(iso = DateTimeFormat.ISO.DATE) LocalDate from,
        @RequestParam(required = false) @DateTimeFormat(iso = DateTimeFormat.ISO.DATE) LocalDate to
    ) {
        return ResponseEntity.ok(progressService.getHeatmap(loginMember.memberUuid(), from, to));
    }

    // 통계·결과 화면 코멘트 모두 프로 전용 (#860)
    @RequiresProFeature(ProFeature.AI_COMMENT)
    @GetMapping("/ai-comment")
    public ResponseEntity<AiCommentResponse> getAiComment(
        @AuthMember LoginMember loginMember,
        @RequestParam(required = false) UUID sessionUuid
    ) {
        return ResponseEntity.ok(aiCommentService.getAiComment(loginMember.memberUuid(), sessionUuid));
    }

    @RequiresProFeature(ProFeature.TOPIC_ANALYSIS)
    @GetMapping("/wrong-questions")
    public ResponseEntity<WrongQuestionsResponse> getWrongQuestions(
        @AuthMember LoginMember loginMember,
        @RequestParam(defaultValue = ProgressService.DEFAULT_WRONG_QUESTION_COUNT) int size
    ) {
        return ResponseEntity.ok(progressService.getWrongQuestions(loginMember.memberUuid(), size));
    }

    // 활동 기록이라 히트맵처럼 무료 (#909)
    @GetMapping("/study-pattern")
    public ResponseEntity<StudyPatternResponse> getStudyPattern(
        @AuthMember LoginMember loginMember
    ) {
        return ResponseEntity.ok(studyStatsService.getStudyPattern(loginMember.memberUuid()));
    }

    // 약점 분석이라 토픽 분석과 같은 프로 기능 단위 (#909)
    @RequiresProFeature(ProFeature.TOPIC_ANALYSIS)
    @GetMapping("/accuracy-detail")
    public ResponseEntity<AccuracyDetailResponse> getAccuracyDetail(
        @AuthMember LoginMember loginMember
    ) {
        return ResponseEntity.ok(studyStatsService.getAccuracyDetail(loginMember.memberUuid()));
    }
}
