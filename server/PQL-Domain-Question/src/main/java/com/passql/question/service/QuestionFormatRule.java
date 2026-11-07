package com.passql.question.service;

import com.passql.question.constant.QuestionFormatViolationReason;
import com.passql.question.dto.QuestionFormatCheckResult;
import com.passql.question.dto.QuestionFormatChoice;
import com.passql.question.dto.QuestionFormatInput;
import com.passql.question.dto.QuestionFormatViolation;
import com.passql.question.dto.QuestionSchemaColumn;
import com.passql.question.dto.QuestionSchemaTable;
import com.passql.question.service.StemMarkdownLayout.LineKind;
import com.passql.question.service.StemMarkdownLayout.TableBlock;

import java.util.ArrayList;
import java.util.HashSet;
import java.util.List;
import java.util.Locale;
import java.util.Set;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

/**
 * 문항 형식 규칙 단일 원본 (#905): 가져오기·관리자 저장·모의고사 공개 검사·생성 저장·일괄 점검 공통
 * 규칙 7개: 줄표·가운뎃점, 데이터 표는 스키마 한 곳, PK·FK 글, 자료형 반복, SQL 서식(QuestionSqlFormatRule), 질문 1개, "- " 목록
 */
public final class QuestionFormatRule {

    public static final String LOCATION_STEM = "지문";
    public static final String LOCATION_HINT = "힌트";
    // 질문 문장 끝 기호와 필요 개수 (#903 지문 블록 분해와 같은 기준: "?" 로 끝나는 문장 1개)
    public static final String QUESTION_SENTENCE_END_MARKS = "?？";
    public static final int REQUIRED_QUESTION_SENTENCE_COUNT = 1;
    // 목록 줄 기호 (#903 지문 블록 분해와 같은 기준)
    public static final String LIST_ITEM_PREFIX = "- ";
    // 개념 글 문단 제목 부제 구분 "## 제목: 부제 {#앵커}" (앱 ConceptReadingParser 와 같은 기준, #903)
    public static final String CONCEPT_HEADING_SUBTITLE_SEPARATOR = ": ";
    // 줄표·가운뎃점 위반 설명에 보여 줄 앞뒤 글자 수
    private static final int PUNCTUATION_CONTEXT_LENGTH = 12;

    // 질문 문장 끝 (뒤가 공백·끝·닫는 괄호/따옴표)
    private static final Pattern QUESTION_SENTENCE_END = Pattern.compile(
            "[" + QUESTION_SENTENCE_END_MARKS + "](?=\\s|$|[)\"'”’」』\\]])");
    private static final Pattern INLINE_CODE = Pattern.compile("`[^`\\n]*`");
    // 글자로 쓴 키 표시: (PK) (FK) (PK, FK) [PK]
    private static final Pattern KEY_MARK_TEXT = Pattern.compile(
            "[(\\[]\\s*(?:PK|FK)(?:\\s*[,/·]\\s*(?:PK|FK))*\\s*[)\\]]", Pattern.CASE_INSENSITIVE);
    // 표 칸 전체가 키 표시 (| PK |)
    private static final Pattern KEY_MARK_CELL = Pattern.compile("(?:PK|FK)(?:\\s*[,/·]\\s*(?:PK|FK))*",
            Pattern.CASE_INSENSITIVE);
    // "- " 아닌 목록 기호 9종: * • ◦ ▪ ○ ● ■ □ + (줄 맨 앞 가운뎃점은 규칙 1 이 잡음)
    static final Pattern NON_DASH_LIST_MARKER = Pattern.compile("^(\\s*)([*•◦▪○●■□+])\\s+");
    private static final Pattern FORBIDDEN_PUNCTUATION = Pattern.compile(
            "[" + ForbiddenPunctuationCleaner.DASH_CHARACTERS + ForbiddenPunctuationCleaner.MIDDLE_DOT_CHARACTERS + "]");

    private QuestionFormatRule() {
    }

