package com.passql.question.service;

import java.util.ArrayList;
import java.util.List;

/**
 * SQL 문자열 어휘 도우미: 주석 제거, 문장 분리, 괄호 짝 찾기, 최상위 쉼표 분리
 * 따옴표 3종(' " `) 안의 ; , ( ) 는 구분자로 보지 않음
 */
final class SqlTextScanner {

    private static final char SINGLE_QUOTE = '\'';
    private static final char DOUBLE_QUOTE = '"';
    private static final char BACKTICK = '`';

    private SqlTextScanner() {
    }

    /** SQL 묶음 > 문장 목록 (주석 제거, 빈 문장 제외) */
    static List<String> splitStatements(String sql) {
        List<String> statements = new ArrayList<>();
        if (sql == null || sql.isBlank()) return statements;
        String withoutComments = removeComments(sql);
        StringBuilder current = new StringBuilder();
        char openQuote = 0;
        for (int index = 0; index < withoutComments.length(); index++) {
            char character = withoutComments.charAt(index);
            if (openQuote != 0) {
                if (character == openQuote) openQuote = 0;
            } else if (isQuote(character)) {
                openQuote = character;
            } else if (character == ';') {
                addIfNotBlank(statements, current);
                current.setLength(0);
                continue;
            }
            current.append(character);
        }
        addIfNotBlank(statements, current);
        return statements;
    }

    /** openIndex 의 '(' 와 짝인 ')' 위치 (없으면 -1) */
    static int findMatchingParenthesis(String text, int openIndex) {
        int depth = 0;
        char openQuote = 0;
        for (int index = openIndex; index < text.length(); index++) {
            char character = text.charAt(index);
            if (openQuote != 0) {
                if (character == openQuote) openQuote = 0;
            } else if (isQuote(character)) {
                openQuote = character;
            } else if (character == '(') {
                depth++;
            } else if (character == ')') {
                depth--;
                if (depth == 0) return index;
            }
        }
        return -1;
    }

    /** 괄호·따옴표 밖의 쉼표로 분리 (각 조각 trim) */
    static List<String> splitTopLevelCommas(String text) {
        List<String> parts = new ArrayList<>();
        StringBuilder current = new StringBuilder();
        int depth = 0;
        char openQuote = 0;
        for (int index = 0; index < text.length(); index++) {
            char character = text.charAt(index);
            if (openQuote != 0) {
                if (character == openQuote) openQuote = 0;
            } else if (isQuote(character)) {
                openQuote = character;
            } else if (character == '(') {
                depth++;
            } else if (character == ')') {
                depth--;
            } else if (character == ',' && depth == 0) {
                parts.add(current.toString().trim());
                current.setLength(0);
                continue;
            }
            current.append(character);
        }
        if (!current.toString().isBlank()) parts.add(current.toString().trim());
        return parts;
    }

    /** 식별자 따옴표 제거 + 스키마 접두사 제거 ("hr"."EMP" > EMP) */
    static String toBareIdentifier(String identifier) {
        String trimmed = identifier.trim();
        int dotIndex = trimmed.lastIndexOf('.');
        String lastPart = dotIndex >= 0 ? trimmed.substring(dotIndex + 1) : trimmed;
        if (lastPart.length() >= 2 && isQuote(lastPart.charAt(0))
                && lastPart.charAt(lastPart.length() - 1) == lastPart.charAt(0)) {
            return lastPart.substring(1, lastPart.length() - 1);
        }
        return lastPart;
    }

    static boolean isQuote(char character) {
        return character == SINGLE_QUOTE || character == DOUBLE_QUOTE || character == BACKTICK;
    }

    /** 주석 2종 제거 (-- 줄 끝까지, /* *\/ 블록), 따옴표 안은 유지 */
    private static String removeComments(String sql) {
        StringBuilder result = new StringBuilder(sql.length());
        char openQuote = 0;
        int index = 0;
        while (index < sql.length()) {
            char character = sql.charAt(index);
            if (openQuote != 0) {
                if (character == openQuote) openQuote = 0;
                result.append(character);
                index++;
            } else if (isQuote(character)) {
                openQuote = character;
                result.append(character);
                index++;
            } else if (sql.startsWith("--", index)) {
                int lineEnd = sql.indexOf('\n', index);
                index = lineEnd < 0 ? sql.length() : lineEnd;
            } else if (sql.startsWith("/*", index)) {
                int blockEnd = sql.indexOf("*/", index + 2);
                index = blockEnd < 0 ? sql.length() : blockEnd + 2;
            } else {
                result.append(character);
                index++;
            }
        }
        return result.toString();
    }

    private static void addIfNotBlank(List<String> statements, StringBuilder statement) {
        String trimmed = statement.toString().trim();
        if (!trimmed.isEmpty()) statements.add(trimmed);
    }
}
