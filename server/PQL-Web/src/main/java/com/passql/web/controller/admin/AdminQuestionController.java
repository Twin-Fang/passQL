package com.passql.web.controller.admin;

import com.passql.ai.dto.GenerateQuestionFullResult;
import com.passql.ai.dto.GeneratedChoiceDto;
import com.passql.ai.dto.QuestionFullContextDto;
import com.passql.common.exception.CustomException;
import com.passql.common.exception.constant.ErrorCode;
import com.passql.meta.service.MetaService;
import com.passql.question.constant.ChoiceSetPolicy;
import com.passql.question.constant.ExecutionMode;
import com.passql.question.dto.*;
import com.passql.question.dto.AdminQuestionSearchCondition;
import com.passql.question.entity.Question;
import com.passql.question.service.OracleSqlCompatibilityConverter;
import com.passql.question.service.QuestionGenerateService;
import com.passql.question.service.QuestionService;
import com.passql.question.service.QuestionVectorIndexService;
import com.passql.web.service.AdminQuestionDeleteService;
import com.passql.web.support.AdminMenu;
import com.passql.web.support.AdminPage;
import com.passql.web.support.AdminPageRequest;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.data.domain.PageRequest;
import org.springframework.data.domain.Pageable;
import org.springframework.http.ResponseEntity;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.servlet.mvc.support.RedirectAttributes;

import java.util.ArrayList;
import java.util.List;
import java.util.UUID;

@Slf4j
@Controller
@RequestMapping("/admin/questions")
@RequiredArgsConstructor
public class AdminQuestionController {

    private final QuestionService questionService;
    private final QuestionGenerateService questionGenerateService;
    private final QuestionVectorIndexService questionVectorIndexService;
    private final OracleSqlCompatibilityConverter oracleSqlCompatibilityConverter;
    private final MetaService metaService;
    private final AdminQuestionDeleteService adminQuestionDeleteService;

    @GetMapping
    @AdminPage(menu = AdminMenu.QUESTIONS)
    public String list(Model model, AdminQuestionSearchCondition condition,
                       @RequestParam(defaultValue = "0") int page,
                       @RequestParam(defaultValue = AdminPageRequest.DEFAULT_PAGE_SIZE) int size) {
        Pageable pageable = AdminPageRequest.newestFirst(page, size);
        model.addAttribute("questions", questionService.searchQuestionsForAdmin(condition, pageable));
        model.addAttribute("condition", condition);
        model.addAttribute("topics", metaService.getTopicTree());
        return "admin/questions";
    }

    @GetMapping("/new")
    @AdminPage(menu = AdminMenu.QUESTIONS, title = "문제 등록 (AI 생성)")
    public String newForm(Model model) {
        model.addAttribute("topics", metaService.getTopicTree());
        return "admin/question-new";
    }

    @GetMapping("/register")
    @AdminPage(menu = AdminMenu.QUESTIONS, title = "문제 직접 등록")
    public String registerForm(Model model) {
        model.addAttribute("topics", metaService.getTopicTree());
        return "admin/question-register";
    }