    /** 문항 1개 > 형식 검사 결과 (위반 없으면 통과) */
    public static QuestionFormatCheckResult check(QuestionFormatInput input) {
        List<QuestionFormatViolation> violations = new ArrayList<>();
        StemMarkdownLayout layout = StemMarkdownLayout.parse(input.stem());
        List<QuestionSchemaTable> schemaTables = SchemaPreviewParser.parse(input.schemaDdl(), input.schemaSampleData());

        // 1 줄표·가운뎃점 (지문·힌트·보기·근거)
        violations.addAll(findForbiddenPunctuationViolations(input.stem(), LOCATION_STEM));
        violations.addAll(findForbiddenPunctuationViolations(input.hint(), LOCATION_HINT));
        // 2~4, 6, 7 지문 구조
        findStemTableViolations(layout, schemaTables, Boolean.TRUE.equals(input.isExecutable()), violations);
        findKeyMarkViolations(layout, violations);
        findColumnTypeViolations(layout, schemaTables, violations);
        findQuestionSentenceViolation(layout, violations);
        findListMarkerViolations(layout, violations);
        // 5 SQL 서식 (지문 sql·언어 없는 코드 블록, SQL 보기)
        for (StemMarkdownLayout.CodeBlock codeBlock : layout.codeBlocks()) {
            if (codeBlock.language().isEmpty() || "sql".equals(codeBlock.language())) {
                violations.addAll(QuestionSqlFormatRule.check(codeBlock.content(), LOCATION_STEM + " SQL " + codeBlock.ordinal()));
            }
        }
        for (QuestionFormatChoice choice : input.choices()) {
            violations.addAll(findChoiceViolations(choice));
        }
        return QuestionFormatCheckResult.of(violations);
    }

    /** 보기 1개: 본문·근거 줄표·가운뎃점 + SQL 보기 서식 */
    public static List<QuestionFormatViolation> findChoiceViolations(QuestionFormatChoice choice) {
        String location = "보기 " + choice.choiceKey();
        List<QuestionFormatViolation> violations = new ArrayList<>(findForbiddenPunctuationViolations(choice.body(), location));
        violations.addAll(findForbiddenPunctuationViolations(choice.rationale(), location + " 근거"));
        if (Boolean.TRUE.equals(choice.isSqlBody())) violations.addAll(QuestionSqlFormatRule.check(choice.body(), location));
        return violations;
    }

    /** 글 1개 줄표·가운뎃점 검사 (1건으로 묶음, 자동 정리 가능) */
    public static List<QuestionFormatViolation> findForbiddenPunctuationViolations(String text, String location) {
        if (!ForbiddenPunctuationCleaner.hasForbiddenPunctuation(text)) return List.of();
        return List.of(toPunctuationViolation(text, location, true,
                "짝은 \"용어: 설명\", 나열·문장은 쉼표로"));
    }

    /** 개념 글 줄표·가운뎃점 검사 (소제목 부제 " — " 도 위반 > "제목: 부제"), 원본은 content/concepts 라 화면 자동 정리 안 함 */
    public static List<QuestionFormatViolation> findConceptArticlePunctuationViolations(String markdown, String location) {
        if (!ForbiddenPunctuationCleaner.hasForbiddenPunctuation(markdown)) return List.of();
        return List.of(toPunctuationViolation(markdown, location, false,
                "개념 원본(content/concepts)에서 고친 뒤 다시 가져오기"));
    }

    private static QuestionFormatViolation toPunctuationViolation(String text, String location, boolean isAutoFixable,
                                                           String guide) {
        Matcher punctuationMatcher = FORBIDDEN_PUNCTUATION.matcher(text);
        long punctuationCount = FORBIDDEN_PUNCTUATION.matcher(text).results().count();
        punctuationMatcher.find();
        int start = Math.max(0, punctuationMatcher.start() - PUNCTUATION_CONTEXT_LENGTH);
        int end = Math.min(text.length(), punctuationMatcher.end() + PUNCTUATION_CONTEXT_LENGTH);
        String context = text.substring(start, end).replace('\n', ' ').trim();
        return new QuestionFormatViolation(QuestionFormatViolationReason.FORBIDDEN_PUNCTUATION, location,
                "\"" + context + "\" 등 " + punctuationCount + "곳 > " + guide, isAutoFixable);
    }

