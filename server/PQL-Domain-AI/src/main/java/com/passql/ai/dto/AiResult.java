package com.passql.ai.dto;

import io.swagger.v3.oas.annotations.media.Schema;
public record AiResult(String text, int promptVersion) {}
