package com.sangam.sangamdairybackend.repository;

import com.sangam.sangamdairybackend.entity.EmailOtp;
import org.springframework.data.jpa.repository.JpaRepository;
import java.util.Optional;

@SuppressWarnings("all")
public interface EmailOtpRepository extends JpaRepository<EmailOtp, Long> {
    Optional<EmailOtp> findTopByEmailOrderByCreatedAtDesc(String email);
}