    // 2 지문 표: 스키마 표와 컬럼이 같고 샘플 행 있음 > 중복(지움), 머리말·같은 컬럼 있는 데이터 표 > 스키마로 옮김
    private static void findStemTableViolations(StemMarkdownLayout layout, List<QuestionSchemaTable> schemaTables,
                                                boolean isExecutable, List<QuestionFormatViolation> violations) {
        for (TableBlock table : layout.tableBlocks()) {
            QuestionSchemaTable matchingSchemaTable = findSchemaTableWithSameColumns(table, schemaTables);
            String location = LOCATION_STEM + " " + (table.firstLineIndex() + 1) + "줄";
            String tableName = table.labelName() != null ? "[" + table.labelName() + "] 표" : "표";
            if (matchingSchemaTable != null && !matchingSchemaTable.sampleRows().isEmpty()) {
                violations.add(new QuestionFormatViolation(QuestionFormatViolationReason.STEM_TABLE_DUPLICATES_SCHEMA,
                        location, tableName + "가 스키마 표 " + matchingSchemaTable.tableName() + " 와 컬럼이 같음 > 지문 표 삭제",
                        true));
            } else if (matchingSchemaTable != null || table.labelName() != null) {
                boolean isConvertible = StemTableSchemaConverter.canConvert(table, matchingSchemaTable, schemaTables, isExecutable);
                violations.add(new QuestionFormatViolation(QuestionFormatViolationReason.STEM_DATA_TABLE_OUTSIDE_SCHEMA,
                        location, tableName + " 데이터를 스키마 표(CREATE TABLE·샘플 INSERT)로 옮기기"
                        + (isConvertible ? "" : " (실행형이거나 표 이름·칸이 맞지 않아 손으로)"), isConvertible));
            }
        }
    }

    /** 지문 표와 컬럼 구성(대소문자 무시, 순서 무관)이 같은 스키마 표 (없으면 null) */
    static QuestionSchemaTable findSchemaTableWithSameColumns(TableBlock table, List<QuestionSchemaTable> schemaTables) {
        Set<String> tableColumns = new HashSet<>(table.upperColumnNames());
        for (QuestionSchemaTable schemaTable : schemaTables) {
            Set<String> schemaColumns = new HashSet<>();
            schemaTable.columns().forEach(column -> schemaColumns.add(column.name().toUpperCase(Locale.ROOT)));
            if (schemaColumns.equals(tableColumns) && schemaTable.columns().size() == table.headerCells().size()) {
                return schemaTable;
            }
        }
        return null;
    }

    // 3 PK·FK 글 표시: 글·표 줄의 (PK)·[FK], 표 칸 전체가 PK·FK (줄마다 1건)
    private static void findKeyMarkViolations(StemMarkdownLayout layout, List<QuestionFormatViolation> violations) {
        for (int lineIndex = 0; lineIndex < layout.lines().size(); lineIndex++) {
            LineKind kind = layout.kindOf(lineIndex);
            String line = layout.lines().get(lineIndex);
            boolean hasKeyMarkText = kind != LineKind.CODE && KEY_MARK_TEXT.matcher(line).find();
            boolean hasKeyMarkCell = kind == LineKind.TABLE && StemMarkdownLayout.splitCells(line).stream()
                    .anyMatch(cell -> KEY_MARK_CELL.matcher(cell).matches());
            if (hasKeyMarkText || hasKeyMarkCell) {
                violations.add(new QuestionFormatViolation(QuestionFormatViolationReason.KEY_MARK_TEXT_IN_STEM,
                        LOCATION_STEM + " " + (lineIndex + 1) + "줄",
                        "키는 스키마 DDL 의 PRIMARY KEY·REFERENCES 로만 (지문 글 표시 삭제)", false));
            }
        }
    }

