package com.passql.submission.dto;

import java.util.UUID;

public record TopicStat(
    UUID topicUuid,
    String displayName,
    double correctRate,
    int solvedCount
) {}
