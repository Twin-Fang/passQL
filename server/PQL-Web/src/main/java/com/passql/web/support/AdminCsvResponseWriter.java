package com.passql.web.support;

import org.springframework.http.ContentDisposition;
import org.springframework.http.HttpHeaders;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;

import java.nio.charset.StandardCharsets;
import java.util.List;

/**
 * 관리자 CSV 내려받기 공통: 머리글 + 행 > 첨부 파일 응답 (BOM 포함 UTF-8, 엑셀 한글 깨짐 방지)
 * 문자열 셀은 수식 인젝션 방지(= + - @ 탭 CR 로 시작하면 ' 접두), 숫자 셀은 그대로, 쉼표·따옴표·줄바꿈은 따옴표로 감쌈
 */
public final class AdminCsvResponseWriter {

    // UTF-8 BOM (엑셀이 인코딩을 UTF-8 로 인식)
    private static final String UTF8_BOM = "﻿";
    private static final String LINE_SEPARATOR = "\r\n";
    private static final String CELL_SEPARATOR = ",";
    // 수식으로 해석될 수 있는 시작 문자 (CSV injection)
    private static final String FORMULA_PREFIX_CHARACTERS = "=+-@\t\r";
    private static final String FORMULA_ESCAPE_PREFIX = "'";
    // 파일명에 허용하는 문자 밖은 _ 로 치환
    private static final String FILE_NAME_FORBIDDEN_PATTERN = "[^A-Za-z0-9._-]";

    private AdminCsvResponseWriter() {
    }

    /** 머리글·행 > CSV 첨부 응답 (fileName 은 확장자 포함, 행 각 셀은 숫자·문자열·날짜 등 아무 값, null 은 빈 칸) */
    public static ResponseEntity<byte[]> toResponse(String fileName, List<String> headers, List<? extends List<?>> rows) {
        StringBuilder csv = new StringBuilder(UTF8_BOM);
        appendLine(csv, headers);
        rows.forEach(row -> appendLine(csv, row));

        String safeFileName = fileName.replaceAll(FILE_NAME_FORBIDDEN_PATTERN, "_");
        return ResponseEntity.ok()
                .header(HttpHeaders.CONTENT_DISPOSITION, ContentDisposition.attachment().filename(safeFileName).build().toString())
                .contentType(new MediaType("text", "csv", StandardCharsets.UTF_8))
                .body(csv.toString().getBytes(StandardCharsets.UTF_8));
    }

    /** 셀 1개 > CSV 텍스트 (수식 인젝션 방지 + 따옴표 처리) */
    static String toCell(Object value) {
        if (value == null) {
            return "";
        }
        // 숫자는 수식 방지 대상 아님 (음수 - 시작 허용)
        if (value instanceof Number) {
            return value.toString();
        }
        String text = value.toString();
        if (!text.isEmpty() && FORMULA_PREFIX_CHARACTERS.indexOf(text.charAt(0)) >= 0) {
            text = FORMULA_ESCAPE_PREFIX + text;
        }
        boolean isQuoteRequired = text.contains(CELL_SEPARATOR) || text.contains("\"") || text.contains("\n") || text.contains("\r");
        return isQuoteRequired ? "\"" + text.replace("\"", "\"\"") + "\"" : text;
    }

    private static void appendLine(StringBuilder csv, List<?> cells) {
        for (int index = 0; index < cells.size(); index++) {
            if (index > 0) {
                csv.append(CELL_SEPARATOR);
            }
            csv.append(toCell(cells.get(index)));
        }
        csv.append(LINE_SEPARATOR);
    }
}
