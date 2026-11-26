package com.sangam.sangamdairybackend.entity;

import jakarta.persistence.*;
import java.time.LocalDateTime;

@SuppressWarnings("all")
@Entity
@Table(name = "email_otps", indexes = @Index(name = "idx_email_otp_email", columnList = "email"))
public class EmailOtp {
    @Id @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;
    @Column(nullable = false, length = 254) private String email;
    @Column(nullable = false, length = 64) private String otpHash;
    @Column(nullable = false) private LocalDateTime expiresAt;
    @Column(nullable = false) private LocalDateTime createdAt;
    @Column(nullable = false) private int attempts = 0;
    @Column(nullable = false) private boolean verified = false;
    public EmailOtp() {}
    public Long getId(){return id;}
    public String getEmail(){return email;} public void setEmail(String v){email=v;}
    public String getOtpHash(){return otpHash;} public void setOtpHash(String v){otpHash=v;}
    public LocalDateTime getExpiresAt(){return expiresAt;} public void setExpiresAt(LocalDateTime v){expiresAt=v;}
    public LocalDateTime getCreatedAt(){return createdAt;} public void setCreatedAt(LocalDateTime v){createdAt=v;}
    public int getAttempts(){return attempts;} public void setAttempts(int v){attempts=v;}
    public boolean isVerified(){return verified;} public void setVerified(boolean v){verified=v;}
}
