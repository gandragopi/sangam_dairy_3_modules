package com.sangam.sangamdairybackend.controller;

import com.sangam.sangamdairybackend.entity.SupportTicket;
import com.sangam.sangamdairybackend.repository.SupportTicketRepository;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.time.LocalDateTime;
import java.util.List;

@RestController
@RequestMapping("/api/support/tickets")
@CrossOrigin(origins = "*")
@SuppressWarnings("all")
public class SupportTicketController {

    private final SupportTicketRepository supportTicketRepository;

    public SupportTicketController(SupportTicketRepository supportTicketRepository) {
        this.supportTicketRepository = supportTicketRepository;
    }

    @GetMapping
    public List<SupportTicket> getAllTickets() {
        return supportTicketRepository.findAll();
    }

    @PostMapping
    public ResponseEntity<SupportTicket> createTicket(@RequestBody SupportTicket ticket) {
        if (ticket.getCreatedAt() == null) {
            ticket.setCreatedAt(LocalDateTime.now());
        }
        SupportTicket savedTicket = supportTicketRepository.save(ticket);
        return ResponseEntity.ok(savedTicket);
    }
}
