package com.passql.web.controller.admin;

import com.passql.meta.service.MetaService;
import com.passql.question.dto.AdminDailyChallengeItem;
import com.passql.question.dto.AdminQuestionListItem;
import com.passql.question.dto.AdminQuestionSearchCondition;
import com.passql.question.dto.DailyChallengeAssignRequest;
import com.passql.question.dto.DailyChallengeCandidatePage;
import com.passql.question.dto.DailyChallengeCopyRequest;
import com.passql.question.dto.DailyChallengeRangeRequest;
import com.passql.question.dto.DailyChallengeRangeResult;
import com.passql.question.service.AdminDailyChallengeService;
import com.passql.question.service.QuestionService;
import com.passql.web.support.AdminMenu;
import com.passql.web.support.AdminPage;
import com.passql.web.support.AdminPageRequest;
import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.Page;
import org.springframework.format.annotation.DateTimeFormat;
import org.springframework.http.ResponseEntity;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.*;

import java.time.LocalDate;
import java.util.List;

@Controller
@RequestMapping("/admin/daily-challenges")
@RequiredArgsConstructor
public class AdminDailyChallengeController {

    // 배정 후보 목록 한 페이지 크기 (건)
    private static final int CANDIDATE_PAGE_SIZE = 20;

    private final AdminDailyChallengeService adminDailyChallengeService;
    private final QuestionService questionService;
    private final MetaService metaService;

    /** 어드민 화면 (토픽 필터 목록 포함) */
    @GetMapping
    @AdminPage(menu = AdminMenu.DAILY_CHALLENGES)
    public String page(Model model) {
        model.addAttribute("topics", metaService.getTopicTree());
        return "admin/daily-challenges";
    }

    /** 캘린더 데이터 조회 */
    @GetMapping("/api")
    @ResponseBody
    public ResponseEntity<List<AdminDailyChallengeItem>> getChallenges(
            @RequestParam @DateTimeFormat(iso = DateTimeFormat.ISO.DATE) LocalDate from,
            @RequestParam @DateTimeFormat(iso = DateTimeFormat.ISO.DATE) LocalDate to) {
        return ResponseEntity.ok(adminDailyChallengeService.getChallenges(from, to));
    }

    /** 배정 후보 검색: 지문 검색어·토픽 코드·난이도 필터, 활성 문제만 최신순 */
    @GetMapping("/api/candidates")
    @ResponseBody
    public ResponseEntity<DailyChallengeCandidatePage> searchCandidates(
            @RequestParam(required = false) String keyword,
            @RequestParam(required = false) String topic,
            @RequestParam(required = false) Integer difficulty,
            @RequestParam(defaultValue = "0") int page) {
        AdminQuestionSearchCondition condition = new AdminQuestionSearchCondition();
        condition.setKeyword(keyword);
        condition.setTopic(topic);
        condition.setDifficulty(difficulty);
        Page<AdminQuestionListItem> candidatePage = questionService.searchQuestionsForAdmin(
                condition, AdminPageRequest.newestFirst(page, CANDIDATE_PAGE_SIZE));
        return ResponseEntity.ok(new DailyChallengeCandidatePage(candidatePage.getContent(),
                candidatePage.getNumber(), candidatePage.getTotalPages(), candidatePage.getTotalElements()));
    }

    /** 날짜에 최대 10문제 배정 (questionUuids 없으면 폴백 로직으로 자동 선정) */
    @PutMapping("/{date}")
    @ResponseBody
    public ResponseEntity<List<AdminDailyChallengeItem>> assign(
            @PathVariable @DateTimeFormat(iso = DateTimeFormat.ISO.DATE) LocalDate date,
            @RequestBody DailyChallengeAssignRequest request) {
        if (request.questionUuids() == null || request.questionUuids().isEmpty()) {
            adminDailyChallengeService.confirmFallback(date);
            return ResponseEntity.ok(adminDailyChallengeService.getChallenges(date, date));
        }
        return ResponseEntity.ok(adminDailyChallengeService.assign(date, request.questionUuids()));
    }

    /** 기간 일괄 자동 배정 (이미 배정된 날짜는 건너뜀) */
    @PostMapping("/api/auto-assign-range")
    @ResponseBody
    public ResponseEntity<DailyChallengeRangeResult> autoAssignRange(@RequestBody DailyChallengeRangeRequest request) {
        return ResponseEntity.ok(adminDailyChallengeService.autoAssignRange(request.fromDate(), request.toDate()));
    }

    /** 원본 날짜의 배정을 대상 기간에 복사 */
    @PostMapping("/api/copy")
    @ResponseBody
    public ResponseEntity<DailyChallengeRangeResult> copyAssignment(@RequestBody DailyChallengeCopyRequest request) {
        return ResponseEntity.ok(adminDailyChallengeService.copyAssignment(request.sourceDate(),
                request.targetFromDate(), request.targetToDate(), Boolean.TRUE.equals(request.isOverwriteExisting())));
    }

    /** 배정 해제 */
    @DeleteMapping("/{date}")
    @ResponseBody
    public ResponseEntity<Void> unassign(
            @PathVariable @DateTimeFormat(iso = DateTimeFormat.ISO.DATE) LocalDate date) {
        adminDailyChallengeService.unassign(date);
        return ResponseEntity.ok().build();
    }
}
