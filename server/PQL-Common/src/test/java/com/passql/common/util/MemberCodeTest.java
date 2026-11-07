package com.passql.common.util;

import org.junit.jupiter.api.Test;

import java.util.UUID;

import static org.assertj.core.api.Assertions.assertThat;

class MemberCodeTest {

    @Test
    void 회원_UUID_앞_8자리를_대문자_회원_번호로_만든다() {
        UUID memberUuid = UUID.fromString("fd06966e-426a-4e85-a85e-727c1ddd0649");
        assertThat(MemberCode.fromMemberUuid(memberUuid)).isEqualTo("PQL-FD06966E");
    }

    @Test
    void 회원_번호는_대소문자와_앞뒤_공백에_관계없이_UUID_앞자리로_읽는다() {
        assertThat(MemberCode.parseUuidPrefix(" pql-FD06966e ")).contains("fd06966e");
    }

    @Test
    void 회원_번호_형식이_아니면_비어_있다() {
        assertThat(MemberCode.parseUuidPrefix(null)).isEmpty();
        assertThat(MemberCode.parseUuidPrefix("FD06966E")).isEmpty();
        assertThat(MemberCode.parseUuidPrefix("PQL-FD0696")).isEmpty();
        assertThat(MemberCode.parseUuidPrefix("PQL-FD06966G")).isEmpty();
    }
}