    @PostMapping("/register")
    public String register(
            @RequestParam UUID topicUuid,
            @RequestParam(required = false) UUID subtopicUuid,
            @RequestParam int difficulty,
            @RequestParam String executionMode,
            @RequestParam String stem,
            @RequestParam(required = false) String schemaDdl,
            @RequestParam(required = false) String schemaSampleData,
            @RequestParam(required = false) String schemaIntent,
            @RequestParam(required = false) String answerSql,
            @RequestParam(required = false) String hint,
            @RequestParam(required = false) String choiceSetPolicy
    ) {
        ChoiceSetPolicy policy = toChoiceSetPolicyOrAiOnly(choiceSetPolicy);
        ExecutionMode mode = ExecutionMode.fromRequestValue(executionMode);

        // 1:1 치환 가능한 Oracle 문법을 PostgreSQL 호환으로 변환 (NVL→COALESCE, SYSDATE→NOW())
        String savedDdl       = oracleSqlCompatibilityConverter.translateOracleToPostgres(schemaDdl);
        String savedSample    = oracleSqlCompatibilityConverter.translateOracleToPostgres(schemaSampleData);
        String savedAnswerSql = oracleSqlCompatibilityConverter.translateOracleToPostgres(answerSql);

        // 치환 후에도 Oracle 전용 문법이 남아있으면 CONCEPT_ONLY로 자동 전환
        if (mode == ExecutionMode.EXECUTABLE) {
            String oracleKeyword = oracleSqlCompatibilityConverter.detectOracleOnlySyntax(savedAnswerSql, savedDdl, savedSample, stem);
            if (oracleKeyword != null) {
                log.info("[register] Oracle 전용 문법 감지 → CONCEPT_ONLY 자동 전환: keyword={}", oracleKeyword);
                mode = ExecutionMode.CONCEPT_ONLY;
            }
        }

        Question question = questionGenerateService.createQuestionOnly(
                topicUuid, subtopicUuid, difficulty,
                mode,
                stem, savedDdl, savedSample, schemaIntent,
                savedAnswerSql, hint, policy);

        return "redirect:/admin/questions/" + question.getQuestionUuid();
    }

    @GetMapping("/{uuid}")
    @AdminPage(menu = AdminMenu.QUESTIONS, title = "문제 상세")
    public String detail(@PathVariable UUID uuid, Model model) {
        QuestionDetail question = questionService.getQuestionForAdmin(uuid);
        model.addAttribute("question", question);
        model.addAttribute("isQuestionActive", questionService.isQuestionActive(uuid));
        return "admin/question-detail";
    }

    @GetMapping("/{uuid}/edit")
    @AdminPage(menu = AdminMenu.QUESTIONS, title = "문제 편집")
    public String editForm(@PathVariable UUID uuid, Model model) {
        Question question = questionService.getQuestionEntity(uuid);
        model.addAttribute("question", question);
        model.addAttribute("topics", metaService.getTopicTree());
        return "admin/question-edit";
    }

    @PostMapping("/{uuid}/edit")
    public String update(
            @PathVariable UUID uuid,
            @RequestParam UUID topicUuid,
            @RequestParam(required = false) UUID subtopicUuid,
            @RequestParam int difficulty,
            @RequestParam String stem,
            @RequestParam(required = false) String schemaDisplay,
            @RequestParam(required = false) String schemaDdl,
            @RequestParam(required = false) String schemaSampleData,
            @RequestParam(required = false) String schemaIntent,
            @RequestParam(required = false) String answerSql,
            @RequestParam(required = false) String hint,
            @RequestParam String executionMode
    ) {
        questionService.updateQuestion(uuid, stem, schemaDisplay, schemaDdl, schemaSampleData, schemaIntent,
                answerSql, hint, difficulty, ExecutionMode.fromRequestValue(executionMode), topicUuid, subtopicUuid);
        return "redirect:/admin/questions/" + uuid;
    }

    @DeleteMapping("/{uuid}")
    public String delete(@PathVariable UUID uuid, RedirectAttributes redirectAttributes) {
        try {
            adminQuestionDeleteService.deactivateQuestion(uuid);
            // 커밋 뒤 벡터 정리 — 남기면 추천 결과에 삭제된 문제가 섞인다 (#412)
            questionVectorIndexService.pruneIndex();
            redirectAttributes.addFlashAttribute("successMessage", "문제를 비활성화했습니다. 회원 풀이 기록은 보존됩니다.");
        } catch (CustomException e) {
            redirectAttributes.addFlashAttribute("errorMessage", e.getMessage());
        }
        return "redirect:/admin/questions";
    }

