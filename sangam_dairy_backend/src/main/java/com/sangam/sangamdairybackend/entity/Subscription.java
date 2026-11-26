package com.sangam.sangamdairybackend.entity;

import jakarta.persistence.*;
import java.math.BigDecimal;
import java.time.LocalDateTime;

@SuppressWarnings("all")
@Entity
@Table(name = "subscriptions")
public class Subscription {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(nullable = false)
    private String customerKey;

    @Column(nullable = false)
    private Long productId;

    @Column(nullable = false)
    private String productName;

    @Column(nullable = false)
    private int quantity;

    @Column(nullable = false)
    private String frequency; // DAILY, ALTERNATE, WEEKLY

    @Column(nullable = false)
    private BigDecimal price;

    @Column(nullable = false)
    private String status; // ACTIVE, PAUSED, CANCELLED

    @Column(nullable = false)
    private LocalDateTime startDate;

    private LocalDateTime createdAt = LocalDateTime.now();

    public Subscription() {}

    public Long getId() { return id; }
    public String getCustomerKey() { return customerKey; } public void setCustomerKey(String v) { customerKey = v; }
    public Long getProductId() { return productId; } public void setProductId(Long v) { productId = v; }
    public String getProductName() { return productName; } public void setProductName(String v) { productName = v; }
    public int getQuantity() { return quantity; } public void setQuantity(int v) { quantity = v; }
    public String getFrequency() { return frequency; } public void setFrequency(String v) { frequency = v; }
    public BigDecimal getPrice() { return price; } public void setPrice(BigDecimal v) { price = v; }
    public String getStatus() { return status; } public void setStatus(String v) { status = v; }
    public LocalDateTime getStartDate() { return startDate; } public void setStartDate(LocalDateTime v) { startDate = v; }
    public LocalDateTime getCreatedAt() { return createdAt; } public void setCreatedAt(LocalDateTime v) { createdAt = v; }
}
