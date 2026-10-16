package com.passql.question.dto;

import io.swagger.v3.oas.annotations.media.Schema;
import java.time.LocalDate;
import java.util.List;

public record LeaderboardResponse(
    @Schema(nullable = true) LocalDate date,
    List<LeaderboardEntry> entries,
    @Schema(nullable = true) LeaderboardEntry myEntry
) {}
