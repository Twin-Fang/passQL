package com.passql.application.service;

import com.passql.ai.dto.AiResult;
import com.passql.ai.entity.AiErrorExplanation;
import com.passql.ai.repository.AiErrorExplanationRepository;
import com.passql.common.exception.CustomException;
import com.passql.common.exception.constant.ErrorCode;
import com.passql.question.entity.Question;
import com.passql.question.repository.QuestionRepository;
import com.passql.submission.entity.Submission;
import com.passql.submission.repository.SubmissionRepository;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.dao.DataIntegrityViolationException;
import org.springframework.stereotype.Service;

import java.nio.charset.StandardCharsets;
import java.security.MessageDigest;
import java.security.NoSuchAlgorithmException;
import java.time.LocalDateTime;
import java.util.HexFormat;
import java.util.Optional;
import java.util.UUID;
import java.util.regex.Pattern;

/**
 * 문제 풀이 AI 해설 진입점: 오답 해설, SQL 오류 해설 (DB 영구 저장, #496)
 * - diffExplain: 회원이 마지막으로 푼 세트의 선택지 해설 (미리 생성본 우선)
 * - explainError: (문제, 정규화 SQL, 오류) 단위 해설 재사용, 없으면 생성·저장
 * Gemini 호출은 트랜잭션 밖에서 한다(DB 커넥션을 오래 잡지 않게).
 */
@Slf4j
@Service
@RequiredArgsConstructor
public class AiExplainService {

    // 오류 해설 입력 상한 (토큰 비용 남용 방지)
    private static final int MAX_SQL_LENGTH = 4000;
    private static final int MAX_ERROR_MESSAGE_LENGTH = 1000;
    // SQL 정규화: 연속 공백 > 한 칸, 끝 세미콜론 제거
    private static final Pattern WHITESPACE_PATTERN = Pattern.compile("\\s+");
    private static final Pattern TRAILING_SEMICOLON_PATTERN = Pattern.compile(";+\\s*$");

    private final QuestionRepository questionRepository;
    private final SubmissionRepository submissionRepository;
    private final AiErrorExplanationRepository errorExplanationRepository;
    private final ChoiceExplanationService choiceExplanationService;
    private final AiExplanationGenerator explanationGenerator;

    /** 오답(또는 정답) 해설: 마지막 제출의 세트 찾기 > 선택지 해설 조회·생성 */
    public AiResult diffExplain(UUID memberUuid, UUID questionUuid, String selectedChoiceKey) {
        Question question = getQuestion(questionUuid);

        // 선택지는 풀이마다 새로 생성되므로, 회원이 실제로 본 세트를 마지막 제출에서 찾는다.
        Optional<Submission> lastSubmission = submissionRepository
                .findFirstByMemberUuidAndQuestionUuidOrderBySubmittedAtDesc(memberUuid, questionUuid);
        UUID choiceSetUuid = lastSubmission.map(Submission::getChoiceSetUuid).orElse(null);
        // 고른 키를 안 보내면(빈 값 포함) 마지막 제출의 키를 쓴다
        String selectedKey = selectedChoiceKey != null && !selectedChoiceKey.isBlank()
                ? selectedChoiceKey
                : lastSubmission.map(Submission::getSelectedChoiceKey).orElse(null);
        if (choiceSetUuid == null || selectedKey == null) {
            log.warn("[ai explain] rejected 400 : no submission for question={}", questionUuid);
            throw new CustomException(ErrorCode.INVALID_INPUT_VALUE);
        }
        return choiceExplanationService.getOrCreateExplanation(question, choiceSetUuid, selectedKey);
    }

    /** SQL 오류 해설: 입력 검증 > 저장본 조회 > 없으면 생성·저장 */
    public AiResult explainError(UUID memberUuid, UUID questionUuid, String sql, String errorMessage) {
        validateErrorExplanationInput(sql, errorMessage);
        Question question = getQuestion(questionUuid);
        String sqlHash = sha256Hex(normalizeSql(sql));
        String errorHash = sha256Hex(errorMessage.trim());

        Optional<AiErrorExplanation> saved = errorExplanationRepository
                .findByQuestionUuidAndSqlHashAndErrorHash(questionUuid, sqlHash, errorHash);
        if (saved.isPresent()) {
            return new AiResult(saved.get().getExplanation(), saved.get().getPromptVersion());
        }

        AiExplanationGenerator.GeneratedExplanation generated =
                explanationGenerator.generateErrorExplanation(question, sql, errorMessage);
        saveErrorExplanation(questionUuid, sqlHash, errorHash, generated);
        return new AiResult(generated.text(), generated.promptVersion());
    }

    private Question getQuestion(UUID questionUuid) {
        return questionRepository.findById(questionUuid)
                .orElseThrow(() -> new CustomException(ErrorCode.QUESTION_NOT_FOUND));
    }

    /** 입력 검증 (빈 값, 길이 상한) */
    private void validateErrorExplanationInput(String sql, String errorMessage) {
        if (sql == null || sql.isBlank() || errorMessage == null || errorMessage.isBlank()
                || sql.length() > MAX_SQL_LENGTH || errorMessage.length() > MAX_ERROR_MESSAGE_LENGTH) {
            log.warn("[ai explain] rejected 400 : invalid error explanation input (sqlLength={}, errorLength={})",
                    sql == null ? 0 : sql.length(), errorMessage == null ? 0 : errorMessage.length());
            throw new CustomException(ErrorCode.INVALID_INPUT_VALUE);
        }
    }

    /** 같은 동시 요청이 먼저 저장했으면 그대로 둔다 (유니크 키 충돌 무시) */
    private void saveErrorExplanation(UUID questionUuid, String sqlHash, String errorHash,
                                      AiExplanationGenerator.GeneratedExplanation generated) {
        try {
            errorExplanationRepository.save(AiErrorExplanation.builder()
                    .questionUuid(questionUuid)
                    .sqlHash(sqlHash)
                    .errorHash(errorHash)
                    .explanation(generated.text())
                    .promptVersion(generated.promptVersion())
                    .createdAt(LocalDateTime.now())
                    .build());
        } catch (DataIntegrityViolationException e) {
            log.info("[ai explain] error explanation already saved : question={}", questionUuid);
        }
    }

    /** SQL > 정규화 (앞뒤 공백 제거, 연속 공백 한 칸, 끝 세미콜론 제거) */
    static String normalizeSql(String sql) {
        String collapsed = WHITESPACE_PATTERN.matcher(sql.trim()).replaceAll(" ");
        return TRAILING_SEMICOLON_PATTERN.matcher(collapsed).replaceAll("");
    }

    static String sha256Hex(String value) {
        try {
            MessageDigest digest = MessageDigest.getInstance("SHA-256");
            return HexFormat.of().formatHex(digest.digest(value.getBytes(StandardCharsets.UTF_8)));
        } catch (NoSuchAlgorithmException e) {
            throw new IllegalStateException("SHA-256 unavailable", e);
        }
    }
}
