package com.sangam.sangamdairybackend.controller;

import com.sangam.sangamdairybackend.entity.SupportMessage;
import com.sangam.sangamdairybackend.repository.SupportMessageRepository;
import org.springframework.web.bind.annotation.*;

import java.time.LocalDateTime;
import java.util.List;

@RestController
@RequestMapping("/api/support")
@CrossOrigin(origins = "*")
@SuppressWarnings("all")
public class SupportController {

    private final SupportMessageRepository supportMessageRepository;

    public SupportController(
            SupportMessageRepository supportMessageRepository
    ) {
        this.supportMessageRepository = supportMessageRepository;
    }

    @GetMapping("/chat/{customerKey}")
    public List<SupportMessage> getMessages(
            @PathVariable String customerKey
    ) {
        return supportMessageRepository
                .findByCustomerKeyOrderByCreatedAtAsc(customerKey);
    }

    @PostMapping("/chat")
    public SupportMessage sendMessage(
            @RequestBody ChatRequest request
    ) {

        if (request.getCustomerKey() == null
                || request.getCustomerKey().trim().isEmpty()) {
            throw new RuntimeException(
                    "Customer key cannot be empty."
            );
        }

        if (request.getMessage() == null
                || request.getMessage().trim().isEmpty()) {
            throw new RuntimeException(
                    "Support message cannot be empty."
            );
        }

        SupportMessage supportMessage = new SupportMessage();

        supportMessage.setCustomerKey(
                request.getCustomerKey().trim()
        );

        supportMessage.setMessage(
                request.getMessage().trim()
        );

        supportMessage.setSender("CUSTOMER");

        supportMessage.setCreatedAt(
                LocalDateTime.now()
        );

        return supportMessageRepository.save(
                supportMessage
        );
    }

    public static class ChatRequest {

        private String customerKey;
        private String message;
        private String sender;

        public ChatRequest() {
        }

        public String getCustomerKey() {
            return customerKey;
        }

        public void setCustomerKey(String customerKey) {
            this.customerKey = customerKey;
        }

        public String getMessage() {
            return message;
        }

        public void setMessage(String message) {
            this.message = message;
        }

        public String getSender() {
            return sender;
        }

        public void setSender(String sender) {
            this.sender = sender;
        }
    }
}
