package com.sangam.sangamdairybackend.entity;

import jakarta.persistence.*;
import java.time.LocalDateTime;

@SuppressWarnings("all")
@Entity
@Table(name = "referrals")
public class Referral {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(nullable = false)
    private String referrerKey;

    @Column(nullable = false)
    private String referralCode;

    private String refereeEmail;

    @Column(nullable = false)
    private String status; // PENDING, SUCCESS

    @Column(nullable = false)
    private LocalDateTime createdAt = LocalDateTime.now();

    public Referral() {}

    public Long getId() { return id; }
    public String getReferrerKey() { return referrerKey; } public void setReferrerKey(String v) { referrerKey = v; }
    public String getReferralCode() { return referralCode; } public void setReferralCode(String v) { referralCode = v; }
    public String getRefereeEmail() { return refereeEmail; } public void setRefereeEmail(String v) { refereeEmail = v; }
    public String getStatus() { return status; } public void setStatus(String v) { status = v; }
    public LocalDateTime getCreatedAt() { return createdAt; } public void setCreatedAt(LocalDateTime v) { createdAt = v; }
}
