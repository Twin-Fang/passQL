package com.passql.question.service;

import com.passql.question.constant.QuestionFormatViolationReason;
import com.passql.question.dto.QuestionFormatViolation;

import java.util.ArrayList;
import java.util.LinkedHashSet;
import java.util.List;
import java.util.Locale;
import java.util.Set;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

/**
 * 문항 SQL 서식 규칙 (#905 규칙 5): 키워드 대문자, SELECT 목록 한 줄 40자, 한글 주석 금지(라벨 줄만 허용)
 * 대상: 지문 코드 블록, SQL 보기 본문 (따옴표·주석 안 글자는 키워드로 보지 않음)
 */
public final class QuestionSqlFormatRule {

    // SELECT 목록(SELECT ~ FROM 앞)을 한 줄에 쓸 수 있는 최대 글자 수, 넘으면 항목마다 줄바꿈
    public static final int MAX_SELECT_LIST_LINE_LENGTH = 40;
    // 라벨 주석 줄 최대 글자 수 (-- 뒤 글자, 예: SQL 1, (가), 보기 1)
    public static final int MAX_LABEL_COMMENT_LENGTH = 12;
    // 라벨 주석 시작 (#903 지문 블록 분해와 같은 기준: 코드 맨 앞 "-- 라벨" 줄)
    public static final String LABEL_COMMENT_PREFIX = "--";
    // 대문자로 써야 하는 SQL 키워드 (식별자로 흔한 낱말 DATE·NAME·LEVEL 등은 제외)
    static final Set<String> UPPERCASE_KEYWORDS = Set.of(
            "SELECT", "FROM", "WHERE", "GROUP", "BY", "HAVING", "ORDER", "JOIN", "INNER", "LEFT", "RIGHT", "FULL",
            "OUTER", "CROSS", "NATURAL", "ON", "USING", "AND", "OR", "NOT", "IN", "EXISTS", "BETWEEN", "LIKE", "IS",
            "NULL", "AS", "DISTINCT", "UNION", "ALL", "INTERSECT", "MINUS", "EXCEPT", "CASE", "WHEN", "THEN", "ELSE",
            "END", "INSERT", "INTO", "VALUES", "UPDATE", "SET", "DELETE", "CREATE", "TABLE", "ALTER", "DROP", "WITH",
            "OVER", "PARTITION", "ASC", "DESC", "CONNECT", "PRIOR", "START", "MERGE", "MATCHED", "COMMIT", "ROLLBACK");
    // 한글 (완성형·자모)
    private static final Pattern HANGUL = Pattern.compile("[가-힣ㄱ-ㅎㅏ-ㅣ]");
    // SELECT [DISTINCT] 로 시작하는 줄
    private static final Pattern SELECT_LINE_HEAD = Pattern.compile("^\\s*SELECT\\s+(?:DISTINCT\\s+)?",
            Pattern.CASE_INSENSITIVE);
    // 같은 줄의 최상위 FROM (SELECT 목록 끝)
    private static final Pattern FROM_WORD = Pattern.compile("\\bFROM\\b", Pattern.CASE_INSENSITIVE);
    private static final Pattern WORD = Pattern.compile("[A-Za-z_][A-Za-z0-9_$#]*");
    // 위반 설명에 보여 줄 소문자 키워드 예시 개수
    private static final int KEYWORD_EXAMPLE_LIMIT = 3;

    private QuestionSqlFormatRule() {
    }

    /** SQL 1개 > 서식 위반 목록 (위치는 호출부가 정함: 지문 SQL 1, 보기 B) */
    public static List<QuestionFormatViolation> check(String sql, String location) {
        List<QuestionFormatViolation> violations = new ArrayList<>();
        if (sql == null || sql.isBlank()) return violations;
        SqlPieces pieces = SqlPieces.split(sql);
        findLowercaseKeywordViolation(pieces.codeText(), location, violations);
        findLongSelectListViolations(pieces.codeText(), location, violations);
        findKoreanCommentViolations(pieces.comments(), location, violations);
        return violations;
    }

    // 키워드 대문자: 소문자·섞인 대소문자 키워드 예시 3개까지 한 건으로
    private static void findLowercaseKeywordViolation(String codeText, String location,
                                                      List<QuestionFormatViolation> violations) {
        Set<String> lowercaseKeywords = new LinkedHashSet<>();
        Matcher wordMatcher = WORD.matcher(codeText);
        while (wordMatcher.find()) {
            String word = wordMatcher.group();
            String upperWord = word.toUpperCase(Locale.ROOT);
            if (UPPERCASE_KEYWORDS.contains(upperWord) && !word.equals(upperWord)) lowercaseKeywords.add(word);
        }
        if (lowercaseKeywords.isEmpty()) return;
        String examples = String.join(", ", lowercaseKeywords.stream().limit(KEYWORD_EXAMPLE_LIMIT).toList());
        violations.add(new QuestionFormatViolation(QuestionFormatViolationReason.SQL_KEYWORD_NOT_UPPERCASE, location,
                examples + " > 대문자로", false));
    }

