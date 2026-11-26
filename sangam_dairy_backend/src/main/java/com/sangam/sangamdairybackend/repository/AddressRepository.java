package com.sangam.sangamdairybackend.repository;

import com.sangam.sangamdairybackend.entity.Address;
import org.springframework.data.jpa.repository.JpaRepository;
import java.util.List;

@SuppressWarnings("all")
public interface AddressRepository extends JpaRepository<Address, Long> {
    List<Address> findByCustomerKey(String customerKey);
}
