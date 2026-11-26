package com.sangam.sangamdairybackend.repository;

import com.sangam.sangamdairybackend.entity.Customer;
import org.springframework.data.jpa.repository.JpaRepository;
import java.util.Optional;

@SuppressWarnings("all")
public interface CustomerRepository extends JpaRepository<Customer, String> {
    Optional<Customer> findByPhone(String phone);
    Optional<Customer> findByEmail(String email);
}
