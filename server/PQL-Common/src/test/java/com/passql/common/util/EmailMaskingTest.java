package com.passql.common.util;

import org.junit.jupiter.api.Test;

import static org.assertj.core.api.Assertions.assertThat;

class EmailMaskingTest {

    @Test
    void 아이디_앞_2자만_남기고_도메인은_그대로_둔다() {
        assertThat(EmailMasking.mask("sqld.pass@kakao.com")).isEqualTo("sq***@kakao.com");
        assertThat(EmailMasking.mask("a@b.com")).isEqualTo("a***@b.com");
    }

    @Test
    void 이메일_형식이_아니면_null() {
        assertThat(EmailMasking.mask(null)).isNull();
        assertThat(EmailMasking.mask(" ")).isNull();
        assertThat(EmailMasking.mask("no-at-sign")).isNull();
        assertThat(EmailMasking.mask("@kakao.com")).isNull();
        assertThat(EmailMasking.mask("user@")).isNull();
    }
}
