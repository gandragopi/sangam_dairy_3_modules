package com.sangam.sangamdairybackend.repository;

import com.sangam.sangamdairybackend.entity.SupportTicket;
import org.springframework.data.jpa.repository.JpaRepository;

@SuppressWarnings("all")
public interface SupportTicketRepository extends JpaRepository<SupportTicket, Long> {
}
