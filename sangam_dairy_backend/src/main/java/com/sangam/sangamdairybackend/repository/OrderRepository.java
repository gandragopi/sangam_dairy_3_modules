package com.sangam.sangamdairybackend.repository;

import com.sangam.sangamdairybackend.entity.Order;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;

@SuppressWarnings("all")
public interface OrderRepository extends JpaRepository<Order, String> {

    List<Order> findByCustomerPhone(String customerPhone);

    List<Order> findByStatus(String status);
}
