package com.sangam.sangamdairybackend.repository;

import com.sangam.sangamdairybackend.entity.Referral;
import org.springframework.data.jpa.repository.JpaRepository;
import java.util.List;

@SuppressWarnings("all")
public interface ReferralRepository extends JpaRepository<Referral, Long> {
    List<Referral> findByReferrerKey(String referrerKey);
}
