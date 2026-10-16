package com.passql.member.repository;

import java.util.UUID;

/** GROUP BY 집계 한 행: 기준 UUID(회원·공지) 별 건수 */
public interface UuidCountProjection {

    UUID getKeyUuid();

    long getRowCount();
}
