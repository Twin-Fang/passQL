package com.passql.question.service;

import java.util.ArrayList;
import java.util.List;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

/**
 * SELECT 목록 줄바꿈 자동 정리 (#923): 형식 검사가 잡은 SELECT 줄(40자 초과) > 항목마다 줄바꿈(첫 항목 열 맞춤), 같은 줄 FROM 은 다음 줄
 * 공백만 바꿈, 공백 뺀 글자가 원본과 다르면 원본 유지 (토큰 동일 보장)
 */
public final class SqlSelectListLineBreaker {

    private static final Pattern LEADING_WHITESPACE = Pattern.compile("^\\s*");
    private static final Pattern WHITESPACE = Pattern.compile("\\s+");
    private static final String FROM_KEYWORD = "FROM";

    private SqlSelectListLineBreaker() {
    }

    /** SQL 1개 > SELECT 목록 줄바꿈 (바꿀 줄 없거나 토큰이 달라지면 원본 그대로) */
    public static String breakLongSelectLists(String sql) {
        if (sql == null || sql.isBlank()) return sql;
        String normalized = sql.replace("\r\n", "\n");
        // 따옴표 안·주석은 빈칸인 코드 글자 (줄 위치 동일) > 리터럴·주석 안 쉼표·FROM 무시
        String codeText = QuestionSqlFormatRule.SqlPieces.split(normalized).codeText();
        String[] lines = normalized.split("\n", -1);
        String[] codeLines = codeText.split("\n", -1);
        if (lines.length != codeLines.length) return sql;

        List<String> brokenLines = new ArrayList<>(lines.length);
        for (int lineIndex = 0; lineIndex < lines.length; lineIndex++) {
            brokenLines.add(breakSelectLine(lines[lineIndex], codeLines[lineIndex]));
        }
        String broken = String.join("\n", brokenLines);
        if (broken.equals(normalized) || !hasSameTokens(sql, broken)) return sql;
        return broken;
    }

    /** 공백 전부 뺀 글자가 같음 (줄바꿈·들여쓰기만 바뀜) */
    public static boolean hasSameTokens(String before, String after) {
        if (before == null || after == null) return before == after;
        return WHITESPACE.matcher(before).replaceAll("").equals(WHITESPACE.matcher(after).replaceAll(""));
    }

    // SELECT 줄 1개: 형식 검사가 위반으로 잡은 줄만 > 최상위 쉼표 뒤 줄바꿈 + 최상위 FROM 앞 줄바꿈
    private static String breakSelectLine(String line, String codeLine) {
        int selectListLineLength = QuestionSqlFormatRule.measureSelectListLineLength(codeLine);
        if (selectListLineLength <= QuestionSqlFormatRule.MAX_SELECT_LIST_LINE_LENGTH) return line;
        Matcher head = QuestionSqlFormatRule.SELECT_LINE_HEAD.matcher(codeLine);
        if (!head.find()) return line;
        SelectListShape shape = SelectListShape.scan(codeLine, head.end());
        if (shape == null || shape.breakCommaIndexes().isEmpty()) return line;

        // 이어지는 항목은 첫 항목 열에 맞춤, FROM 줄은 SELECT 줄 들여쓰기
        Matcher leading = LEADING_WHITESPACE.matcher(line);
        String statementIndent = leading.find() ? leading.group() : "";
        String itemIndent = statementIndent + " ".repeat(head.end() - statementIndent.length());
        List<String> outputLines = new ArrayList<>();
        int itemStart = 0;
        for (int commaIndex : shape.breakCommaIndexes()) {
            String item = line.substring(itemStart, commaIndex + 1);
            outputLines.add(itemStart == 0 ? item.stripTrailing() : itemIndent + item.strip());
            itemStart = commaIndex + 1;
        }
        outputLines.add(itemIndent + line.substring(itemStart, shape.selectListEnd()).strip());
        if (shape.hasFrom()) outputLines.add(statementIndent + line.substring(shape.selectListEnd()).strip());
        return String.join("\n", outputLines);
    }

    /** SELECT 목록 모양: 줄바꿈할 최상위 쉼표 위치, 목록 끝(최상위 FROM 또는 줄 끝), FROM 여부 */
    private record SelectListShape(List<Integer> breakCommaIndexes, int selectListEnd, boolean hasFrom) {

        // 괄호 깊이 0 의 쉼표·FROM 찾기 (닫는 괄호가 더 많으면 바깥 문장 일부라 정리 안 함 > null)
        static SelectListShape scan(String codeLine, int listStart) {
            List<Integer> commaIndexes = new ArrayList<>();
            int depth = 0;
            for (int index = listStart; index < codeLine.length(); index++) {
                char character = codeLine.charAt(index);
                if (character == '(') depth++;
                else if (character == ')' && --depth < 0) return null;
                else if (character == ',' && depth == 0) commaIndexes.add(index);
                else if (depth == 0 && isFromKeywordAt(codeLine, index)) {
                    return new SelectListShape(toBreakCommas(codeLine, commaIndexes, index), index, true);
                }
            }
            return new SelectListShape(toBreakCommas(codeLine, commaIndexes, codeLine.length()), codeLine.length(), false);
        }

        // 뒤에 항목이 이어지는 쉼표만 (줄 끝 쉼표는 이미 줄바꿈된 목록)
        private static List<Integer> toBreakCommas(String codeLine, List<Integer> commaIndexes, int listEnd) {
            return commaIndexes.stream()
                    .filter(commaIndex -> !codeLine.substring(commaIndex + 1, listEnd).isBlank())
                    .toList();
        }

        // 낱말 경계의 FROM (EXTRACT(YEAR FROM X) 는 괄호 안이라 깊이로 걸러짐)
        private static boolean isFromKeywordAt(String codeLine, int index) {
            if (!codeLine.regionMatches(true, index, FROM_KEYWORD, 0, FROM_KEYWORD.length())) return false;
            boolean isWordStart = index == 0 || !isIdentifierCharacter(codeLine.charAt(index - 1));
            int endIndex = index + FROM_KEYWORD.length();
            boolean isWordEnd = endIndex >= codeLine.length() || !isIdentifierCharacter(codeLine.charAt(endIndex));
            return isWordStart && isWordEnd;
        }

        private static boolean isIdentifierCharacter(char character) {
            return Character.isLetterOrDigit(character) || character == '_' || character == '$' || character == '#';
        }
    }
}
