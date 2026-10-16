package com.passql.question.service;

import com.passql.common.util.RequestEnumParser;
import com.passql.meta.repository.TopicRepository;
import com.passql.question.constant.ExecutionMode;
import com.passql.question.dto.ExecuteResult;
import com.passql.question.dto.ImportItemResult;
import com.passql.question.dto.QuestionExportDto;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Component;

/**
 * 가져오기 항목 1건 검증: 필수 필드·토픽·실행 모드 확인, Oracle 문법 치환·감지, 정답 SQL 샌드박스 실행
 * 결과 상태 3개: OK(실행 성공), SKIP(개념 문제·Oracle 전용 문법), FAIL(사유 기록)
 */
@Component
@RequiredArgsConstructor
public class QuestionImportItemValidator {

    private final TopicRepository topicRepository;
    private final SandboxPool sandboxPool;
    private final SandboxExecutor sandboxExecutor;
    private final OracleSqlCompatibilityConverter oracleSqlCompatibilityConverter;

    /** 가져오기 항목 1건 검증: 필수 필드 > 토픽 > 실행 모드 > Oracle 문법 > 샌드박스 실행 */
    public ImportItemResult validate(int index, QuestionExportDto item, String stemPreview, String importAction) {
        // 필수 필드 검증
        if (item.topicCode() == null || item.topicCode().isBlank()
                || item.difficulty() == null
                || item.executionMode() == null || item.executionMode().isBlank()
                || item.stem() == null || item.stem().isBlank()) {
            return new ImportItemResult(index, stemPreview, item.topicCode(), item.difficulty(),
                    item.executionMode(), "FAIL", null, null,
                    "필수 필드 누락 (topicCode, difficulty, executionMode, stem)", importAction);
        }

        // topicCode 유효성
        if (topicRepository.findByCode(item.topicCode()).isEmpty()) {
            return new ImportItemResult(index, stemPreview, item.topicCode(), item.difficulty(),
                    item.executionMode(), "FAIL", null, null,
                    "존재하지 않는 토픽: " + item.topicCode(), importAction);
        }

        // executionMode 유효성
        ExecutionMode mode = RequestEnumParser.parseOrNull(ExecutionMode.class, item.executionMode());
        if (mode == null) {
            return new ImportItemResult(index, stemPreview, item.topicCode(), item.difficulty(),
                    item.executionMode(), "FAIL", null, null,
                    "유효하지 않은 실행 모드: " + item.executionMode(), importAction);
        }

        // CONCEPT_ONLY → Sandbox 스킵
        if (mode == ExecutionMode.CONCEPT_ONLY) {
            return new ImportItemResult(index, stemPreview, item.topicCode(), item.difficulty(),
                    item.executionMode(), "SKIP", null, null, null, importAction);
        }

        // 1단계: 1:1 치환 가능한 Oracle 문법을 PostgreSQL 호환으로 변환 (NVL→COALESCE, SYSDATE→NOW())
        String translatedDdl       = oracleSqlCompatibilityConverter.translateOracleToPostgres(item.schemaDdl());
        String translatedSample    = oracleSqlCompatibilityConverter.translateOracleToPostgres(item.schemaSampleData());
        String translatedAnswerSql = oracleSqlCompatibilityConverter.translateOracleToPostgres(item.answerSql());

        // 2단계: 치환 후에도 남은 Oracle 전용 문법 감지 → CONCEPT_ONLY 자동 전환
        // (CONNECT BY, ROWNUM, NVL2, DECODE 등 단순 치환 불가 문법)
        String oracleKeyword = oracleSqlCompatibilityConverter.detectOracleOnlySyntax(translatedAnswerSql, translatedDdl, translatedSample, item.stem());
        if (oracleKeyword != null) {
            return new ImportItemResult(index, stemPreview, item.topicCode(), item.difficulty(),
                    "CONCEPT_ONLY", "SKIP", null, null,
                    "[Oracle 전용 문법 감지 → CONCEPT_ONLY 자동 전환] 키워드: " + oracleKeyword, importAction);
        }

        // EXECUTABLE 추가 필수 필드
        if (translatedDdl == null || translatedDdl.isBlank()
                || translatedAnswerSql == null || translatedAnswerSql.isBlank()) {
            return new ImportItemResult(index, stemPreview, item.topicCode(), item.difficulty(),
                    item.executionMode(), "FAIL", null, null,
                    "EXECUTABLE 문제: schemaDdl, answerSql 필수", importAction);
        }

        // Sandbox 실행 테스트 (치환된 SQL로 실행)
        return executeSandboxTest(index, item, stemPreview, importAction,
                translatedDdl, translatedSample, translatedAnswerSql);
    }

    private ImportItemResult executeSandboxTest(int index, QuestionExportDto item, String stemPreview,
                                                String importAction,
                                                String schemaDdl, String schemaSampleData, String answerSql) {
        String dbName = null;
        try {
            dbName = sandboxPool.acquire();
            String setupSql = schemaDdl;
            if (schemaSampleData != null && !schemaSampleData.isBlank()) {
                setupSql = setupSql + ";\n" + schemaSampleData;
            }
            sandboxExecutor.applyDdl(dbName, setupSql);
            ExecuteResult execResult = sandboxExecutor.execute(dbName, answerSql);

            if ("OK".equals(execResult.status())) {
                return new ImportItemResult(index, stemPreview, item.topicCode(), item.difficulty(),
                        item.executionMode(), "OK", execResult.rowCount(), execResult.elapsedMs(),
                        null, importAction);
            } else {
                return new ImportItemResult(index, stemPreview, item.topicCode(), item.difficulty(),
                        item.executionMode(), "FAIL", null, execResult.elapsedMs(),
                        execResult.errorMessage(), importAction);
            }
        } catch (Exception e) {
            return new ImportItemResult(index, stemPreview, item.topicCode(), item.difficulty(),
                    item.executionMode(), "FAIL", null, null,
                    "Sandbox 오류: " + e.getMessage(), importAction);
        } finally {
            if (dbName != null) {
                sandboxPool.release(dbName);
            }
        }
    }
}
