package com.sangam.sangamdairybackend.repository;

import com.sangam.sangamdairybackend.entity.OrderItem;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;

@SuppressWarnings("all")
public interface OrderItemRepository extends JpaRepository<OrderItem, Long> {

    List<OrderItem> findByOrderId(Long orderId);

}
