package com.passql.web.controller.admin;

import com.passql.question.dto.ExecuteResult;
import com.passql.question.service.AdminSandboxTestService;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

/**
 * 관리자 등록 폼의 [샌드박스 실행 테스트] 버튼용.
 */
@Slf4j
@RestController
@RequestMapping("/admin/sandbox")
@RequiredArgsConstructor
public class AdminSandboxController {

    private final AdminSandboxTestService adminSandboxTestService;

    @PostMapping("/execute")
    public ResponseEntity<ExecuteResult> execute(@RequestBody ExecuteRequest request) {
        return ResponseEntity.ok(adminSandboxTestService.executeSandboxTest(
                request.ddl(), request.sampleData(), request.sql()));
    }

    public record ExecuteRequest(String ddl, String sampleData, String sql) {}
}
