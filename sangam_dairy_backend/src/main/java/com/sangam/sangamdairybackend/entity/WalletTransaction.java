package com.sangam.sangamdairybackend.entity;

import jakarta.persistence.*;
import java.math.BigDecimal;
import java.time.LocalDateTime;

@SuppressWarnings("all")
@Entity
@Table(name = "wallet_transactions")
public class WalletTransaction {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(nullable = false)
    private String customerKey;

    @Column(nullable = false)
    private BigDecimal amount;

    @Column(nullable = false)
    private String type; // CREDIT, DEBIT

    @Column(nullable = false)
    private String description;

    private int loyaltyPoints = 0;

    @Column(nullable = false)
    private LocalDateTime createdAt = LocalDateTime.now();

    public WalletTransaction() {}

    public Long getId() { return id; }
    public String getCustomerKey() { return customerKey; } public void setCustomerKey(String v) { customerKey = v; }
    public BigDecimal getAmount() { return amount; } public void setAmount(BigDecimal v) { amount = v; }
    public String getType() { return type; } public void setType(String v) { type = v; }
    public String getDescription() { return description; } public void setDescription(String v) { description = v; }
    public int getLoyaltyPoints() { return loyaltyPoints; } public void setLoyaltyPoints(int v) { loyaltyPoints = v; }
    public LocalDateTime getCreatedAt() { return createdAt; } public void setCreatedAt(LocalDateTime v) { createdAt = v; }
}