    /** 비활성 문제 복구 (#479): 활성화 > 추천 색인 다시 적재 */
    @PostMapping("/{uuid}/restore")
    @ResponseBody
    public ResponseEntity<Void> restore(@PathVariable UUID uuid) {
        adminQuestionDeleteService.restoreQuestion(uuid);
        questionVectorIndexService.reindexSelected(List.of(uuid.toString()));
        return ResponseEntity.ok().build();
    }

    /** 문제 1건 비활성화 (상세 화면 JSON 요청용, 회원 기록 보존) */
    @PostMapping("/{uuid}/deactivate")
    @ResponseBody
    public ResponseEntity<Void> deactivate(@PathVariable UUID uuid) {
        adminQuestionDeleteService.deactivateQuestion(uuid);
        questionVectorIndexService.pruneIndex();
        return ResponseEntity.ok().build();
    }

    /**
     * 선택 문제 일괄 비활성화 (JSON body: { "questionUuids": [...] }), 회원 기록 보존
     */
    @DeleteMapping("/bulk")
    @ResponseBody
    public ResponseEntity<AdminQuestionDeleteService.BulkDeactivateResult> bulkDelete(
            @RequestBody ExportRequest request) {
        AdminQuestionDeleteService.BulkDeactivateResult result =
                adminQuestionDeleteService.deactivateQuestions(request.questionUuids());
        // 문제마다가 아니라 일괄삭제 끝에 한 번만 정리한다 (#412)
        if (result.deactivated() > 0) questionVectorIndexService.pruneIndex();
        return ResponseEntity.ok(result);
    }

    /**
     * AI 문제 생성 (JSON 반환, AJAX preview 용).
     */
    @PostMapping("/generate-full")
    @ResponseBody
    public ResponseEntity<GenerateQuestionFullResult> generateFull(
            @RequestBody QuestionFullContextDto context) {
        GenerateQuestionFullResult result = questionGenerateService.generate(context);
        return ResponseEntity.ok(result);
    }

    /**
     * 관리자 검수 후 저장.
     */
    @PostMapping
    public String save(
            @RequestParam UUID topicUuid,
            @RequestParam(required = false) UUID subtopicUuid,
            @RequestParam int difficulty,
            @RequestParam String schemaDdl,
            @RequestParam(required = false) String schemaSampleData,
            @RequestParam(required = false) String schemaIntent,
            @RequestParam String stem,
            @RequestParam String answerSql,
            @RequestParam(required = false) String hint,
            @RequestParam(required = false) String choiceSetPolicy,
            @RequestParam List<String> choiceKeys,
            @RequestParam List<String> choiceBodies,
            @RequestParam List<String> choiceCorrects,
            @RequestParam List<String> choiceRationales
    ) {
        int choiceCount = choiceKeys.size();
        if (choiceCount != choiceBodies.size() || choiceCount != choiceCorrects.size() || choiceCount != choiceRationales.size()) {
            throw new CustomException(ErrorCode.QUESTION_GENERATE_INPUT_INVALID);
        }
        List<GeneratedChoiceDto> choices = new ArrayList<>();
        for (int i = 0; i < choiceCount; i++) {
            choices.add(new GeneratedChoiceDto(
                    choiceKeys.get(i),
                    choiceBodies.get(i),
                    "true".equalsIgnoreCase(choiceCorrects.get(i)),
                    choiceRationales.get(i)
            ));
        }

        ChoiceSetPolicy policy = toChoiceSetPolicyOrAiOnly(choiceSetPolicy);

        questionGenerateService.createQuestionWithSeedSet(
                topicUuid, subtopicUuid, difficulty,
                schemaDdl, schemaSampleData, schemaIntent,
                stem, answerSql, hint, policy, choices);

        return "redirect:/admin/questions";
    }

    /** 정책 미입력 > AI_ONLY, 그 외는 fromRequestValue 규칙 */
    private ChoiceSetPolicy toChoiceSetPolicyOrAiOnly(String requestValue) {
        return requestValue == null ? ChoiceSetPolicy.AI_ONLY : ChoiceSetPolicy.fromRequestValue(requestValue);
    }
}
