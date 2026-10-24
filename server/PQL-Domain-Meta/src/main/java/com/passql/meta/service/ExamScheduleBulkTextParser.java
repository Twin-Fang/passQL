package com.passql.meta.service;

import com.passql.meta.constant.CertType;

import java.time.LocalDate;
import java.time.format.DateTimeParseException;
import java.util.ArrayList;
import java.util.List;
import java.util.regex.Pattern;

/**
 * 시험 일정 일괄 등록 붙여넣기 텍스트 해석: 한 줄에 "자격증 회차 시험일" (공백·쉼표·탭 구분)
 * 예: SQLD 63 2026-11-14 / 시험일은 2026-11-14, 2026.11.14, 2026/11/14 허용 / 빈 줄과 # 주석 줄은 무시
 */
public final class ExamScheduleBulkTextParser {

    // 줄 안 구분자: 공백·탭·쉼표 연속
    private static final Pattern FIELD_DELIMITER = Pattern.compile("[\\s,]+");
    // 줄 필드 수: 자격증, 회차, 시험일
    private static final int FIELD_COUNT = 3;

    private ExamScheduleBulkTextParser() {
    }

    /** 해석된 일정 1건 */
    public record Entry(CertType certType, int round, LocalDate examDate) {}

    /** 해석 결과 (errors: "N번째 줄: 사유", 하나라도 있으면 등록하지 않음) */
    public record ParseResult(List<Entry> entries, List<String> errors) {}

    public static ParseResult parse(String text) {
        List<Entry> entries = new ArrayList<>();
        List<String> errors = new ArrayList<>();
        if (text == null) {
            return new ParseResult(entries, errors);
        }
        String[] lines = text.split("\\R");
        for (int index = 0; index < lines.length; index++) {
            String line = lines[index].trim();
            if (line.isEmpty() || line.startsWith("#")) {
                continue;
            }
            String lineLabel = (index + 1) + "번째 줄";
            String[] fields = FIELD_DELIMITER.split(line);
            if (fields.length != FIELD_COUNT) {
                errors.add(lineLabel + ": '자격증 회차 시험일' 3개 값이어야 합니다");
                continue;
            }
            parseEntry(fields, lineLabel, entries, errors);
        }
        return new ParseResult(entries, errors);
    }

    private static void parseEntry(String[] fields, String lineLabel, List<Entry> entries, List<String> errors) {
        CertType certType = parseCertTypeOrNull(fields[0]);
        if (certType == null) {
            errors.add(lineLabel + ": 자격증은 SQLD 또는 SQLP");
            return;
        }
        Integer round = parseRoundOrNull(fields[1]);
        if (round == null) {
            errors.add(lineLabel + ": 회차는 1 이상의 숫자");
            return;
        }
        LocalDate examDate = parseDateOrNull(fields[2]);
        if (examDate == null) {
            errors.add(lineLabel + ": 시험일은 2026-11-14 형식");
            return;
        }
        entries.add(new Entry(certType, round, examDate));
    }

    private static CertType parseCertTypeOrNull(String value) {
        try {
            return CertType.valueOf(value.toUpperCase());
        } catch (IllegalArgumentException e) {
            return null;
        }
    }

    private static Integer parseRoundOrNull(String value) {
        try {
            int round = Integer.parseInt(value);
            return round >= 1 ? round : null;
        } catch (NumberFormatException e) {
            return null;
        }
    }

    private static LocalDate parseDateOrNull(String value) {
        try {
            return LocalDate.parse(value.replace('.', '-').replace('/', '-'));
        } catch (DateTimeParseException e) {
            return null;
        }
    }
}
