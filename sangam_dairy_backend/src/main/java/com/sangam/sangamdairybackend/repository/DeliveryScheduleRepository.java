package com.sangam.sangamdairybackend.repository;

import com.sangam.sangamdairybackend.entity.DeliverySchedule;
import org.springframework.data.jpa.repository.JpaRepository;
import java.util.List;

@SuppressWarnings("all")
public interface DeliveryScheduleRepository extends JpaRepository<DeliverySchedule, Long> {
    List<DeliverySchedule> findByCustomerKey(String customerKey);
}
