package com.sangam.sangamdairybackend.repository;

import com.sangam.sangamdairybackend.entity.Subscription;
import org.springframework.data.jpa.repository.JpaRepository;
import java.util.List;

@SuppressWarnings("all")
public interface SubscriptionRepository extends JpaRepository<Subscription, Long> {
    List<Subscription> findByCustomerKey(String customerKey);
}
