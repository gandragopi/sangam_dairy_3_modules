package com.sangam.sangamdairybackend.entity;

import jakarta.persistence.*;
import java.time.LocalDateTime;

@SuppressWarnings("all")
@Entity
@Table(name = "notifications")
public class Notification {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(nullable = false)
    private String customerKey;

    @Column(nullable = false)
    private String title;

    @Column(nullable = false, length = 1000)
    private String message;

    @Column(nullable = false)
    private boolean readStatus = false;

    @Column(nullable = false)
    private LocalDateTime createdAt = LocalDateTime.now();

    public Notification() {}

    public Long getId() { return id; }
    public String getCustomerKey() { return customerKey; } public void setCustomerKey(String v) { customerKey = v; }
    public String getTitle() { return title; } public void setTitle(String v) { title = v; }
    public String getMessage() { return message; } public void setMessage(String v) { message = v; }
    public boolean isReadStatus() { return readStatus; } public void setReadStatus(boolean v) { readStatus = v; }
    public LocalDateTime getCreatedAt() { return createdAt; } public void setCreatedAt(LocalDateTime v) { createdAt = v; }
}
