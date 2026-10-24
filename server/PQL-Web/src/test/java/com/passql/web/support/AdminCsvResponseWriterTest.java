package com.passql.web.support;

import org.junit.jupiter.api.Test;
import org.springframework.http.HttpHeaders;
import org.springframework.http.ResponseEntity;

import java.nio.charset.StandardCharsets;
import java.util.Arrays;
import java.util.List;

import static org.assertj.core.api.Assertions.assertThat;

/** CSV 공통 응답: BOM·수식 인젝션 방지·따옴표 처리·첨부 헤더 */
class AdminCsvResponseWriterTest {

    @Test
    void 본문은_BOM으로_시작하고_머리글_다음_행이_이어진다() {
        ResponseEntity<byte[]> response = AdminCsvResponseWriter.toResponse(
                "growth.csv", List.of("기간", "가입"), List.of(List.of("10/01", 3L)));

        String body = new String(response.getBody(), StandardCharsets.UTF_8);

        assertThat(body).isEqualTo("﻿기간,가입\r\n10/01,3\r\n");
        assertThat(response.getHeaders().getFirst(HttpHeaders.CONTENT_DISPOSITION)).contains("attachment").contains("growth.csv");
        assertThat(response.getHeaders().getContentType().toString()).startsWith("text/csv").containsIgnoringCase("utf-8");
    }

    @Test
    void 수식으로_읽히는_문자열_셀은_작은따옴표를_붙인다() {
        assertThat(AdminCsvResponseWriter.toCell("=SUM(A1:A2)")).isEqualTo("'=SUM(A1:A2)");
        assertThat(AdminCsvResponseWriter.toCell("+1234")).isEqualTo("'+1234");
        assertThat(AdminCsvResponseWriter.toCell("-cmd")).isEqualTo("'-cmd");
        assertThat(AdminCsvResponseWriter.toCell("@user")).isEqualTo("'@user");
        assertThat(AdminCsvResponseWriter.toCell("\tTAB")).isEqualTo("'\tTAB");
    }

    @Test
    void 음수_숫자는_수식_방지_대상이_아니다() {
        assertThat(AdminCsvResponseWriter.toCell(-5L)).isEqualTo("-5");
        assertThat(AdminCsvResponseWriter.toCell(-1.5)).isEqualTo("-1.5");
    }

    @Test
    void 쉼표_따옴표_줄바꿈은_따옴표로_감싸고_null은_빈_칸이다() {
        assertThat(AdminCsvResponseWriter.toCell("a,b")).isEqualTo("\"a,b\"");
        assertThat(AdminCsvResponseWriter.toCell("say \"hi\"")).isEqualTo("\"say \"\"hi\"\"\"");
        assertThat(AdminCsvResponseWriter.toCell("line1\nline2")).isEqualTo("\"line1\nline2\"");
        assertThat(AdminCsvResponseWriter.toCell(null)).isEmpty();
    }

    @Test
    void 파일명의_허용_밖_문자는_밑줄로_바꾼다() {
        ResponseEntity<byte[]> response = AdminCsvResponseWriter.toResponse(
                "../a b\"c.csv", List.of("x"), List.of(Arrays.asList((Object) null)));

        assertThat(response.getHeaders().getFirst(HttpHeaders.CONTENT_DISPOSITION))
                .contains("filename=\".._a_b_c.csv\"").doesNotContain("/");
    }
}
