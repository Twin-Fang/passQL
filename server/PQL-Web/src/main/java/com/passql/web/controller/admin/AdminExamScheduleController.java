package com.passql.web.controller.admin;

import com.passql.meta.constant.CertType;
import com.passql.meta.dto.ExamScheduleBulkRequest;
import com.passql.meta.dto.ExamScheduleBulkResult;
import com.passql.meta.dto.ExamScheduleCreateRequest;
import com.passql.meta.dto.ExamScheduleResponse;
import com.passql.meta.dto.ExamScheduleUpdateRequest;
import com.passql.meta.service.ExamScheduleCoverageService;
import com.passql.meta.service.ExamScheduleService;
import com.passql.web.support.AdminMenu;
import com.passql.web.support.AdminPage;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.UUID;

@Controller
@RequestMapping("/admin/exam-schedules")
@RequiredArgsConstructor
public class AdminExamScheduleController {

    private final ExamScheduleService examScheduleService;
    private final ExamScheduleCoverageService coverageService;

    @GetMapping
    @AdminPage(menu = AdminMenu.EXAM_SCHEDULES)
    public String list(@RequestParam(value = "certType", required = false) String certType, Model model) {
        CertType type = (certType != null && !certType.isEmpty()) ? CertType.fromRequestValue(certType) : null;
        List<ExamScheduleResponse> schedules = examScheduleService.getAllSchedules(type);

        model.addAttribute("schedules", schedules);
        // 지난 일정 표시·정리 버튼 기준일 (KST)
        model.addAttribute("today", examScheduleService.getTodayInKorea());
        model.addAttribute("pastScheduleCount", examScheduleService.countPastSchedules());
        model.addAttribute("certTypes", CertType.values());
        model.addAttribute("selectedCertType", certType);
        // 공식 공고를 확인해야 하는지 알려 주는 상태 (#411)
        model.addAttribute("coverages", coverageService.getCoverages());
        model.addAttribute("officialUrl", ExamScheduleCoverageService.OFFICIAL_SCHEDULE_URL);
        model.addAttribute("checkedAt", coverageService.getCheckedAt().orElse(null));
        model.addAttribute("checkStale", coverageService.isCheckStale());
        model.addAttribute("staleDays", ExamScheduleCoverageService.STALE_CHECK_DAYS);
        return "admin/exam-schedules";
    }

    @PostMapping
    public String create(ExamScheduleCreateRequest request) {
        examScheduleService.createSchedule(request);
        return "redirect:/admin/exam-schedules";
    }

    /** 일괄 등록 (JSON body: { "text": "SQLD 63 2026-11-14\nSQLD 64 2027-02-27" }), 잘못된 줄이 있으면 400 */
    @PostMapping("/bulk")
    @ResponseBody
    public ResponseEntity<ExamScheduleBulkResult> importSchedules(@Valid @RequestBody ExamScheduleBulkRequest request) {
        return ResponseEntity.ok(examScheduleService.importSchedules(request.text()));
    }

    /** 지난 일정 정리: 시험일이 오늘보다 이전인 일정 전부 삭제 */
    @DeleteMapping("/past")
    @ResponseBody
    public ResponseEntity<ExamScheduleBulkResult> deletePastSchedules() {
        return ResponseEntity.ok(examScheduleService.deletePastSchedules());
    }

    /** 공식 공고를 확인했다고 오늘 날짜를 남긴다 */
    @PostMapping("/announcement-checked")
    public String markChecked() {
        coverageService.markChecked();
        return "redirect:/admin/exam-schedules";
    }

    /** 회차·시험일 수정 (#479) */
    @PutMapping("/{uuid}")
    @ResponseBody
    public ResponseEntity<Void> update(@PathVariable("uuid") UUID uuid,
                                       @Valid @RequestBody ExamScheduleUpdateRequest request) {
        examScheduleService.updateSchedule(uuid, request);
        return ResponseEntity.ok().build();
    }

    @PutMapping("/{uuid}/select")
    @ResponseBody
    public ResponseEntity<Void> select(@PathVariable("uuid") UUID uuid) {
        examScheduleService.selectSchedule(uuid);
        return ResponseEntity.ok().build();
    }

    @DeleteMapping("/{uuid}")
    @ResponseBody
    public ResponseEntity<Void> delete(@PathVariable("uuid") UUID uuid) {
        examScheduleService.deleteSchedule(uuid);
        return ResponseEntity.ok().build();
    }
}
