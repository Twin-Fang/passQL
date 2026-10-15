package com.passql.member.repository;

import com.passql.member.entity.PushSendHistory;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.UUID;

public interface PushSendHistoryRepository extends JpaRepository<PushSendHistory, UUID> {

    Page<PushSendHistory> findAllByOrderBySentAtDesc(Pageable pageable);
}
