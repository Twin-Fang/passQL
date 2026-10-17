package com.passql.question.service;

import com.passql.common.exception.CustomException;
import com.passql.common.exception.constant.ErrorCode;
import com.passql.question.dto.ExecuteResult;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;

import java.util.List;

/**
 * 관리자 등록 폼 [샌드박스 실행 테스트]: 임시 샌드박스에 DDL + 샘플 적용 > SQL 1회 실행
 * DDL 적용 실패는 ERROR 결과로 돌려 관리자 화면에 원인 문장 표시 (/admin 세션 인증 경로 전용)
 */
@Slf4j
@Service
@RequiredArgsConstructor
public class AdminSandboxTestService {

    private final SandboxExecutor sandboxExecutor;

    /** DDL + 샘플 + 실행 SQL > 실행 결과 (준비 실패 시 status ERROR) */
    public ExecuteResult executeSandboxTest(String schemaDdl, String schemaSampleData, String sql) {
        try {
            return sandboxExecutor.runInTemporarySandbox(schemaDdl, schemaSampleData,
                    dbName -> sandboxExecutor.execute(dbName, sql));
        } catch (CustomException e) {
            if (e.getErrorCode() != ErrorCode.SANDBOX_SETUP_FAILED) {
                throw e;
            }
            log.warn("[admin sandbox test] setup failed : {}", e.getMessage());
            return new ExecuteResult("ERROR", List.of(), List.of(), 0, 0L,
                    ErrorCode.SANDBOX_SETUP_FAILED.name(), SandboxExecutor.toAdminFailureReason(e));
        }
    }
}
