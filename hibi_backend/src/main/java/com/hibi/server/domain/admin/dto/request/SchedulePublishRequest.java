package com.hibi.server.domain.admin.dto.request;

import jakarta.validation.constraints.NotNull;

import java.time.LocalDateTime;

/**
 * F18: 예약 게시 요청
 */
public record SchedulePublishRequest(
        @NotNull Long songId,
        @NotNull LocalDateTime scheduledAt
) {}