    // 4 자료형: 스키마 컬럼 이름 바로 뒤에 그 컬럼 자료형을 지문(글·표)에 다시 적음 (스키마 표가 이미 보여 줌)
    private static void findColumnTypeViolations(StemMarkdownLayout layout, List<QuestionSchemaTable> schemaTables,
                                                 List<QuestionFormatViolation> violations) {
        StringBuilder nonCodeText = new StringBuilder();
        for (int lineIndex = 0; lineIndex < layout.lines().size(); lineIndex++) {
            if (layout.kindOf(lineIndex) != LineKind.CODE) nonCodeText.append(layout.lines().get(lineIndex)).append('\n');
        }
        Set<String> reportedColumns = new HashSet<>();
        for (QuestionSchemaTable schemaTable : schemaTables) {
            for (QuestionSchemaColumn column : schemaTable.columns()) {
                String typeHead = column.type() == null ? "" : column.type().split("\\(", 2)[0].trim();
                if (typeHead.isEmpty() || !reportedColumns.add(column.name().toUpperCase(Locale.ROOT))) continue;
                Pattern columnWithType = Pattern.compile("(?<![A-Za-z0-9_])" + Pattern.quote(column.name())
                        + "(?![A-Za-z0-9_])\\s*[:(|]?\\s*" + Pattern.quote(typeHead) + "(?![A-Za-z0-9_])",
                        Pattern.CASE_INSENSITIVE);
                if (columnWithType.matcher(nonCodeText).find()) {
                    violations.add(new QuestionFormatViolation(QuestionFormatViolationReason.COLUMN_TYPE_TEXT_IN_STEM,
                            LOCATION_STEM, column.name() + " " + typeHead + " > 스키마 표가 자료형을 보여 주니 지문에서 삭제", false));
                }
            }
        }
    }

    // 6 질문 문장: 글 줄(코드·표 제외, 인라인 코드 제외)에서 ? 로 끝나는 문장 정확히 1개
    private static void findQuestionSentenceViolation(StemMarkdownLayout layout, List<QuestionFormatViolation> violations) {
        StringBuilder proseText = new StringBuilder();
        for (int lineIndex = 0; lineIndex < layout.lines().size(); lineIndex++) {
            if (layout.kindOf(lineIndex) == LineKind.PROSE) proseText.append(layout.lines().get(lineIndex)).append('\n');
        }
        String withoutInlineCode = INLINE_CODE.matcher(proseText).replaceAll("");
        long questionSentenceCount = QUESTION_SENTENCE_END.matcher(withoutInlineCode).results().count();
        if (questionSentenceCount != REQUIRED_QUESTION_SENTENCE_COUNT) {
            violations.add(new QuestionFormatViolation(QuestionFormatViolationReason.QUESTION_SENTENCE_COUNT,
                    LOCATION_STEM, "\"?\" 로 끝나는 질문 문장 " + questionSentenceCount + "개 (정확히 "
                    + REQUIRED_QUESTION_SENTENCE_COUNT + "개)", false));
        }
    }

    // 7 목록 기호: 글 줄의 * • · 등 > "- " (자동 정리 가능)
    private static void findListMarkerViolations(StemMarkdownLayout layout, List<QuestionFormatViolation> violations) {
        for (int lineIndex = 0; lineIndex < layout.lines().size(); lineIndex++) {
            if (layout.kindOf(lineIndex) != LineKind.PROSE) continue;
            Matcher marker = NON_DASH_LIST_MARKER.matcher(layout.lines().get(lineIndex));
            if (marker.find()) {
                violations.add(new QuestionFormatViolation(QuestionFormatViolationReason.LIST_MARKER_NOT_DASH,
                        LOCATION_STEM + " " + (lineIndex + 1) + "줄",
                        "\"" + marker.group(2) + "\" > \"" + LIST_ITEM_PREFIX + "용어: 설명\"", true));
            }
        }
    }
}
