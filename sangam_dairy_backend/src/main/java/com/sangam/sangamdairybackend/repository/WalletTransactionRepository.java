package com.sangam.sangamdairybackend.repository;

import com.sangam.sangamdairybackend.entity.WalletTransaction;
import org.springframework.data.jpa.repository.JpaRepository;
import java.util.List;

@SuppressWarnings("all")
public interface WalletTransactionRepository extends JpaRepository<WalletTransaction, Long> {
    List<WalletTransaction> findByCustomerKey(String customerKey);
}
