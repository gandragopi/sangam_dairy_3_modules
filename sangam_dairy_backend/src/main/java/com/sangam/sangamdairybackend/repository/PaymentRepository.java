package com.sangam.sangamdairybackend.repository;

import com.sangam.sangamdairybackend.entity.Payment;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;
import java.util.Optional;

@SuppressWarnings("all")
public interface PaymentRepository extends JpaRepository<Payment, Long> {

    Optional<Payment> findByPaymentReference(String paymentReference);

    List<Payment> findByOrderKey(String orderKey);
}
