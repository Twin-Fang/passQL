package com.passql.application.questionformat;

import com.passql.application.questionformat.dto.QuestionFormatFieldChange;
import com.passql.common.util.UuidUtils;
import com.passql.question.constant.ChoiceKind;
import com.passql.question.dto.QuestionFormatInput;
import com.passql.question.entity.Question;
import com.passql.question.entity.QuestionChoiceSet;
import com.passql.question.entity.QuestionChoiceSetItem;
import com.passql.question.service.ChoiceExplanationComposer;
import com.passql.question.service.ForbiddenPunctuationCleaner;
import com.passql.question.service.QuestionFormatAutoFixer;

import java.util.ArrayList;
import java.util.LinkedHashSet;
import java.util.List;
import java.util.Objects;
import java.util.Set;

/**
 * 문제 1개 자동 정리 계획 (#905): 문제 필드(QuestionFormatAutoFixer) + 공유 세트 보기 글·세트 해설 줄표·가운뎃점(ForbiddenPunctuationCleaner)
 * 미리보기와 적용이 같은 계획을 씀 (적용 시 서버가 다시 계산, 화면 값은 믿지 않음)
 */
final class QuestionFormatFixPlanner {

    static final String FIELD_STEM = "지문";
    static final String FIELD_HINT = "힌트";
    static final String FIELD_SCHEMA_DDL = "스키마 DDL";
    static final String FIELD_SCHEMA_SAMPLE_DATA = "샘플 데이터";
    // 결과 표 보기 본문(JSON) 시작 문자 > 줄표·가운뎃점 정리 대상 아님
    private static final String JSON_BODY_PREFIXES = "[{";

    /** 보기 1개 정리 후 글 (바뀌지 않은 필드는 원문) */
    record ItemTextFix(QuestionChoiceSetItem item, String body, String rationale, String explanation) {
    }

    /** 세트 해설 JSON 정리 후 */
    record SetExplanationFix(QuestionChoiceSet choiceSet, String explanationJson) {
    }

    /** 문제 1개 계획: 문제 필드 결과 + 보기·해설 정리 + 미리보기 필드 변경 */
    record Plan(Question question, QuestionFormatAutoFixer.Result questionResult, List<ItemTextFix> itemFixes,
                List<SetExplanationFix> explanationFixes, List<String> fixNames,
                List<QuestionFormatFieldChange> changes) {

        boolean hasChanges() {
            return !changes.isEmpty();
        }
    }

    private QuestionFormatFixPlanner() {
    }

    static Plan plan(Question question, QuestionFormatScanScope scope) {
        List<QuestionFormatFieldChange> changes = new ArrayList<>();
        Set<String> fixNames = new LinkedHashSet<>();

        // 문제 필드 (지문 표·목록 기호·줄표·가운뎃점)
        QuestionFormatAutoFixer.Result questionResult = QuestionFormatAutoFixer.fix(QuestionFormatInput.from(question, List.of()));
        fixNames.addAll(questionResult.appliedFixes());
        addChange(changes, FIELD_STEM, question.getStem(), questionResult.stem());
        addChange(changes, FIELD_HINT, question.getHint(), questionResult.hint());
        addChange(changes, FIELD_SCHEMA_DDL, question.getSchemaDdl(), questionResult.schemaDdl());
        addChange(changes, FIELD_SCHEMA_SAMPLE_DATA, question.getSchemaSampleData(), questionResult.schemaSampleData());

        // 공유 세트 보기 글·세트 해설 줄표·가운뎃점
        List<ItemTextFix> itemFixes = new ArrayList<>();
        List<SetExplanationFix> explanationFixes = new ArrayList<>();
        for (QuestionChoiceSet choiceSet : scope.setsOf(question.getQuestionUuid())) {
            String setLabel = "세트 " + UuidUtils.toShortForm(choiceSet.getChoiceSetUuid());
            for (QuestionChoiceSetItem item : scope.itemsOf(choiceSet.getChoiceSetUuid())) {
                ItemTextFix itemFix = planItem(item);
                String itemLabel = setLabel + " 보기 " + item.getChoiceKey();
                int changeCountBefore = changes.size();
                addChange(changes, itemLabel + " 본문", item.getBody(), itemFix.body());
                addChange(changes, itemLabel + " 근거", item.getRationale(), itemFix.rationale());
                addChange(changes, itemLabel + " 해설", item.getExplanation(), itemFix.explanation());
                if (changes.size() > changeCountBefore) itemFixes.add(itemFix);
            }
            String cleanedExplanationJson = cleanExplanationJson(choiceSet.getExplanationJson());
            if (!Objects.equals(cleanedExplanationJson, choiceSet.getExplanationJson())) {
                explanationFixes.add(new SetExplanationFix(choiceSet, cleanedExplanationJson));
                addChange(changes, setLabel + " 해설", choiceSet.getExplanationJson(), cleanedExplanationJson);
            }
        }
        if (!itemFixes.isEmpty() || !explanationFixes.isEmpty()) fixNames.add(QuestionFormatAutoFixer.FIX_PUNCTUATION);
        return new Plan(question, questionResult, itemFixes, explanationFixes, List.copyOf(fixNames), changes);
    }

    // 보기 글: 근거·해설은 항상, 본문은 글 보기만 (SQL·결과 표 JSON 은 실행 검증본이라 그대로)
    private static ItemTextFix planItem(QuestionChoiceSetItem item) {
        String body = item.getBody();
        boolean isTextBody = item.getKind() == ChoiceKind.TEXT && body != null
                && (body.isBlank() || JSON_BODY_PREFIXES.indexOf(body.strip().charAt(0)) < 0);
        return new ItemTextFix(item, isTextBody ? ForbiddenPunctuationCleaner.clean(body) : body,
                ForbiddenPunctuationCleaner.clean(item.getRationale()), ForbiddenPunctuationCleaner.clean(item.getExplanation()));
    }

    // 세트 해설 JSON > 해석 > 글 정리 > JSON (해석 못 하면 원문 유지)
    private static String cleanExplanationJson(String explanationJson) {
        if (!ForbiddenPunctuationCleaner.hasForbiddenPunctuation(explanationJson)) return explanationJson;
        return ChoiceExplanationComposer.parse(explanationJson)
                .map(explanation -> ChoiceExplanationComposer.toJson(ForbiddenPunctuationCleaner.clean(explanation)))
                .orElse(explanationJson);
    }

    private static void addChange(List<QuestionFormatFieldChange> changes, String fieldName, String before, String after) {
        if (!Objects.equals(before, after)) changes.add(new QuestionFormatFieldChange(fieldName, before, after));
    }
}
