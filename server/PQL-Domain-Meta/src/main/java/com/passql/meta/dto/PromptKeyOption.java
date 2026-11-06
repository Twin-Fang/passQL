package com.passql.meta.dto;

import com.passql.meta.constant.PromptKey;

/**
 * 관리자 프롬프트 등록 폼 키 선택지 1건 (#875)
 * isUsedByCode: PromptKey 에 있으면 true, DB 에만 남은 옛 키면 false
 */
public record PromptKeyOption(String keyName, String purpose, boolean isUsedByCode) {

    // DB 에만 남은 옛 키 표시 문구
    private static final String UNUSED_KEY_PURPOSE = "코드에서 읽지 않는 키";

    public static PromptKeyOption from(PromptKey promptKey) {
        return new PromptKeyOption(promptKey.getKeyName(), promptKey.getPurpose(), true);
    }

    public static PromptKeyOption unusedKey(String keyName) {
        return new PromptKeyOption(keyName, UNUSED_KEY_PURPOSE, false);
    }

    /** 선택지 표시 문구: key_name — 용도 */
    public String label() {
        return keyName + " — " + purpose;
    }
}