    // SELECT 목록 한 줄 길이: 항목 2개 이상이고 "SELECT 목록" 이 40자 넘으면 위반 (줄마다)
    private static void findLongSelectListViolations(String codeText, String location,
                                                     List<QuestionFormatViolation> violations) {
        String[] lines = codeText.split("\n", -1);
        for (int lineIndex = 0; lineIndex < lines.length; lineIndex++) {
            String line = lines[lineIndex];
            Matcher head = SELECT_LINE_HEAD.matcher(line);
            if (!head.find()) continue;
            String afterSelect = line.substring(head.end());
            Matcher fromMatcher = FROM_WORD.matcher(afterSelect);
            String selectList = fromMatcher.find() ? afterSelect.substring(0, fromMatcher.start()) : afterSelect;
            int itemCount = SqlTextScanner.splitTopLevelCommas(selectList).size();
            int selectListLineLength = (line.substring(0, head.end()) + selectList).trim().length();
            if (itemCount >= 2 && selectListLineLength > MAX_SELECT_LIST_LINE_LENGTH) {
                violations.add(new QuestionFormatViolation(QuestionFormatViolationReason.SQL_SELECT_LIST_TOO_LONG,
                        location + " " + (lineIndex + 1) + "줄",
                        "SELECT 목록 " + selectListLineLength + "자 (최대 " + MAX_SELECT_LIST_LINE_LENGTH + "자) > 항목마다 줄바꿈",
                        false));
            }
        }
    }

    // 한글 주석: 라벨 줄(블록 맨 앞 또는 빈 줄 뒤 단독 "-- 짧은 라벨")만 허용
    private static void findKoreanCommentViolations(List<SqlComment> comments, String location,
                                                    List<QuestionFormatViolation> violations) {
        for (SqlComment comment : comments) {
            if (!HANGUL.matcher(comment.text()).find() || comment.isLabelLine()) continue;
            violations.add(new QuestionFormatViolation(QuestionFormatViolationReason.SQL_KOREAN_COMMENT,
                    location + " " + (comment.lineIndex() + 1) + "줄",
                    "코드 안 한글 설명 주석 > 지문 글로 옮기기 (맨 앞 \"-- SQL 1\" 같은 라벨 줄만 허용)", false));
        }
    }

    /** 주석 1개: 줄 번호(0부터), 주석 글자(-- 뒤), 라벨 줄 여부 */
    record SqlComment(int lineIndex, String text, boolean isLabelLine) {
    }

    /** SQL > 코드 글자(따옴표 안·주석은 빈칸) + 주석 목록 */
    record SqlPieces(String codeText, List<SqlComment> comments) {

        static SqlPieces split(String sql) {
            String normalized = sql.replace("\r\n", "\n");
            StringBuilder code = new StringBuilder(normalized.length());
            List<SqlComment> comments = new ArrayList<>();
            char openQuote = 0;
            int index = 0;
            while (index < normalized.length()) {
                char character = normalized.charAt(index);
                if (openQuote != 0) {
                    if (character == openQuote) openQuote = 0;
                    code.append(character == '\n' ? '\n' : ' ');
                    index++;
                } else if (SqlTextScanner.isQuote(character)) {
                    openQuote = character;
                    code.append(' ');
                    index++;
                } else if (normalized.startsWith(LABEL_COMMENT_PREFIX, index)) {
                    int lineEnd = normalized.indexOf('\n', index);
                    int commentEnd = lineEnd < 0 ? normalized.length() : lineEnd;
                    comments.add(toLineComment(normalized, index, commentEnd));
                    code.append(" ".repeat(commentEnd - index));
                    index = commentEnd;
                } else if (normalized.startsWith("/*", index)) {
                    int blockEnd = normalized.indexOf("*/", index + 2);
                    int commentEnd = blockEnd < 0 ? normalized.length() : blockEnd + 2;
                    String blockText = normalized.substring(index, commentEnd);
                    comments.add(new SqlComment(lineIndexAt(normalized, index), blockText, false));
                    code.append(blockText.replaceAll("[^\n]", " "));
                    index = commentEnd;
                } else {
                    code.append(character);
                    index++;
                }
            }
            return new SqlPieces(code.toString(), comments);
        }

        // 줄 주석 > 라벨 줄 판정 (그 줄에 주석만 있음 + 맨 앞 또는 빈 줄 뒤 + 짧음)
        private static SqlComment toLineComment(String sql, int commentStart, int commentEnd) {
            int lineStart = sql.lastIndexOf('\n', commentStart - 1) + 1;
            boolean isAloneOnLine = sql.substring(lineStart, commentStart).isBlank();
            String text = sql.substring(commentStart + LABEL_COMMENT_PREFIX.length(), commentEnd).trim();
            String before = sql.substring(0, lineStart);
            boolean isStatementStart = before.isBlank() || before.endsWith("\n\n") || before.matches("(?s).*\\n[ \\t]*\\n$");
            boolean isLabelLine = isAloneOnLine && isStatementStart && text.length() <= MAX_LABEL_COMMENT_LENGTH;
            return new SqlComment(lineIndexAt(sql, commentStart), text, isLabelLine);
        }

        private static int lineIndexAt(String text, int position) {
            int lineIndex = 0;
            for (int index = 0; index < position; index++) {
                if (text.charAt(index) == '\n') lineIndex++;
            }
            return lineIndex;
        }
    }
}
