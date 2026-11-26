package com.sangam.sangamdairybackend.repository;

import com.sangam.sangamdairybackend.entity.Offer;
import org.springframework.data.jpa.repository.JpaRepository;
import java.util.Optional;

@SuppressWarnings("all")
public interface OfferRepository extends JpaRepository<Offer, Long> {
    Optional<Offer> findByCode(String code);
}
