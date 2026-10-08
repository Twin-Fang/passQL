package com.passql.web.controller.admin;

import com.passql.meta.constant.CertType;
import com.passql.meta.dto.ExamScheduleCreateRequest;
import com.passql.meta.dto.ExamScheduleResponse;
import com.passql.meta.service.ExamScheduleCoverageService;
import com.passql.meta.service.ExamScheduleService;
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
    public String list(@RequestParam(value = "certType", required = false) String certType, Model model) {
        CertType type = (certType != null && !certType.isEmpty()) ? CertType.valueOf(certType) : null;
        List<ExamScheduleResponse> schedules = examScheduleService.getAllSchedules(type);

        model.addAttribute("schedules", schedules);
        model.addAttribute("certTypes", CertType.values());
        model.addAttribute("selectedCertType", certType);
        // 공식 공고를 확인해야 하는지 알려 주는 상태 (#411)
        model.addAttribute("coverages", coverageService.getCoverages());
        model.addAttribute("officialUrl", ExamScheduleCoverageService.OFFICIAL_SCHEDULE_URL);
        model.addAttribute("checkedAt", coverageService.getCheckedAt().orElse(null));
        model.addAttribute("checkStale", coverageService.isCheckStale());
        model.addAttribute("staleDays", ExamScheduleCoverageService.STALE_CHECK_DAYS);
        model.addAttribute("pageTitle", "시험 일정 관리");
        model.addAttribute("currentMenu", "exam-schedules");
        return "admin/exam-schedules";
    }

    @PostMapping
    public String create(ExamScheduleCreateRequest request) {
        examScheduleService.createSchedule(request);
        return "redirect:/admin/exam-schedules";
    }

    /** 공식 공고를 확인했다고 오늘 날짜를 남긴다 */
    @PostMapping("/announcement-checked")
    public String markChecked() {
        coverageService.markChecked();
        return "redirect:/admin/exam-schedules";
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
