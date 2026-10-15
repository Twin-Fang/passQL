package com.passql.meta.repository;

import com.passql.meta.entity.AdminAccount;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;
import java.util.Optional;
import java.util.UUID;

public interface AdminAccountRepository extends JpaRepository<AdminAccount, UUID> {

    Optional<AdminAccount> findByUsername(String username);

    boolean existsByUsername(String username);

    List<AdminAccount> findAllByOrderByCreatedAtAsc();
}
