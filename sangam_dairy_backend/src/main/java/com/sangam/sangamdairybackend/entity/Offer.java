package com.sangam.sangamdairybackend.entity;

import jakarta.persistence.*;
import java.math.BigDecimal;

@SuppressWarnings("all")
@Entity
@Table(name = "offers")
public class Offer {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(nullable = false, unique = true)
    private String code;

    @Column(nullable = false)
    private String title;

    @Column(nullable = false)
    private String description;

    @Column(nullable = false)
    private BigDecimal discountAmount;

    private BigDecimal minOrderValue;

    @Column(nullable = false)
    private boolean active = true;

    public Offer() {}

    public Long getId() { return id; }
    public String getCode() { return code; } public void setCode(String v) { code = v; }
    public String getTitle() { return title; } public void setTitle(String v) { title = v; }
    public String getDescription() { return description; } public void setDescription(String v) { description = v; }
    public BigDecimal getDiscountAmount() { return discountAmount; } public void setDiscountAmount(BigDecimal v) { discountAmount = v; }
    public BigDecimal getMinOrderValue() { return minOrderValue; } public void setMinOrderValue(BigDecimal v) { minOrderValue = v; }
    public boolean isActive() { return active; } public void setActive(boolean v) { active = v; }
}
