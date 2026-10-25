package com.passql.member.repository;

import com.passql.member.entity.MemberNotificationPreference;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.UUID;

public interface MemberNotificationPreferenceRepository extends JpaRepository<MemberNotificationPreference, UUID> {
}
