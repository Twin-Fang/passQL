package com.passql.member.repository;

import com.passql.member.entity.PushTemplate;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;
import java.util.Optional;
import java.util.UUID;

public interface PushTemplateRepository extends JpaRepository<PushTemplate, UUID> {

    List<PushTemplate> findAllByOrderByNameAsc();

    Optional<PushTemplate> findByName(String name);
}
