package com.sangam.sangamdairybackend.repository;

import com.sangam.sangamdairybackend.entity.SupportMessage;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;

@SuppressWarnings("all")
public interface SupportMessageRepository
        extends JpaRepository<SupportMessage, Long> {

    List<SupportMessage> findByCustomerKeyOrderByCreatedAtAsc(
            String customerKey
    );
}
