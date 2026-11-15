package com.passql.web.controller.admin;

import com.passql.common.util.UuidUtils;
import com.passql.meta.constant.CertType;
import com.passql.submission.constant.ExamAnswerItemStatus;
import com.passql.submission.constant.ExamAnswerRoundStatus;
import com.passql.submission.dto.examanswer.AdminExamAnswerItemRow;
import com.passql.submission.dto.examanswer.AdminExamAnswerItemUpdateRequest;
import com.passql.submission.dto.examanswer.AdminExamAnswerItemsUpdateResult;
import com.passql.submission.dto.examanswer.AdminExamAnswerOfficialRequest;
import com.passql.submission.dto.examanswer.AdminExamAnswerRoundCreateRequest;
import com.passql.submission.dto.examanswer.AdminExamAnswerRoundRow;
import com.passql.submission.dto.examanswer.AdminExamAnswerRoundUpdateRequest;
import com.passql.submission.service.ExamAnswerAdminService;
import com.passql.web.support.AdminMenu;
import com.passql.web.support.AdminPage;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.Map;
import java.util.UUID;

/**
 * 관리자 회차별 가답안 (#1075): 회차 목록·생성·수정, 50문항 편집, 공식 정답 일괄 반영, 득표 현황
 * JSON API 는 스크립트 운영 반영에도 사용 (세션 + CSRF)
 */
@Controller
@RequestMapping("/admin/exam-answers")
@RequiredArgsConstructor
public class AdminExamAnswerController {

    private final ExamAnswerAdminService examAnswerAdminService;

    /** 화면: 회차 목록 + 선택 회차(없으면 최신) 문항 편집 */
    @GetMapping
    @AdminPage(menu = AdminMenu.EXAM_ANSWERS)
    public String page(@RequestParam(value = "roundUuid", required = false) String roundUuid, Model model) {
        List<AdminExamAnswerRoundRow> rounds = examAnswerAdminService.getRounds();
        AdminExamAnswerRoundRow selectedRound = UuidUtils.parseOrEmpty(roundUuid)
                .map(examAnswerAdminService::getRound)
                .orElse(rounds.isEmpty() ? null : rounds.get(0));

        model.addAttribute("rounds", rounds);
        model.addAttribute("selectedRound", selectedRound);
        model.addAttribute("itemRows", selectedRound == null ? List.of()
                : examAnswerAdminService.getItemRows(selectedRound.roundUuid()));
        model.addAttribute("certTypes", CertType.values());
        model.addAttribute("roundStatuses", ExamAnswerRoundStatus.values());
        model.addAttribute("itemStatuses", ExamAnswerItemStatus.values());
        return "admin/exam-answers";
    }

    /** 회차 생성 (문항 50행 자동) > 새 회차 UUID */
    @PostMapping
    @ResponseBody
    public ResponseEntity<Map<String, UUID>> createRound(@Valid @RequestBody AdminExamAnswerRoundCreateRequest request) {
        return ResponseEntity.ok(Map.of("roundUuid", examAnswerAdminService.createRound(request)));
    }

    /** 회차 정보 수정 (제목·시험일·상태·안내) */
    @PutMapping("/{roundUuid}")
    @ResponseBody
    public ResponseEntity<Void> updateRound(@PathVariable("roundUuid") UUID roundUuid,
                                            @Valid @RequestBody AdminExamAnswerRoundUpdateRequest request) {
        examAnswerAdminService.updateRound(roundUuid, request);
        return ResponseEntity.ok().build();
    }

    /** 문항 편집 행 50개 (JSON, 스크립트 확인용) */
    @GetMapping("/{roundUuid}/items")
    @ResponseBody
    public ResponseEntity<List<AdminExamAnswerItemRow>> getItems(@PathVariable("roundUuid") UUID roundUuid) {
        return ResponseEntity.ok(examAnswerAdminService.getItemRows(roundUuid));
    }

    /** 문항 일괄 수정 (JSON 배열, null 필드 유지) */
    @PutMapping("/{roundUuid}/items")
    @ResponseBody
    public ResponseEntity<AdminExamAnswerItemsUpdateResult> updateItems(@PathVariable("roundUuid") UUID roundUuid,
                                                                        @RequestBody List<AdminExamAnswerItemUpdateRequest> requests) {
        return ResponseEntity.ok(examAnswerAdminService.updateItems(roundUuid, requests));
    }

    /** 공식 정답 50자 반영 > 문항 OFFICIAL, 회차 OFFICIAL */
    @PutMapping("/{roundUuid}/official-answers")
    @ResponseBody
    public ResponseEntity<AdminExamAnswerItemsUpdateResult> applyOfficialAnswers(@PathVariable("roundUuid") UUID roundUuid,
                                                                                 @Valid @RequestBody AdminExamAnswerOfficialRequest request) {
        return ResponseEntity.ok(examAnswerAdminService.applyOfficialAnswers(roundUuid, request.answers()));
    }
}
