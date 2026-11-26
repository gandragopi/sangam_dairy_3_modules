package com.sangam.sangamdairybackend.repository;

import com.sangam.sangamdairybackend.entity.Notification;
import org.springframework.data.jpa.repository.JpaRepository;
import java.util.List;

@SuppressWarnings("all")
public interface NotificationRepository extends JpaRepository<Notification, Long> {
    List<Notification> findByCustomerKey(String customerKey);
}
